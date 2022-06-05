Select *
From PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4 

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases Vs Total Deaths
--Shows chance of death if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
--where location like '%states%' 
order by 1,2

--Looking at total cases vs population
Select Location, date, population, total_cases,  (total_cases/population)*100 as PopPercentageInfected
From PortfolioProject..CovidDeaths
--where location like '%states%' 
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, Population, Max(total_cases)as HighestInfectionCount,  Max((total_cases/population))*100 as PopPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%' 
Group by Location, Population
order by PopPercentage DESC

-- Showing Countries with Highest Death Count 
Select Location, Max(cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null 
Group by Location
order by TotalDeathCount DESC

--BY Continent 
Select continent, Max(cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null 
Group by continent
order by TotalDeathCount DESC

--Showing continents with highes death count

Select continent, Max(cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null 
Group by continent
order by TotalDeathCount DESC

-- GLOBAL NUMBERS
Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases) * 100 as DeathPercentage 
From PortfolioProject..CovidDeaths
where continent is not null 
--group by date
order by 1,2

-- Looking at Total Population vs vaccinations
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--USE CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)

Select * , (RollingPeopleVaccinated/Population) *100 
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location  nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

Select * , (RollingPeopleVaccinated/Population) *100 
From #PercentPopulationVaccinated

--Creating View to store data for later

