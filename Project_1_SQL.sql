select *
from covid_vaccinations;

# converting the the data type of date from text to varchar(255)
alter table covid_vaccinations
modify date varchar(255);

# converting the date type from string to date and from "dd-mm-yyyy" to "yyyy-mm-dd"
update covid_vaccinations
set date=str_to_date(date,"%d-%m-%Y");


SELECT *
FROM covid_deaths
WHERE length(continent) != 0
ORDER BY 3,4;

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM covid_deaths
Where location = 'india' AND length(continent) != 0
ORDER BY 1,2;

-- Looking at Total cases V/S Total deaths
-- Shows Likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 as Death_percentage
FROM covid_deaths
WHERE length(continent) != 0
ORDER BY 1,2;

-- Looking at Total Cases V/S Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 as Infected_Percentage
FROM covid_deaths
WHERE length(continent) != 0
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases/population)) * 100 as Infected_Percentage
FROM covid_deaths
WHERE length(continent) != 0
GROUP BY location, population
ORDER BY 4 DESC;

-- Showing Countries with Highest Death Count per Population
SELECT location, population, MAX(total_deaths) AS Total_death_count
FROM covid_deaths
WHERE length(continent) != 0
GROUP BY location,population
ORDER BY Total_death_count desc;

-- "Showing the continent with the highest death count - I tried by selecting continent but seems like 
-- the data is a little messed up so the majority of the data was wrongly entered in the location column"
SELECT location, MAX(total_deaths) AS Total_death_count
FROM covid_deaths
WHERE length(continent) = 0
GROUP BY location
ORDER BY Total_death_count desc;	

-- By Continent
SELECT continent, MAX(total_deaths) AS Total_death_count
FROM covid_deaths
WHERE length(continent) != 0
GROUP BY continent
ORDER BY Total_death_count desc;


-- Global Numbers
SELECT date,SUM(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, sum(new_deaths)/sum(new_cases)*100 As
death_percentage
from covid_deaths
WHERE length(continent) != 0
group by date
order by 1,2;


-- Looking at total population vs Vaccinations 

With PopvsVac as
# We created a (CTE) common table expression PopsVac
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(vac.new_vaccinations) over ( partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
WHERE length(dea.continent) != 0
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated_percentage
From Popvsvac;


-- Percentage of of People Vaccinated with the Temporary table method
# Temp Table
Drop Table if exists PercPopulationVaccinated;
Create temporary Table PercPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
RollingPeopleVaccinated numeric
);


Insert into PercPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, Population,
sum(vac.new_vaccinations) over ( partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
WHERE length(dea.continent) != 0;
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinated_percentage
From PercPopulationVaccinated;

-- Creating view to store for Later Vizualizations
CREATE VIEW	PercPopulationVaccinated AS
(SELECT dea.continent, dea.location, dea.date, Population,
sum(vac.new_vaccinations) over ( partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid_deaths dea
join covid_vaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
WHERE length(dea.continent) != 0);

