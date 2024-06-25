---Data has been imported from our device in the SQL Studio

select * from CovidDeath
order by 3, 4


select * from Covidvaccin

order by 3,4

--Percentage people likely of dying of covid in each country
	select Location, date, total_cases, total_deaths,
	CASE 
		when total_cases = 0 then  0
		else (cast (total_deaths as float ) / cast(total_cases as float))*100  
		end as Death_Percentage
	from CovidDeath
	where location like '%Nigeria%'
	order by 1,2


--Total cases vs total population

	select Location, date, total_cases, population,
	CASE 
		when total_cases = 0 then  0
		else (cast (total_cases as float ) / cast(population as float))*100  
		end as Percentage_population
	from CovidDeath
	where location like '%Nigeria%'
	order by 1,2


--Country with highest infected count

	select Location, population, Max(total_cases) as Highest_infection_count,
	CASE 
		when total_cases = 0 then  0
		else MAX(cast (total_cases as float) / cast(population as float))*100  
		end as Percentage_Population_infected
	from CovidDeath
	GROUP by location, population, total_cases
	order by Percentage_Population_infected desc


--checking highest death count in all location

	select location, Max(cast(total_deaths as int)) as Total_deathRate
	from CovidDeath where continent is not null
	GROUP by location 
	order by Total_deathRate desc


----checking highest death count in all continent/globally

	select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as 
	total_deaths, sum(cast(new_deaths as int))/sum(New_cases)*100 as death_percentage
	from CovidDeath where continent is null 
	order by 1,2

---Viewing the total number of Population that are vaccinated.. Pop vs Total_Vaccination
	
	select death.continent, death.location, death.date,
	death.population, vaccin.new_vaccinations
	from CovidDeath death
	join Covidvaccin vaccin
	on death.location = vaccin.location and 
	death.date = vaccin.date 
	where death.continent is not null
	order by 2,3

---Using partition to check the sum new vacination in each country per day adding each day like rolling count	
	select death.continent, death.location, death.date,
	death.population, vaccin.new_vaccinations, sum(Convert(bigint, new_vaccinations))
	over (partition by death.location order by death.location, death.date) as RollinPeopleVaccin	
	from CovidDeath death
	join Covidvaccin vaccin
	on death.location = vaccin.location and 
	death.date = vaccin.date 
	where death.continent is not null
	order by 2,3


	--using CTEto divide rollingPeopleVaccin by population * 100 to get the number of people actually vaccinated


	With Poplvs_Vaccin (continent, Location, Date, Population, new_vaccinations, RollinPeopleVaccin) 
	as
	(
	select death.continent, death.location, death.date,
	death.population, vaccin.new_vaccinations, sum(cast(new_vaccinations as bigint))
	over (partition by death.location order by death.location, death.date) as RollinPeopleVaccin	
	from CovidDeath death
	join Covidvaccin vaccin
	on death.location = vaccin.location and 
	death.date = vaccin.date 
	where death.continent is not null)

	select * ,(RollinPeopleVaccin/Population)*100
	from Poplvs_Vaccin

---Using temp_table


	Drop Table if exists #percentagePop_vaccinated
---the drop table was added just incase u you want edit a column from the temp_table and recreate it

	Create Table #percentagePop_vaccinated
	(
	Continent nvarchar (255),
	location nvarchar (255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollinPeopleVaccin numeric
	)

	insert into #percentagePop_vaccinated
	select death.continent, death.location, death.date,
	death.population, vaccin.new_vaccinations, sum(cast(new_vaccinations as bigint))
	over (partition by death.location order by death.location, death.date) as RollinPeopleVaccin	
	from CovidDeath death
	join Covidvaccin vaccin
	on death.location = vaccin.location and 
	death.date = vaccin.date 
	where death.continent is not null

	select * ,(RollinPeopleVaccin/Population)*100
	from #percentagePop_vaccinated

-----Creating views to store the Data for visualization

	Create View Percent_Population_Vaccinated as
	select death.continent, death.location, death.date,
	death.population, vaccin.new_vaccinations, sum(cast(new_vaccinations as bigint))
	over (partition by death.location order by death.location, death.date) as RollinPeopleVaccin	
	from CovidDeath death
	join Covidvaccin vaccin
	on death.location = vaccin.location and 
	death.date = vaccin.date 
	where death.continent is not null


select * from Percent_Population_Vaccinated


-----Creating views for highest death count Globally

	Create View GLobal_deathCount as 
	select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as 
	total_deaths, sum(cast(new_deaths as int))/sum(New_cases)*100 as death_percentage
	from CovidDeath where continent is null 
	
select * from GLobal_deathCount


--checking views for highest death count in all location
	create view Death_countPer_location as
	select location, Max(cast(total_deaths as int)) as Total_deathRate
	from CovidDeath where continent is not null
	GROUP by location 

select * from Death_countPer_location
	
