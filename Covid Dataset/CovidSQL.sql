SELECT * FROM CovidDeaths WHERE continent is NOT NULL ORDER BY 3,4

SELECT * FROM CovidVaccinations ORDER BY 3,4

--Select Data that i'm using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like 'EG%' AND continent is NOT NULL
ORDER BY 1,2

--Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM CovidDeaths
WHERE location like 'EG%' AND continent is NOT NULL
ORDER BY 1,2

-- Countries with Highest Infection Rate vs Population (Tableau 3)

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PrecentPopulationInfected
FROM CovidDeaths
--WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY PrecentPopulationInfected DESC

-- Countries with Highest Infection Rate vs Population by Date(Tableau 4)

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PrecentPopulationInfected
FROM CovidDeaths
--WHERE continent is NOT NULL
GROUP BY location, population, date
ORDER BY PrecentPopulationInfected DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Continents with Highest Infection Rate vs Population

SELECT continent, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as MAXInfectionPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY MAXInfectionPercentage DESC

-- Global Numbers per day

SELECT date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

-- Global Numbers (Tableau 1)

SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2


--Continents with Highest Death Rate (Tableau 2)

SELECT location, SUM(cast(new_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is NULL AND location NOT IN ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

--Tableau 3



-- Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as SUMofVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVac
AS
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as SUMofVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *,(SUMofVaccinations/population)*100 as VaccinatedPercentage FROM popvsvac


--Temp Table

CREATE TABLE #PernectPOpulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccination numeric,
SUMofVaccinations numeric)

INSERT INTO #PernectPOpulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as SUMofVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT *,(SUMofVaccinations/population)*100 as VaccinatedPercentage FROM #PernectPOpulationVaccinated ORDER BY 2,3


--Create View to store data for later Visualization

CREATE VIEW PernectPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as SUMofVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL

SELECT * FROM PernectPopulationVaccinated