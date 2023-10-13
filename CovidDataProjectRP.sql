Select*
From PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4

--Select*
--From [Portfolio Project]..CovidVaccinations
--order by 3, 4

--Select Data that we are going to be using

Select Location, date, total_cases new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by  1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by  1,2

--Looking at Total Cases vs. Population
--Shows what percentage of population got Covid

Select location, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%states%'
order by  1,2


--Lookin at countries with highest Infection Rate compared to Population\

Select Location, Population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
From [PortfolioProject]..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by  PercentPopulationInfected desc

--Showing the Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continents with highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [PortfolioProject]..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by date
order by  1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [PortfolioProject]..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by  1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject]..CovidDeaths dea
Join [PortfolioProject]..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date = vac.date
	where dea.continent is not null
Order by 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject]..CovidDeaths dea
Join [PortfolioProject]..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3,
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject]..CovidDeaths dea
Join [PortfolioProject]..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3,

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject]..CovidDeaths dea
Join [PortfolioProject]..CovidVaccinations vac
	on dea.location= vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3


Select*
From PercentPopulationVaccinated
