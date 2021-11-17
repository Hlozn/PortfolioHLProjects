--- DATA CLEANING 

Select *
From HousingProject.dbo.NashvilleHousing

--- 1. First let's focus on the date, we should always standarized it 

Select SaleDate, Convert(date,SaleDate) 
From HousingProject.dbo.NashvilleHousing 

Update NashvilleHousing
Set SaleDate = Convert(date,SaleDate)

ALTER TABLE NashvilleHousing	
Add SaleDateConv Date;

Update NashvilleHousing
Set SaleDateConv = Convert(Date,SaleDate)

Select SaleDateConv 
From HousingProject.dbo.NashvilleHousing 

----------------------------------------------------------------------------------
--- 2. Populate Property Address data 

Select * 
From HousingProject.dbo.NashvilleHousing 

-- 3. from the previous query we get several nulls, in the next query I'm going to identify where are the nulls 
Select PropertyAddress 
From HousingProject.dbo.NashvilleHousing 
Where PropertyAddress is null 

-- with this query I'm going to see if I'm able to match the ParcelID with the nulls in the PropertyAddress
Select * 
From HousingProject.dbo.NashvilleHousing 
Order by ParcelID

-- 4. with this query I'm able to identify with the ParcelID the PropertyAddress but keeping in mind that the UniqueId must not interfere with query dut the fact that is unique 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
From HousingProject.dbo.NashvilleHousing a
JOIN HousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

-- 5. with this I can compere where the PropertyAddress is null and it's matter o populate the addresses 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
From HousingProject.dbo.NashvilleHousing a
JOIN HousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

-- 6. with this query we're going to populate the PropertyAddress nulls
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingProject.dbo.NashvilleHousing a
JOIN HousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- 7. 
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From HousingProject.dbo.NashvilleHousing a
JOIN HousingProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--- we can check if it worked by running the query 6. 
----------------------------------------------------------------------------------

--- 8. Separate the PropertyAddress by Address, city and State 

select PropertyAddress
From HousingProject.dbo.NashvilleHousing

-- 9. with this I'm separating the Property Address in Address and City until the comma in the PropertyAddress column,
select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From HousingProject.dbo.NashvilleHousing

-- 10. with this I'm creating a new column named propertysplitaddress with the first line of substring 
ALTER TABLE NashvilleHousing	
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


-- 11. with this I'm creating a new column named propertysplitcity with the second line of substring 

ALTER TABLE NashvilleHousing	
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- just for checking if everything ran ok
Select *
from HousingProject.dbo.NashvilleHousing

Select OwnerAddress
from HousingProject.dbo.NashvilleHousing

-- this is a much simpler way of separate things in different columns
Select 
parsename(replace(OwnerAddress, ',','.'), 3) 
,parsename(replace(OwnerAddress, ',','.'), 2) 
,parsename(replace(OwnerAddress, ',','.'), 1)  
from HousingProject.dbo.NashvilleHousing


ALTER TABLE dbo.NashvilleHousing	
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.'), 3)


ALTER TABLE NashvilleHousing	
Add OwnerSplitCity Nvarchar(255);
Update NashvilleHousing
Set OwnerSplitCity = parsename(replace(OwnerAddress, ',','.'), 2)


ALTER TABLE NashvilleHousing	
Add OwnerSplitState Nvarchar(255);
Update NashvilleHousing
Set OwnerSplitState = parsename(replace(OwnerAddress, ',','.'), 1)

Select *
From HousingProject..NashvilleHousing

-------------------------------------------------------------------------------------

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From HousingProject..NashvilleHousing
Group by SoldAsVacant
order by 2 

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
From HousingProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END

----------------------------------------------------------------------
--- Removing duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION by ParcelID,
				 PropertyAddress,
				 salePrice,
				 SaleDate,
				 LegalReference 
				 ORDER BY 
					UniqueID
					) row_num

from HousingProject..NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
Where row_num > 1 
--Order by PropertyAddress

---------------------------------------------------------------------------------

-- Delate Unused Columns
Select *
from HousingProject..NashvilleHousing

ALTER TABLE HousingProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 