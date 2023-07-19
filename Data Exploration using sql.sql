select * 
from DataExploration..CovidDeaths
order by 3,4

select * 
from DataExploration..CovidVaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from DataExploration..CovidDeaths
order by 1,2

--Calculating death percentage

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from DataExploration..CovidDeaths
where location = 'India'
order by 1,2

--Total Cases Percentage

select location,date,total_cases,population,(total_cases/population)*100 as cases_percentage
from DataExploration..CovidDeaths
where location = 'India'
order by 1,2

--Infection rate compared to population

select location,max(total_cases) as highestInfectionRate,population,max((total_cases/population))*100 as max_cases_percentage
from DataExploration..CovidDeaths
group by location,population
order by max_cases_percentage desc

--Highest death count per population

select location,max(total_deaths) as highestDeathCount
from DataExploration..CovidDeaths
group by location
order by highestDeathCount desc

--Here I noticed that total_deaths column is of varchar datatype, so I will cast it to int

select location,max(cast(total_deaths as int)) as highestDeathCount
from DataExploration..CovidDeaths
group by location
order by highestDeathCount desc


-- Joining the two tables, CovidDeaths and CovidVaccinations

select *
from DataExploration..CovidDeaths d
join DataExploration..CovidVaccinations v
on d.location=v.location
and d.date=v.date

-- New vaccination each day

select d.continent,d.location,d.date,d.population,v.new_vaccinations
from DataExploration..CovidDeaths d
join DataExploration..CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3

--Using rolling to add new Vaccinations each day

select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccination
from DataExploration..CovidDeaths d
join DataExploration..CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3

--Population VS Vaccinations using CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccination)
as
(
	select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccination
	from DataExploration..CovidDeaths d
	join DataExploration..CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
	where d.continent is not null
)
select *, (RollingPeopleVaccination/population)*100 as popVSvac
from PopvsVac


-- Using Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric
)

insert into #PercentPopulationVaccinated
	select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccination
	from DataExploration..CovidDeaths d
	join DataExploration..CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
	where d.continent is not null

select *, (RollingPeopleVaccination/population)*100 as popVSvac
from #PercentPopulationVaccinated


--Creating View

create view PercentPopulationVaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations,sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccination
	from DataExploration..CovidDeaths d
	join DataExploration..CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
	where d.continent is not null

select *
from PercentPopulationVaccinated