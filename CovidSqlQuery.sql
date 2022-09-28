select location,date,total_cases,new_cases,total_deaths,population
from dbo.CovidDeaths$ order by 1,2

--looking at total cases vs total deaths in germany

select location,date,total_cases,cast(total_deaths as int )as total_deaths,(total_deaths/total_cases)*100 as deaths_percent 
from dbo.CovidDeaths$
where location ='Germany'
order by 1,2 

--looking at total cases vs population

select location,date,population,total_cases,(total_cases/population)*100 as cases_population 
from dbo.CovidDeaths$
where location ='Germany'
order by 1,2 

--which country has the highest infection rate inorder to the population
select location,population,max(total_cases) as max_total_case,  max(total_cases/population)*100 as max_case_pop
from dbo.CovidDeaths$
group by location, population
order by 4 desc

--which country has the highest death
select location , population,max(cast(total_deaths as int)) as total_deaths
from dbo.CovidDeaths$
where continent is not null
group by location, population
order by total_deaths desc

--which continent has the highest death 
select location,max(cast(total_deaths as int)) as total_deaths
from dbo.CovidDeaths$
where continent is null and location <> 'world'
group by location
order by total_deaths desc

-- global deaths( when continent is null , it means that we are calculating the continents number  instead of countries
select date,sum(total_cases)as global_cases,sum(cast(total_deaths as int)) as global_deaths
from dbo.CovidDeaths$
where date='2021-04-30 00:00:00.000' and continent is null
group by date


--joining the two tables (deaths and vaccination)
select * from dbo.CovidDeaths$ dea join dbo.CovidVaccinations$  vac on 
dea.location=vac.location and dea.date= vac.date

-- population vs total vaccination for countries
select dea.location,dea.date,dea.population ,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_total_vac
 from dbo.CovidDeaths$ dea join dbo.CovidVaccinations$  vac on 
dea.location=vac.location and dea.date= vac.date
where dea.continent is not null

-- calculating the rolling vaccination  vs population percentage using cte 

with PopvsVac (location,date,population,new_vaccinations,rolling_total_vac)
as 
(select dea.location,dea.date,dea.population ,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_total_vac
 from dbo.CovidDeaths$ dea join dbo.CovidVaccinations$  vac on 
dea.location=vac.location and dea.date= vac.date
where dea.continent is not null and vac.new_vaccinations is not null )

select * ,(rolling_total_vac /population)*100 as roll_vac_pop_per
from PopvsVac


--creating the same query but using view in order to use it later in our visualisations
create view percentPopulationVaccinated as
select dea.location,dea.date,dea.population ,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rolling_total_vac
 from dbo.CovidDeaths$ dea join dbo.CovidVaccinations$  vac on 
dea.location=vac.location and dea.date= vac.date
where dea.continent is not null and vac.new_vaccinations is not null

select * ,(rolling_total_vac/population)* 100 as vac_pop_per from percentPopulationVaccinated
