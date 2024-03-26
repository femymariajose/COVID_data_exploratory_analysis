SELECT *
  FROM CovidDeaths

--Select the data
  Select  location, date, total_cases, new_cases, total_deaths, population from CovidDeaths 
  where continent is not null


  --Total Cases vs Total Deaths
    Select  location, date, total_cases, total_deaths,
	(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage from CovidDeaths
	where continent is not null
  order by 1,2

  --Death Rate if you contract covid in your country
  Select continent, location, date, total_cases, total_deaths, 
  (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage from CovidDeaths
  where location like '%canada%' and continent is not null
  order by 1,2

  --Percentage of population who got covid
  Select  location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected from CovidDeaths
  where location like '%canada%' and continent is not null
  order by 1,2

  --Countries with highest infection rates compared to population
   Select  location, population, max(total_cases)as HighestInfectionCount, max((total_cases/population))*100 as 
   PercentPopulationInfected from CovidDeaths
   where continent is not null
 group by location, population 
  order by PercentPopulationInfected desc

  --Showing countries wth highest death count per population
  Select  location, max(total_deaths)as TotalDeathCount from CovidDeaths
  where continent is not null
 group by location
  order by TotalDeathCount desc

  --Continent with highest death count per population
  Select  continent, max(total_deaths)as TotalDeathCount from CovidDeaths
  where continent is not null
 group by continent
  order by TotalDeathCount desc

  --Global Numbers
    Select --date,
 sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
 (SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)))*100 as DeathPercentage
 from CovidDeaths
  where continent is not null
  --group by date
  order by 1,2

  --Total population vs Vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as PeopleVaccinated
from CovidDeaths dea join CovidVaccination vac on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not null
  order by 1,2,3

  --Using CTE

  With PopulationVsVaccination (Population, date, Continent, Location, new_vaccinations, PeopleVaccinated)
  as
  (
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as PeopleVaccinated
from CovidDeaths dea join CovidVaccination vac on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
  Select *
  ,(PeopleVaccinated/population)*100
  from PopulationVsVaccination

--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as PeopleVaccinated
from CovidDeaths dea join CovidVaccination vac on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  
  Select *
  ,(PeopleVaccinated/population)*100
  from #PercentPopulationVaccinated

  --Creating view to store data
Create view PercentPopulationVaccinated as   
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) 
as PeopleVaccinated
from CovidDeaths dea join CovidVaccination vac on dea.location = vac.location 
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
Select * from PercentPopulationVaccinated