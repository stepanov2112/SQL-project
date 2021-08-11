use test_database

select *
from test_database..Death
--where continent is not null
order by 3,4;


select location, date, total_cases, new_cases, total_deaths, population
from test_database..Death
order by 1,2

UPDATE test_database..Death
SET total_deaths = NULL 
WHERE total_deaths = ''

-- looking at total cases vs total deaths
--also show likelihood of dying if you contract covid in your contry
select location, date, total_cases, total_deaths, (convert(decimal(15,3),total_deaths) / total_cases)*100 as DeathPercantage
from test_database..Death
where location like 'Russia'
order by 1,2

--show percentage of population got covid
select location, date, population, total_cases,  (convert(decimal(15,3),total_cases) / population)*100 as InfectPercantage
from test_database..Death
where location like 'Russia'
order by 1,2

--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) TotalCasses,  max(cast(total_cases as float)) / population*100 as InfectPercantage
from test_database..Death
where cast(population as float) <> 0
group by location, population
order by 4 desc

--total cases in every country ordered from max to min
select location, max(cast(total_cases as float)) as TotalDeathCount
from test_database..Death
where continent <> ''
group by location
order by TotalDeathCount desc

--by continent
select location, max(cast(total_cases as float)) as TotalDeathCount
from test_database..Death
where continent = ''
group by location
order by TotalDeathCount desc

--by date
select date, sum(cast(new_cases as float)) as Total_Cases, sum(cast(new_deaths as float)) as Total_Deaths,
sum(cast(new_deaths as float)) / sum(cast(new_cases as float))*100 as DeathPercantage
from test_database..Death
where cast(new_cases as float) <> 0
group by date
order by 1

--looking at populations vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccination
FROM test_database..Death dea
JOIN test_database..vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''
ORDER BY 2,3

-- using CTE
WITH popVSvac (continent, location, date, population, new_vaccination, TotalVaccination)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccination
FROM test_database..Death dea
JOIN test_database..vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''
)
SELECT *, TotalVaccination/cast(population as float)* 100
FROM popVSvac
where cast(population as float) <> 0
order by 2,3

--creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date) as TotalVaccination
FROM test_database..Death dea
JOIN test_database..vaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''
