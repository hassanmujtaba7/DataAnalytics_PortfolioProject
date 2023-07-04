

select *
from covid_deaths$
order by 3,4;

select location, date, total_cases,new_cases, total_deaths, population
from covid_deaths$
order by 1,2


EXEC sp_help 'dbo.covid_vaccinaitons$';

alter table covid_deaths$
alter column total_cases float

alter table covid_deaths$
alter column total_deaths float


--likelihood of dying is you contract covid in your country
--looking at total cases vs total deaths
select location, date,total_cases,new_cases, total_deaths,(total_deaths / total_cases)*100 as deathPercentage
from covid_deaths$
where location LIKE 'germany'
order by 1,2


-- total cases vs population
select location, date,total_cases,new_cases, population,(total_cases /population )*100 as populationAffected
from covid_deaths$
where location LIKE 'germany'
order by 1,2

--countries having highest infection rates
select location,population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationAffected
from covid_deaths$
group by location, population 
order by 4 DESC;

-- Countries with highest death count per population
select location, population, (MAX(total_deaths)/MAX(population)*100) as Max_death_count
from covid_deaths$
group by location, population
order by Max_death_count desc

-- countries with highest death count per population
select location, MAX(total_deaths) as total_death_count
from covid_deaths$
where continent is not null
group by location
order by total_death_count desc

-- CONTINENTS with highest death count per population
select continent, MAX(total_deaths) as total_death_count
from covid_deaths$
where continent is not null
group by continent
order by total_death_count desc

-- global numbers
-- global death percentage with increasing date
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths , sum(new_deaths)/nullif(sum(new_cases),0)*100 as death_percentage
from covid_deaths$
where continent is not null
group by date
order by 1,2

--rolling ticker for people vaccinated
 select d.continent, d.location, d.date,d.population, CAST(v.new_vaccinations as float) as new_vaccinations, 
 sum(cast(v.new_vaccinations as float)) OVER (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
-- (rolling_people_vaccinated/population)*100
 from covid_deaths$ as d
 join covid_vaccinations$ as v 
	on d.location = v.location
	and d.date=v.date
where d.continent is not null
order by 2,3


WITH cte (continent, location, date, population, new_vaccinations,rolling_people_vaccinated)  as (
 select d.continent, d.location, d.date,d.population, CAST(v.new_vaccinations as float) as new_vaccinations, 
 sum(cast(v.new_vaccinations as float)) OVER (partition by d.location order by d.location, d.date) as rolling_people_vaccinated

 from covid_deaths$ as d
 join covid_vaccinations$ as v 
	on d.location = v.location
	and d.date=v.date
where d.continent is not null
--order by 2,3)
)
select *, (rolling_people_vaccinated/population)*100
from cte

-- creating views
