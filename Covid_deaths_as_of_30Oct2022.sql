SELECT * FROM `data-analysis-project-356709.CovidDataset.CovidDeaths` 
WHERE continent Is Not NULL
order by location, date;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths` 
WHERE continent Is Not NULL
ORDER BY 1,2;

-- Looing at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths`
where location like '%States' AND continent Is Not NULL
order by date;

-- Looing at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentagepopulationInfected
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths`
WHERE continent Is Not NULL
--where location like 'Austria'
order by location, date;

-- Looking at the countries wth highest Infection Rate compared to population

SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagepopulationInfected
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths`
WHERE continent Is Not NULL
group by location, population
order by PercentagepopulationInfected;

-- Looking at the countries with Highest Death Count per Population

SELECT location, max(total_deaths) as TotalDeathCount
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths`
WHERE continent Is Not NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

-- Let's break things down by continents
SELECT continent, max(total_deaths) as TotalDeathCount
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths`
WHERE continent Is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Showing the continent with highest death count per population

SELECT continent, max(total_deaths) as TotalDeathCount
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths`
WHERE continent Is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Total Global Numbers
SELECT sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases) as DeathPercentage
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths`
where continent Is Not NULL
order by 1,2;

-- Daily Global Numbers
SELECT date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases) as DeathPercentage
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths`
where continent Is Not NULL
GROUP BY date
order by 1,2;

-- Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 -- can not use a column created in the select statement. Use CTE or Temp table
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths` dea
JOIN`data-analysis-project-356709.CovidDataset.CovidVaccinations` vac
ON dea.location = vac.location and
  dea.date = vac.date
where dea.continent Is Not NULL
order by 2,3;

-- Use CTE
with PopvsVac 
as 
(
  SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 -- can not use a column created in the select statement. Use CTE or Temp table
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths` dea
JOIN`data-analysis-project-356709.CovidDataset.CovidVaccinations` vac
ON dea.location = vac.location and
  dea.date = vac.date
where dea.continent Is Not NULL
--order by 2,3;
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 as PercentagePopulationVaccinated
FROM PopvsVac;

-- Use Temp Table


CREATE Temp TABLE PercentagePopulationVaccinated
(
  Continent string,
  Location string,
  Date datetime,
  Population int64,
  New_vaccinations int64,
  RollingPopulatonVaccinated int64
);

INSERT INTO PercentagePopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 -- can not use a column created in the select statement. Use CTE or Temp table
FROM `data-analysis-project-356709.CovidDataset.CovidDeaths` dea
JOIN`data-analysis-project-356709.CovidDataset.CovidVaccinations` vac
ON dea.location = vac.location and
  dea.date = vac.date
where dea.continent Is Not NULL
--order by 2,3
;

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentagePopulationVaccinated;

