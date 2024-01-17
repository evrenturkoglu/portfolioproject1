--Select * from PortfolioProject.dbo.CovidDeaths
--order by 3,4

--Select * from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

Select location,date ,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--Looking at total cases vs total deaths

ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_cases float NULL; 

Select location,date ,total_cases,total_deaths,(total_deaths/total_cases)*100 as percentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
order by 1,2

Select continent, max(cast(total_deaths as int)) as totaldeath
from CovidDeaths
where trim(continent) is not null and continent != ''
Group by continent
order by totaldeath desc

with PopvsVac 
as 
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location,dea.date) Rollingsum
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent !=''
)
Select *, (Rollingsum/population)*100
from PopvsVac

Select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated;

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
RollingPeopleVaccinated float
)
insert into #PercentPopulationVaccinated
select dea.continent, 
       dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
       sum(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location,dea.date) Rollingsum
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent !='';
