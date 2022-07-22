SELECT *
FROM [Project Portfolio 1].dbo.CovidDeaths cd 
WHERE continent is not null
order by 3,4

--SELECT *
--FROM [Project Portfolio 1]..CovidVaccinations1
--order by 3,4


--select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM [Project Portfolio 1]..CovidDeaths
WHERE continent is not NULL 
order by 1

--total cases vs total deaths
--shows likelihood of dying if you contract covid in the respective country
Select location, date, total_cases, total_deaths, (total_deaths *1.0 / total_cases*1.0) * 100.0 as deathperc
FROM [Project Portfolio 1]..CovidDeaths
where location like '%Germany%'
WHERE continent is not NULL and continent <>''
order by 1

--looking at total cases vs population
--shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases *1.0 / population*1.0) * 100.0 as PercentPopulationInfected
FROM [Project Portfolio 1]..CovidDeaths
--where location like '%Germany%'
WHERE continent is not NULL 
order by 1

--countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases *1.0 / population*1.0)) * 100.0 as PercentPopulationInfected
FROM [Project Portfolio 1]..CovidDeaths
--where location like '%Germany%'
WHERE continent is not NULL 
Group by location, population
order by PercentPopulationInfected DESC

--countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [Project Portfolio 1]..CovidDeaths
--where location like '%Germany%'
WHERE continent is not NULL and continent <>''
Group by location
order by TotalDeathCount DESC

--Break down by continent
--showing the continents with highest death rate
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [Project Portfolio 1].dbo.CovidDeaths cd 
--where location like '%Germany%'
WHERE continent is not null and continent <>''
Group by continent 
order by TotalDeathCount DESC

--global numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathperc
FROM [Project Portfolio 1].dbo.CovidDeaths cd
--where location like '%Germany%'
WHERE continent is not NULL and continent <>''
GROUP BY [date]
order by 1,2

SELECT *
FROM [Project Portfolio 1].dbo.CovidDeaths dea 
Join [Project Portfolio 1].dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.[date] = vac.[date] 
	
--use CTE 
With PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
--looking at total population vs. vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Project Portfolio 1].dbo.CovidDeaths dea 
Join [Project Portfolio 1].dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.[date] = vac.[date] 
WHERE dea.continent is not NULL and dea.continent <>''
--order by 2,3	
)

SELECT * ,(RollingPeopleVaccinated)/(population)*100
From PopVsVac
order by 2

-- Temp TABLE 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population float,
New_vaccinations float,
RollingPeopleVaccinated float,
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Project Portfolio 1].dbo.CovidDeaths dea 
Join [Project Portfolio 1].dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.[date] = vac.[date] 
--WHERE dea.continent is not NULL and dea.continent <>''
--order by 2,3	

SELECT * ,(RollingPeopleVaccinated)/(population)*100
From #PercentPopulationVaccinated
order by 2

--create view for later data visualization
Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [Project Portfolio 1].dbo.CovidDeaths dea 
Join [Project Portfolio 1].dbo.CovidVaccinations vac
	on dea.location = vac.location 
	and dea.[date] = vac.[date] 
WHERE dea.continent is not NULL and dea.continent <>''
--order by 2,3

