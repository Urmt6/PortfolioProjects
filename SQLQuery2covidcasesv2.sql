select *
From PortfoliProject.dbo.coviddeaths
Where continent is not null
order by 3,4

--select *
--From PortfoliProject.dbo.covidvaccinations
--order by 3,4

-- Select data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfoliProject.dbo.coviddeaths
Order by 1,2

-- Looking at total cases vs total deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100
From PortfoliProject.dbo.coviddeaths
Order by 1,2

-- kuna jagada ei sest nvarchar on invalid, siis konverdin  andmed floatiks, vaatame kas toimib.

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 as DeathPercentage
FROM PortfoliProject.dbo.coviddeaths
Where location = 'estonia'
ORDER BY 1,2;

-- Looking total caes vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 as PositivePercentage
FROM PortfoliProject.dbo.coviddeaths
Where location = 'estonia'
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to poulation

SELECT Location, MAX(total_cases) as HighestInfectioncount, population, MAX((CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)))*100 as PErcentagePopulationInfected
FROM PortfoliProject.dbo.coviddeaths
--Where location = 'estonia'
Group by Location,population
ORDER BY PErcentagePopulationInfected desc

-- testin mis on max total cases eestis
SELECT Location, MAX(total_cases)
FROM PortfoliProject.dbo.coviddeaths
Where location = 'estonia'
Group by location

SELECT Location, total_cases, date
FROM PortfoliProject.dbo.coviddeaths
Where location = 'estonia'
order by 2,3

-- Showing the countries with higest death count oer population

SELECT Location, MAX(cast(Total_deaths as int)) as totalDeathCount
FROM PortfoliProject.dbo.coviddeaths
--Where location = 'estonia'
Where continent is not null
Group by Location
ORDER BY totalDeathCount desc

SELECT Location, MAX(Total_deaths) as totalDeathCount
FROM PortfoliProject.dbo.coviddeaths
--Where location = 'estonia'
Group by Location
ORDER BY totalDeathCount desc

-- LETS BREAK DOWN BY CONTINENT
-- continendiga millegi pärast, tekib mingi viga, et north america all ei ole kanadat, statistika ei anna õiget üle vaadet, järgmises muudab select continendi ära locationiks tagasi
SELECT continent, MAX(cast(Total_deaths as int)) as totalDeathCount
FROM PortfoliProject.dbo.coviddeaths
--Where location = 'estonia'
Where continent is not null
Group by continent
ORDER BY totalDeathCount desc

-- not null panin nulliks, saime continendid kätte

SELECT location, MAX(cast(Total_deaths as int)) as totalDeathCount
FROM PortfoliProject.dbo.coviddeaths
--Where location = 'estonia'
Where continent is null
Group by location
ORDER BY totalDeathCount desc

-- showing continents with the highest death count per population
SELECT continent, MAX(cast(Total_deaths as int)) as totalDeathCount
FROM PortfoliProject.dbo.coviddeaths
--Where location = 'estonia'
Where continent is not null
Group by continent
ORDER BY totalDeathCount desc

-- Breaking global numbers

SELECT date, SUM(new_cases), SUM(cast(new_deaths as int)),SUM(cast(New_Deaths as int))/SUM(cast(New_Cases as int))*100 as DeathPercentage
FROM PortfoliProject.dbo.coviddeaths
--Where location = 'estonia'
where continent is not null
group by date
ORDER BY 1,2;
--surmade arv kokku %
SELECT  
       SUM(new_cases) as new_cases,
       SUM(new_deaths) as new_deaths,
       CASE WHEN SUM(New_Cases) = 0 THEN 0 ELSE SUM(New_Deaths)/NULLIF(SUM(New_Cases), 0)*100 END AS DeathPercentage
FROM PortfoliProject.dbo.coviddeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;


--looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
FRom PortfoliProject.dbo.coviddeaths dea
 join PortfoliProject.dbo.covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2,3;

 -- Use CTE, columns must be same number as the query

 With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
FRom PortfoliProject.dbo.coviddeaths dea
 join PortfoliProject.dbo.covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3;
 )
 --Select*
 --From PopvsVac

 Select*, (RollingPeopleVaccinated/Population)*100
 From PopvsVac

 --TEMP TABLE
 DROP Table if exists #PercentPopulationVaccinated
 Create table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
FRom PortfoliProject.dbo.coviddeaths dea
 join PortfoliProject.dbo.covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3;

 Select*, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated

 --Create view to store data for later visualizations
 Create View PercentPopulationVaccinated as
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
FRom PortfoliProject.dbo.coviddeaths dea
 join PortfoliProject.dbo.covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3;

 Select * 
 From PercentPopulationVaccinated