
--Select * from PortfolioProject.dbo.CovidDeaths
--Order by 3,4

--Select * from PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select the data that we are going to use

Select location,date, total_cases,new_cases,total_Deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total_cases vs total_Death

Select location, date,total_cases,total_Deaths, (total_deaths/total_cases)*100  as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%States%'
order by 1,2

-- Looking at total_cases vs Population
-- Show what % of population got covid

Select location, date,population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
where location like '%States%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%States%'
Group by location, population
order by PercentagePopulationInfected desc

--Showing countries highest death count per population
Select location, Max(cast(total_deaths as int)) As TotalDeathCount
From portfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc


--Lets break things down continent
Select location, Max(cast(total_deaths as int)) As TotalDeathCount
From portfolioProject..CovidDeaths
where continent is null
Group by location
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select sum(new_cases) as Total_cases, sum(cast(new_deaths as Int)) As Total_Deaths, (sum(cast(new_deaths as Int))/sum(new_cases))*100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group by date
Order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join portfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join portfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
select *, (rollingPeopleVaccinated/population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
, sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join portfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3
select *, (rollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select * from PercentPopulationVaccinated
