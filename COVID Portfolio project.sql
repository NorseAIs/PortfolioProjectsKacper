SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

-- Select data I will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Norway'
AND continent is not null
ORDER BY 1,2

-- Total cases vs Population
SELECT location, date, population, total_cases, (total_cases/population) * 100 as PercentagePopulationInfected
FROM CovidDeaths
--WHERE location = 'Norway'
ORDER BY 1,2

-- Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentagePopulationInfected
FROM CovidDeaths
--WHERE location = 'Norway'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--Countries with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'Norway'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'Norway'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC


--Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- CTE USE
With PopvsVac (Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated

-- Creating view to store data for visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

CREATE VIEW DeathPercentageNorway as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Norway'
AND continent is not null
--ORDER BY 1,2

CREATE VIEW PercentagePopulationInfected as
SELECT location, date, population, total_cases, (total_cases/population) * 100 as PercentagePopulationInfected
FROM CovidDeaths
--WHERE location = 'Norway'
--ORDER BY 1,2

CREATE VIEW TotalDeathCount as 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location = 'Norway'
WHERE continent is not null
GROUP BY continent
--ORDER BY TotalDeathCount DESC