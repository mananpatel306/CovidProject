select * 
from Covid_project.dbo.covid_deaths as covid_death

--Total cases and deaths in countries
select location, population, max(cast(total_cases as int)) as totalcases, max(cast(total_deaths as int)) as totaldeaths
from covid_deaths
where continent is not null 
group by location, population
order by totaldeaths desc

--Total cases and deaths in continents
select continent, max(cast(total_cases as int)) as totalcases, max(cast(total_deaths as int)) as totaldeaths
from covid_deaths
where continent is not null
group by continent
order by totaldeaths desc

--Total cases and deaths in continents including other factors as well (Income group, international organizations)
select location, max(cast(total_cases as int)) as totalcases, max(cast(total_deaths as int)) as totaldeaths
from covid_deaths
where continent is null
group by location
order by totaldeaths desc


--Percentage calculation of deaths to covid cases
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage
from covid_deaths
where location like '%India%'
order by 1,2

--Percentage calculation of cases to population
select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as percentage
from covid_deaths
where location like '%India%'
order by 1,2

--Percentage calculation of deaths to population
select location, date, total_cases, total_deaths, population, (total_deaths/population)*100 as percentage
from covid_deaths
where location like '%India%'
order by 1,2

--Countries with highest infection rate to population
select location, max(total_cases) as totalcases, population, max((total_cases/population))*100 as percentage
from covid_deaths
where location != 'International'
group by location, population
order by percentage desc


--Countries with highest death rate to population
select location, max(total_deaths) as totaldeaths, population, max((total_deaths/population))*100 as percentage
from covid_deaths
where location != 'International'
group by location, population
order by percentage desc

--Vaccination Table
select *
from covid_vaccine
order by 3

--Total population vs Vaccination

with popvsvac (location, date, continent, population, new_vaccination, total_vaccinations, cumalative_vaccinations)
as 
(
select deaths.location, deaths.date, deaths.continent, deaths.population, vaccine.new_vaccinations,  
   SUM(cast(vaccine.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.date) as cumalative_vaccinations
from covid_deaths as deaths
join covid_vaccine as vaccine
   on deaths.date = vaccine.date
   and deaths.location = vaccine.location
where deaths.continent is not null
--order by 2,3
)
select *, cumalative_vaccinations/population*100
from popvsvac

--temp table
drop table if exists #Population_Percentage_Vaccinated
create table #Population_Percentage_Vaccinated
(
location nvarchar(255),
date datetime,
continent nvarchar(255),
population numeric,
new_vaccinations numeric,
total_vaccinations numeric,
cumalative_vaccination numeric
)

insert into #Population_Percentage_Vaccinated
select deaths.location, deaths.date, deaths.continent, deaths.population, vaccine.new_vaccinations, vaccine.total_vaccinations, 
   SUM(cast(vaccine.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.location, deaths.date) as cumalative_vaccination
from covid_deaths as deaths
join covid_vaccine as vaccine
   on deaths.date = vaccine.date
   and deaths.location = vaccine.location
where deaths.continent is not null
--order by 2,3
select * ,cumalative_vaccination/population*100 as vaccinated_percent
from #Population_Percentage_Vaccinated 

select * from covid_deaths
select * from covid

--creating views
create view first_view as
select deaths.location, deaths.date, deaths.continent, deaths.population, vaccine.new_vaccinations,  
   SUM(cast(vaccine.new_vaccinations as bigint)) over (partition by deaths.location order by deaths.date) as cumalative_vaccinations
from covid_deaths as deaths
join covid_vaccine as vaccine
   on deaths.date = vaccine.date
   and deaths.location = vaccine.location
where deaths.continent is not null