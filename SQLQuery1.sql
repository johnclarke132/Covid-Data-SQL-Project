-- View CovidDeaths Data
SELECT Location, date, total_cases, new_cases, total_deaths, population
	FROM [Covid Data SQL Project]..CovidDeaths$
	-- Ommit grouped and class data
	WHERE continent IS NOT NULL
	ORDER BY 1,2

-- View CovidVaccinations Data
 SELECT * 
 	FROM [Covid Data SQL Project]..CovidVaccinations$
	WHERE continent IS NOT NULL

-- Mortality rate by day (Total Cases vs Total Deaths)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Percentage
	FROM [Covid Data SQL Project]..CovidDeaths$
	WHERE continent IS NOT NULL
	ORDER BY 1,2

-- Mortality rate by day - UK (Total Cases vs Total Deaths)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Percentage
	FROM [Covid Data SQL Project]..CovidDeaths$
	WHERE Location='United Kingdom'
	ORDER BY 1,2

-- % Total infections - UK (Total Cases vs Population)
SELECT Location, date, population, total_cases, (total_cases/population) * 100 AS Percentage
	FROM [Covid Data SQL Project]..CovidDeaths$
	WHERE Location='United Kingdom'
	ORDER BY 1,2

-- Countries with highest total infection rate (Infection rate vs Population)
SELECT Location, population, MAX(total_cases) AS InfectionCount, MAX((total_cases/population)) * 100 AS Percentage
	FROM [Covid Data SQL Project]..CovidDeaths$
	WHERE continent IS NOT NULL
	GROUP BY location, population
	ORDER BY Percentage DESC

-- Total death count by country
SELECT Location, MAX(cast(total_deaths as int)) AS DeathCount
	FROM [Covid Data SQL Project]..CovidDeaths$
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY DeathCount DESC

-- Death count by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS DeathCount
	FROM [Covid Data SQL Project]..CovidDeaths$
	WHERE continent IS NOT NULL
	GROUP BY continent
	ORDER BY DeathCount DESC

-- Global numbers by day
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(total_deaths AS int)) AS TotalDeaths
	FROM [Covid Data SQL Project]..CovidDeaths$
	WHERE continent IS NOT NULL
	GROUP BY date
	ORDER BY date 

-- Total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
	FROM [Covid Data SQL Project]..CovidDeaths$ dea
	JOIN [Covid Data SQL Project]..CovidVaccinations$ vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	ORDER BY 1,2,3

-- Rolling vaccinations by day per country (CTE)

With RollingVaccinations (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM [Covid Data SQL Project]..CovidDeaths$ dea
JOIN [Covid Data SQL Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (TotalPeopleVaccinated/Population)*100 AS PercentagePeopleVaccinated
FROM RollingVaccinations


-- Rolling vaccinations by day per country (Temp table)
DROP TABLE IF exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM [Covid Data SQL Project]..CovidDeaths$ dea
JOIN [Covid Data SQL Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (TotalPeopleVaccinated/Population)*100
	FROM PercentPopulationVaccinated


-- Create view to store data
DROP VIEW PercentPopulationVaccinatedView 
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalPeopleVaccinated
FROM [Covid Data SQL Project]..CovidDeaths$ dea
JOIN [Covid Data SQL Project]..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
