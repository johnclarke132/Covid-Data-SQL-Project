-- View CovidDeaths Data
SELECT Location, date, total_cases, new_cases, total_deaths, population
	FROM [Covid Data SQL Project]..CovidDeaths$
	ORDER BY 1,2

-- View CovidVaccinations Data
 SELECT * 
 	FROM [Covid Data SQL Project]..CovidVaccinations$

-- Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Percentage
	FROM [Covid Data SQL Project]..CovidDeaths$
	ORDER BY 1,2
