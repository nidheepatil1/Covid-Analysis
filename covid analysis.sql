--liklihood of dying if infected my covid
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as deathPercent
from [Portfolio dataase]..CovidDeaths
ORDER by 1,2

--percentage of population affected by covid
select location, date, total_cases, population, (total_cases/population) * 100 as covidCasePercent
from [Portfolio dataase]..CovidDeaths
ORDER by 1,2

--looking at country with highest infection rate with compared to its population
select location, max(total_cases) as total_cases, population, (max(total_cases/population) * 100) as covidCasePercent
from [Portfolio dataase]..CovidDeaths
group by location, population
ORDER by covidCasePercent desc
 
--looking at country with death count rate with compared to its population
select continent, max(cast(total_deaths as int)) as totaldeathCount, (max(total_deaths/population) * 100) as deathPercent
from [Portfolio dataase]..CovidDeaths
where continent is not null
group by continent
ORDER by deathPercent desc

--overall world
select sum(cast(new_deaths as int)) as totaldeathCount,sum(new_cases) as totalcases, ((sum(cast(new_deaths as int))/sum(new_cases)) * 100) as deathPercent
from [Portfolio dataase]..CovidDeaths
where continent is not null
order by 1 

-- Vaccination per location vs population
with popVsVac as(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.date) as peopleVaccinated
from [Portfolio dataase]..CovidDeaths as dea
join [Portfolio dataase]..CovidVaccinations as vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select * , (peopleVaccinated/population) * 100 as vaccinatedPeoplePercent
from popVsVac

--TEMP table
Drop table if exists #percentOfPeopleVaccinated
create table #percentOfPeopleVaccinated
(
continent varchar(255), 
location varchar(255),
date datetime,
population numeric,
new_vaccination numeric,
peopleVaccinated numeric
)
insert into #percentOfPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as peopleVaccinated
from [Portfolio dataase]..CovidDeaths as dea
join [Portfolio dataase]..CovidVaccinations as vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select * , (peopleVaccinated/population) * 100 as vaccinatedPeoplePercent
from #percentOfPeopleVaccinated

--create view
create view percentOfPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as peopleVaccinated
from [Portfolio dataase]..CovidDeaths as dea
join [Portfolio dataase]..CovidVaccinations as vac
on dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null