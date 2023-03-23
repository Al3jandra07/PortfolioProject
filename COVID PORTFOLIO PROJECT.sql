Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Selecionamos los datos que vamos a usar 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2 

--Vemos el Total de Casos vs Total de Muertes

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathsPercentage
From PortfolioProject..CovidDeaths
Where location like '%Costa Rica%' --Probabilidad de morir si contrae Covid en mi pais
order by 1,2 

--Vemos el Total de Casos vs Poblacion 
--Que porcentaje de la poblacion tuvo Covid

Select location, date, population, total_cases,(total_cases/population)*100 as DeathsPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Costa Rica%' solo de prueba
order by 1,2 

--Veamos los paises con la tasa más alta de infeccion en comparacion con la poblacion

Select location, population, MAX (total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 as PercenPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Costa Rica%' solo de prueba
Group by location, population
order by PercenPopulationInfected desc

--Showing countries with Highest Death count per population

Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount --se uso cast para convertirlo a un numero entero
From PortfolioProject..CovidDeaths
Where continent is not null -- para eliminar los continentes vacios
Group by location 
order by TotalDeathCount desc

--Dividido por continente 

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount --se uso cast para convertirlo a un numero entero
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathCount desc

--Continentes con el recuento de muertes más alto por poblacion
--podemos agregar cualquier consulta de las de arriba, pero cambiandolo a continente

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount --se uso cast para convertirlo a un numero entero
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- Looking at total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations
	, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated --CONVERT se puede usar igual que Cast para convertirlo a un numero entero
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
	

	-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated --Drop es para no eliminar la tabla temporal y poder hacerle cambios
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
From PercentPopulationVaccinated