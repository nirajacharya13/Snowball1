select *
from CovidPortfoliioP..CovidDeaths
where continent is not null
order by 3,4

--Selecting the data that we are going to use

select location, date, total_cases, new_cases, total_deaths,population
from CovidPortfoliioP..CovidDeaths
order by 1,2

ALTER TABLE CovidPortfoliioP..CovidDeaths
ALTER COLUMN population float;

ALTER TABLE CovidPortfoliioP..CovidVaccinations
ALTER COLUMN new_vaccinations float;

--Total cases vs totatl deaths

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidPortfoliioP..CovidDeaths
--where total_cases !=NULL and total_deaths != NULL
where location = 'India'
order by 1,2;

--Total Cases vs Population

select location,date, total_cases, population, (total_cases/population)*100 as CasesPercentage
from CovidPortfoliioP..CovidDeaths
where location='Nepal'
--where total_cases not in (NULL)
order by 1,2,5 desc;

-- Which country(having more than a million residents) had the highest percentage of citizens infected by covid?

select location, max(total_cases) as HighestInfectionCount, population, max((total_cases)/population)*100 as CasesPercentage
from CovidPortfoliioP..CovidDeaths
where population > 1000000
group by location, population
order by 4 desc;

select location, max(total_cases) as HighestInfectionCount, population, max((total_cases)/population)*100 as CasesPercentage
from CovidPortfoliioP..CovidDeaths
group by location, population
order by 4 desc;

--Countries with highest death count
select location, max(total_deaths) as TotalDeathCount
from CovidPortfoliioP..CovidDeaths
where continent is not null
group by location
order by 2 desc

--Highest Death count By Continent
select continent, max(total_deaths) as TotalDeathCount
from CovidPortfoliioP..CovidDeaths
where continent is not null
group by continent
order by 2 desc


-- Finding countries with highest death rate per population
select location, max(total_deaths) as HighestDeathCount, population, max((total_deaths)/population)*100 as DeathPercent
from CovidPortfoliioP..CovidDeaths
group by location, population
order by 4 desc

-- Finding continents with highest death rate per population
select continent, max((total_deaths)/population)*100 as DeathPercent
from CovidPortfoliioP..CovidDeaths
where continent is not null
group by continent
order by 2 desc

--Global Number
--World daily covid cases
select date, sum(new_cases) as new_cases, sum(new_deaths)
from CovidPortfoliioP..CovidDeaths
where continent is not null
group by date
order by 1,2

--World daily covid deaths
select date, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, (sum(new_deaths)/sum(nullif(new_cases,0)))*100 as DeathPercentage
from CovidPortfoliioP..CovidDeaths
where continent is not null
group by date
order by 1,2

--Total Death %
select  sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, (sum(new_deaths)/sum(nullif(new_cases,0)))*100 as DeathPercentage
from CovidPortfoliioP..CovidDeaths
where continent is not null
order by 1,2

--Joining deaths and vaccination tables
select *
from CovidPortfoliioP..CovidDeaths dea
join CovidPortfoliioP..CovidVaccinations vac
	on dea.location = vac.location and dea.date=vac.date
	order by 3,4

-- Total Population vs Vaccination (Total number of people who got vaccination)
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidPortfoliioP..CovidDeaths dea
Join CovidPortfoliioP..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Without using Total_Vaccination column, we are going to find out the Total number of people vaccinated by location/country
--Rolling Count Column using Window Function

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
from CovidPortfoliioP..CovidDeaths dea
left join CovidPortfoliioP..CovidVaccinations vac
	on vac.location = dea.location and vac.date=dea.date
where dea.continent is not null
order by 2,3

--select * from CovidPortfoliioP..CovidVaccinations
--	where ROW_NUMBER() not in (select ROW_NUMBER()) from CovidPortfoliioP..CovidVaccinations)

