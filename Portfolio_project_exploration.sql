select * 
from Portfolio_Project..CovidDeaths
where continent is not null
order by 3,4;


--select * 
--from Portfolio_Project..CovidVaccinations
--order by 3,4;

select Location, date, total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths;


-- Looking at Total Cases and Total Deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_Project..CovidDeaths
where location = 'India'
order by 1,2;


-- Total cases vs Population
select Location, date, population, total_cases,(total_cases/population)*100 as Case_Percentage
from Portfolio_Project..CovidDeaths
where location = 'India' 
order by 1,2;

-- Countries with highest infection rate compared to Population
select location, population, MAX(total_cases) as Highest_Infection_Count, Max((total_cases/population))*100 
as Percent_Population_Infected
from Portfolio_Project..CovidDeaths
where continent is not null
group by location, population
order by Percent_Population_Infected desc;

-- Countries with highest death rate compared to population
select location, population, MAX(cast(total_deaths as int)) as Total_Death_Count
from Portfolio_Project..CovidDeaths
where continent is not null
group by location, population
order by Total_Death_Count desc;


-- Continents with highest death count
select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc;


-- Global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Percentage_Death
from Portfolio_Project..CovidDeaths
--where location = 'India' 
where continent is not null
group by date
order by 1,2;


--total death percentage of the world
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Percentage_Death
from Portfolio_Project..CovidDeaths
--where location = 'India' 
where continent is not null
order by 1,2;


--total populations vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,
dea.date) as rolling_vacc_count
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


--using CTE

-- note: number of columns in the cte should be the same as in the select command

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,
dea.date) as rolling_vacc_count
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rolling_People_Vaccinated/Population)*100 as Population_Percent_Vaccinated 
from PopvsVac;

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as Population_Percent_Vaccinated 
from #PercentPopulationVaccinated;


-- Creating view to store data for data viz later

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3;


Select * 
from PercentPopulationVaccinated
