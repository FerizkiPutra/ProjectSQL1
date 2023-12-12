

Select *
From PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortofolioProject..CovidVaccinations
--order by 3,4


-- Using Data

Select Location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
Order by 1,2 

-- Total cases and total deaths

Select Location, date,population, total_cases, new_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location like '%donesia%'
Order by 1,2


--Total Case and Population %
Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationCasePercentage
From PortofolioProject..CovidDeaths
--Where location like '%donesia%'
Order by 1,2

-- Highest Case
Select Location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100 as PopulationInfectsPercentage
From PortofolioProject..CovidDeaths
Group by location, population
Order by PopulationInfectsPercentage desc


-- HIghest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeath
From PortofolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeath desc

-- Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeath
From PortofolioProject..CovidDeaths
where continent is null
Group by location
Order by TotalDeath desc

-- Global Numbers
Select Sum(new_cases) as total_cases,Sum(cast(new_deaths as int))as total_death, Sum(cast(New_deaths as int))/Sum(New_cases)*100 as DeathPercentage --total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
where continent is not null
--group by date
Order by 1,2

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentagesPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Create View TheGlobalNumber as
Select Sum(new_cases) as total_cases,Sum(cast(new_deaths as int))as total_death, Sum(cast(New_deaths as int))/Sum(New_cases)*100 as DeathPercentage --total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
where continent is not null
--group by date
--Order by 1,2

