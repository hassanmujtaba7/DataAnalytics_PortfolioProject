-- Covid 19 data exploration 
-- Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, CASE functions, Creating Views, Converting Data Types

---------------------------------------------------------------------------------------------------------------

-- calculating infection rates per country -- 
select location,population, date,  
	MAX(total_cases) as highestInfectionCount, 
	(max(total_cases)/population)*100 as PercentPopulationAffected
from covid_deaths$
	
group by location, population , date
order by 4 DESC;

---------------------------------------------------------------------------------------------------------------

-- Calculating highest death count per continent

select continent, 
	MAX(total_deaths) as total_death_count
from covid_deaths$
	
where continent is not null
group by continent
order by total_death_count desc
	
---------------------------------------------------------------------------------------------------------------
	
--calculating global death percentage with increasing date
	
select date, sum(new_cases) as total_cases, 
	sum(new_deaths) as total_deaths, 
	sum(new_deaths)/nullif(sum(new_cases),0)*100 as death_percentage
from covid_deaths$
	
where continent is not null
group by date
order by 1,2
	
---------------------------------------------------------------------------------------------------------------
--rolling ticker for people vaccinated by country with increasing date
	
WITH cte as 
(
 select d.continent, d.location, d.date,d.population, 
	CAST(v.new_vaccinations as float) as new_vaccinations, 
	sum(cast(v.new_vaccinations as float)) OVER (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
from covid_deaths$ as d
	
 join covid_vaccinations$ as v 
	on d.location = v.location
	and d.date=v.date
	
where d.continent is not null
)
	
select *, (rolling_people_vaccinated/population)*100 as abc
from cte
order by 2,3
	
---------------------------------------------------------------------------------------------------------------	

--calculating percentage recovered by country with increasing date
	
with cte1 as 
	(
select location, date, total_cases, total_deaths, 
	(total_cases - total_deaths) as total_recoveries
from covid_deaths$
	)

select *, (total_recoveries/total_cases)*100 as percentage_recovered
from cte1
order by location
---------------------------------------------------------------------------------------------------------------

-- calculating percentage of population fully vaccinated

create view percentage_fully_vaccinated as
select v.location, d.population, d.date,people_fully_vaccinated, 
	(isnull(people_fully_vaccinated,0)/d.population)*100 as percentage_fully_vacc
from covid_vaccinations$ as v
	
join covid_deaths$ as d
	on v.location= d.location
	and v.date=d.date

---------------------------------------------------------------------------------------------------------------

-- Making different age groups of global population using CASE function and then calculating global infection rates by age groups
	
with cte2 as
(select new_deaths, v.location,v.date,new_cases, v.continent,
case
when median_age <= '20' then 'less than 20'
when median_age > '20' AND median_age <= '30' then '20-30'
when median_age > '30' AND median_age <= '40' then '30-40'
when median_age > '40' then 'above 40'
END as age_groups_infected

from covid_vaccinations$ as v
join covid_deaths$ as d ON v.location=d.location
AND v.date = d.date

--order by v.location,v.date
)

select sum(new_deaths) as total_deaths,sum(new_cases) as total_cases , age_groups_infected
from cte2
where continent is not null
and age_groups_infected is not null
group by age_groups_infected

---------------------------------------------------------------------------------------------------------------
	
-- calculating total deaths per country and classifying them into using CASE function using number of deaths

with cte3 as(
select continent,  sum (isnull(new_deaths,0)) as deaths_per_country, location
from covid_deaths$
where continent is not null
group by continent, location
--order by 3 desc
)

select *, 
case 
when deaths_per_country < '100000' then 'other'
else location 
end as loaction1
from cte3
--order by deaths_per_country desc

select *
from covid_vaccinations$
order by date
---------------------------------------------------------------------------------------------------------------
