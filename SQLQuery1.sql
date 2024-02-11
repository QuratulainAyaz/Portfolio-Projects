select *
from Portfolio..CovidDeaths$
order by 3,4

select *
from Portfolio..CovidVaccinations$
order by 3,4

--select the data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

--looking attotal cases vs death
select location, date, total_cases, new_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
from CovidDeaths$
Where location like '%states%'
order by 1,2

--looking at the total cases vs population
select location, date, total_cases, new_cases, population, ((total_cases/population)*100) as PercentagePopulationInfected
from CovidDeaths$
--Where location like '%states%'
order by 1,2

---loking at countries with highest infectious rate compared to the population
select location , population,  MAX(total_cases) as HighestInefetionCount, MAX((total_cases/population)*100) as PercentagePopulationInfected
from CovidDeaths$
Where location = 'Pakistan'
Group By location, population
order by PercentagePopulationInfected desc

--showing countries with highest deathcount per population
select location , MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--Where location = 'Pakistan'
Where continent is  null
Group By location
order by TotalDeathCount desc


--showing the continents with the highest death count
--lets break things by continent
select continent , MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--Where location = 'Pakistan'
Where continent is not null
Group By continent
order by TotalDeathCount desc


--the Global Numbers
Select  date, SUM(new_cases) as totallcases, SUM(CAST(total_deaths as int)) as totalldeaths, SUM(CAST(total_deaths as int))/SUM(new_cases)*100 as deathpercentage --, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
--Where location like '%states'
Where continent is not null
Group by date
order by 1,2

--the Global Numbers without date
Select  SUM(new_cases) as totallcases, SUM(CAST(total_deaths as int)) as totalldeaths, SUM(CAST(total_deaths as int))/SUM(new_cases)*100 as deathpercentage --, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths$
--Where location like '%states'
Where continent is not null
--Group by date
order by 1,2



select *
from Portfolio..CovidVaccinations$


--Looking at the total population and the vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2, 3


--looking at with rolling count of vac with every day

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingCountVaccinations
-- (RollingCountVaccinations/new_vaccinations)*100
from Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2, 3

-- we will use CTE to create table to get the rolling percentage
With PopvsVac (continent, location, date, population, new_vaccinations, RollingCountVaccinations) 
as
(
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingCountVaccinations
from 
Portfolio..CovidDeaths$ dea
Join 
Portfolio..CovidVaccinations$ vac
on 
dea.location=vac.location
and 
dea.date=vac.date
where 
dea.continent is not null
)
select *, (RollingCountVaccinations/Population)*100 as RollingVacPercentage
From
PopvsVac


--temp table

CREATE Table #PerPopVac
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountVaccinations numeric
)
Insert into #PerPopVac

select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingCountVaccinations
from 
Portfolio..CovidDeaths$ dea
Join 
Portfolio..CovidVaccinations$ vac
on 
dea.location=vac.location
and 
dea.date=vac.date
where 
dea.continent is not null

select *, (RollingCountVaccinations/Population)*100 as RollingVacPercentage
From #PerPopVac

--droping the table to alter it
Drop Table
If exists  #PerPopVac
CREATE Table #PerPopVac
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCountVaccinations numeric
)
Insert into #PerPopVac

select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingCountVaccinations
from 
Portfolio..CovidDeaths$ dea
Join 
Portfolio..CovidVaccinations$ vac
on 
dea.location=vac.location
and 
dea.date=vac.date
--where dea.continent is not null

select *, (RollingCountVaccinations/Population)*100 as RollingVacPercentage
From #PerPopVac
-- creating views to store data for later visualisations 
Create View PerPopVac as
select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as RollingCountVaccinations
from 
Portfolio..CovidDeaths$ dea
Join 
Portfolio..CovidVaccinations$ vac
on 
dea.location=vac.location
and 
dea.date=vac.date
where dea.continent is not null