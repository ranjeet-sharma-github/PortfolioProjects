select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Total deaths in positive cases
--Shows the likelyhood of dying 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--Total cases vs population
select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as casesPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--Countries with highest infection rate compared to population
select location,Max(total_cases) as highestInfectionCount, population, Max((total_cases/population))*100 as casesPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by population, location
order by casesPercentage desc

--Showing countrues with highest deathCount by population
select location, MAX(cast(total_deaths as int)) as totalDeaths
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by totalDeaths desc

--By continent
select continent, MAX(cast(total_deaths as int)) as totalDeaths
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by totalDeaths desc

--Showing continents with highest death counts by population
select continent, MAX(cast(total_deaths as int)) as totalDeaths
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by totalDeaths desc

--Global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--looking at total population vs total vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeoppleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

With PopsVsVacc(Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeoppleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopsVsVacc


-- Temp table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeoppleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store date for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeoppleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
From PercentPopulationVaccinated
