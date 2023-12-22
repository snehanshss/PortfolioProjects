SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [Portfolio_Project_1].[dbo].['CovidDeaths']
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking for total Cases and total Deaths
--Shows the likelyhood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths, (CONVERT (float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM [Portfolio_Project_1].[dbo].['CovidDeaths']
WHERE continent IS NOT NULL
ORDER BY 1,2

--Lookin at Total Cases vs Populations

SELECT location,date,total_cases,population, (CONVERT (float,total_cases)/NULLIF(CONVERT(float,population),0))*100 AS PercentagePopulationInfected
FROM [Portfolio_Project_1].[dbo].['CovidDeaths']
WHERE continent IS NOT NULL 
and location like'%India%'
ORDER BY 1,2


--Looking at countires with Highest Infection rate compared to Population

SELECT location,population, MAX(total_cases) as HidhestInfectionCount,MAX ((CONVERT (float,total_cases)/NULLIF(CONVERT(float,population),0)))*100 AS PercentagePopulationInfected
FROM [Portfolio_Project_1].[dbo].['CovidDeaths']
WHERE continent IS NOT NULL
and location LIKE '%India%'
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC

-- Showing Countries where Highest Death Count Per Population

SELECT location,  MAX (CAST (total_deaths as int) )  As TotalDeathCount
FROM [Portfolio_Project_1].[dbo].['CovidDeaths']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC 

--Lets break things down by continent

--Showing the contitent with Higest Death Count per population

SELECT Continent,  MAX (CAST (total_deaths as int) )  As TotalDeathCount
FROM [Portfolio_Project_1].[dbo].['CovidDeaths']
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC 

--Global Numbers

SELECT  SUM (new_cases) AS total_cases, SUM (CAST(new_deaths as int)) AS total_Deaths, SUM(CAST(new_deaths as int))/NULLIF (SUM(new_cases),0)*100 AS DeathPercentage
FROM [Portfolio_Project_1].[dbo].['CovidDeaths']
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking for Total Population and Vaccinations
--Shows Percentage of Population that has received atleast one Covid Vaccine 

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM (CONVERT (bigint,vac.new_vaccinations)) OVER (PARTITION by dea.Location Order BY dea.location,dea.date) AS RollingPeopleVaccinated,
 --(RollingPeopleVaccinated/population)*100

FROM [Portfolio_Project_1].[dbo].['CovidDeaths'] as dea
    JOIN [Portfolio_Project_1].[dbo].['CovidVacinations'] as vac
	  ON dea.location = vac.location
	  and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY  2,3


-- Using CTE to preform Calculations on Partition By in previous query 

WITH PopvsVac (Continent, location,date, population, New_Vaccinations, RollingPeopleVaccinated)  
as 
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM (CONVERT (bigint,vac.new_vaccinations)) OVER (PARTITION by dea.Location Order BY dea.location,dea.date) AS RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM [Portfolio_Project_1].[dbo].['CovidDeaths'] as dea
    JOIN [Portfolio_Project_1].[dbo].['CovidVacinations'] as vac
	  ON dea.location = vac.location
	  and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY  2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Using Temp Table to perform Calculation on Partition By in previous query
 
DROP TABLE IF EXISTS #PrecentPopulationVaccinated 
CREATE TABLE #PrecentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PrecentPopulationVaccinated 
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM (CONVERT (bigint,vac.new_vaccinations)) OVER (PARTITION by dea.Location Order BY dea.location,dea.date) AS RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM [Portfolio_Project_1].[dbo].['CovidDeaths'] as dea
    JOIN [Portfolio_Project_1].[dbo].['CovidVacinations'] as vac
	  ON dea.location = vac.location
	  and dea.date = vac.date 
--WHERE dea.continent IS NOT NULL
--ORDER BY  2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PrecentPopulationVaccinated 


-- Creating View to store data for later visualizations

CREATE VIEW  PrecentPopulationVaccinated as 
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, SUM (CONVERT (bigint,vac.new_vaccinations)) OVER (PARTITION by dea.Location Order BY dea.location,dea.date) AS RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM [Portfolio_Project_1].[dbo].['CovidDeaths'] as dea
    JOIN [Portfolio_Project_1].[dbo].['CovidVacinations'] as vac
	  ON dea.location = vac.location
	  and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY  2,3

SELECT *
FROM PrecentPopulationVaccinated