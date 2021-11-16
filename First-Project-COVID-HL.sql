select *
from Project_COVID..CovidDeaths
Where continent is not null
order by 3,4

--select *
--from Project_COVID..CovidVaccinations
--order by 3,4

-- We are going to Select the data we're goin to use 

Select location, date, total_cases, new_cases, total_deaths, population
From Project_COVID..CovidDeaths
Where continent is not null
order by 1,2

-- We are going to see the Total Cases vs Total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project_COVID..CovidDeaths
Where continent is not null
order by 1,2

-- I'm going to look how Mexico was handling the global pandemic 
-- And the likelihood of dying if infected by COVID in Mx 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project_COVID..CovidDeaths
Where location like '%mexico%'
and continent is not null
order by 1,2

-- Total cases vs the Population 
-- What percentage of the population got covid 

Select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
From Project_COVID..CovidDeaths
--Where location like '%mexico%'
Where continent is not null
order by 1,2

-- Countries with the highest infection rate vs the population  
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as MaxInfectionRate
From Project_COVID..CovidDeaths
--Where location like '%mexico%'
Where continent is not null
Group by location, population
order by MaxInfectionRate desc

-- Countries with the highest death count per population 
Select location, MAX(cast(Total_deaths as int)) as MaxTotalDeath
From Project_COVID..CovidDeaths
--Where location like '%mexico%'
Where continent is not null
Group by location
order by MaxTotalDeath desc

-- Analysing the data per Continent 
Select location, MAX(cast(Total_deaths as int)) as MaxTotalDeath
From Project_COVID..CovidDeaths
--Where location like '%mexico%'
Where continent is null
Group by location
order by MaxTotalDeath desc

-- Analysing the data per Continent 
--Showing continents with the highest death rate per population

Select continent, MAX(cast(Total_deaths as int)) as MaxTotalDeath
From Project_COVID..CovidDeaths
--Where location like '%mexico%'
Where continent is not null
Group by continent
order by MaxTotalDeath desc


-- Global numbers 
-- Grouping by date
Select date, SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int))as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as GlobalDeathPerc
From Project_COVID..CovidDeaths
Where continent is not null
Group by date
order by 1,2

-- Getting the just the total
Select  SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int))as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as GlobalDeathPerc
From Project_COVID..CovidDeaths
Where continent is not null
order by 1,2


-- Population infected vs Vaccinated
Select *
From Project_COVID..CovidDeaths dea
Join Project_COVID..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Adding the new vaccinated people to the previous ones 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as PeopleCountedVacc
From Project_COVID..CovidDeaths dea
Join Project_COVID..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
Order by 2,3

-- Using CTE to know the percentage of people vaccinated 

With PopvsVac (continent, location, date, population, new_vaccinations, PeopleCountedVacc)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as PeopleCountedVacc
From Project_COVID..CovidDeaths dea
Join Project_COVID..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order by 2,3
)

Select *, (PeopleCountedVacc/population)*100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
ocation nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleCountedVacc numeric
)
-- for larger number we should use Sum(convert(bigint,)) because it will drop an error if we just use sum(convert(int,))
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as PeopleCountedVacc
From Project_COVID..CovidDeaths dea
Join Project_COVID..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null 
--Order by 2,3

Select *, (PeopleCountedVacc/population)*100 as PercVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated1 as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
  dea.date) as PeopleCountedVacc
From Project_COVID..CovidDeaths dea
Join Project_COVID..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
--Order by 2,3

select *
from PercentPopulationVaccinated1


-- for tableau tables 
-- 2. 
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Project_COVID..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc 

--3.
Select location, population, MAX(total_cases) as HighestInfenctionCount, MAX(total_cases/population)*100 as PercentPopInfected
From Project_COVID..CovidDeaths
Group by location, population
Order by PercentPopInfected desc 

--4.
Select location, population, date, MAX(total_cases) as HighestInfenctionCount, MAX(total_cases/population)*100 as PercentPopInfected
From Project_COVID..CovidDeaths
Group by location, population, date
Order by PercentPopInfected desc 
