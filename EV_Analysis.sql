-- Active: 1755582485257@@127.0.0.1@3306@electric_vehicle_db
CREATE DATABASE electric_vehicle_db;

USE electric_vehicle_db;

CREATE DATABASE EV_ANALYTICS;

USE EV_ANALYTICS;

CREATE TABLE ELECTRIC_VEHICLES (
    Vehicle_ID INT PRIMARY KEY,
    Make VARCHAR(50),
    Model VARCHAR(50),
    Year INT,
    Region VARCHAR(50),
    Vehicle_Type VARCHAR(50),
    Battery_Capacity_kWh DECIMAL(6,2),
    Battery_Health_Percent DECIMAL(5,2),
    Range_km DECIMAL(7,2),
    Charging_Power_kW DECIMAL(6,2),
    Charging_Time_hr DECIMAL(5,2),
    Charge_Cycles INT,
    Energy_Consumption_kWh_per_100km DECIMAL(6,2),
    Mileage_km INT,
    Avg_Speed_kmh DECIMAL(5,2),
    Max_Speed_kmh DECIMAL(5,2),
    Acceleration_0_100_kmh_sec DECIMAL(5,2),
    Temperature_C DECIMAL(5,2),
    Usage_Type VARCHAR(50),
    CO2_Saved_tons DECIMAL(6,2),
    Maintenance_Cost_USD DECIMAL(10,2),
    Insurance_Cost_USD DECIMAL(10,2),
    Electricity_Cost_USD_per_kWh DECIMAL(6,3),
    Monthly_Charging_Cost_USD DECIMAL(10,2),
    Resale_Value_USD DECIMAL(12,2)
);


SELECT * FROM electric_vehicles;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Q1. Find the top 5 electric vehicle models with the highest average range per kWh of battery capacity (range efficiency).
SELECT
    make,
    Model,
    ROUND(AVG(Range_km/Battery_Capacity_kWh),2) Avg_rng_per_kwh
FROM electric_vehicles
GROUP BY make, model
ORDER BY Avg_rng_per_kwh DESC
LIMIT 5;


-- Q2. Identify which region has the highest average CO2 savings per vehicle and analyze environmental impact by region.
SELECT 
    region,
    make,
    model,
    ROUND(AVG(CO2_Saved_tons),2) CO2_saved,
    ROUND(AVG(Temperature_C)) Avg_temp
FROM electric_vehicles
GROUP BY region,make,Model
ORDER BY region, CO2_saved DESC;


-- Q3. Determine the correlation between battery health percentage and total mileage driven for all vehicles.
SELECT 
    ROUND(
        (
            (AVG(Battery_Health_Percent * Mileage_km) - (AVG(Battery_Health_Percent) * AVG(Mileage_km)))
            /
            (STDDEV(Battery_Health_Percent) * STDDEV(Mileage_km))
        ), 3
    ) AS Battery_Mileage_Correlation
FROM electric_vehicles;


-- Q4. Find vehicles that have a resale value higher than their region’s average resale value.
WITH cte_avg_resale_value AS (
        SELECT 
            region,
            make,
            model,
            Year,
            Resale_Value_USD resale_value,
            ROUND(AVG(Resale_Value_USD) OVER(PARTITION BY region),2) region_avg_resale_value
        FROM electric_vehicles
)
SELECT
    region,
    make,
    model,
    year,
    resale_value,
    region_avg_resale_value
FROM cte_avg_resale_value
WHERE resale_value > region_avg_resale_value
ORDER BY region, resale_value DESC;


-- Q5. Compare the average monthly charging cost between personal and commercial usage types.
SELECT 
    ROUND(AVG(CASE WHEN Usage_Type = 'Personal' THEN Monthly_Charging_Cost_USD END), 2) AS Personal_Avg_Cost,
    ROUND(AVG(CASE WHEN Usage_Type = 'Commercial' THEN Monthly_Charging_Cost_USD END), 2) AS Commercial_Avg_Cost
FROM electric_vehicles;


-- Q6. Identify which vehicle make has the lowest average maintenance cost relative to mileage (cost per km).
SELECT 
    make,
    ROUND(SUM(Maintenance_Cost_USD) / SUM (mileage_km),4) Avg_Maintenance_cost_per_km
FROM electric_vehicles
GROUP BY make
ORDER BY Avg_Maintenance_cost_per_km
LIMIT 1;


-- Q7. Calculate the top 3 vehicle types with the fastest average acceleration (0–100 km/h) in each region.
WITH cte_acc AS (
SELECT
    region,
    Vehicle_type,
    ROUND(AVG(Acceleration_0_100_kmh_sec),2) Avg_acc,
    RANK() OVER(PARTITION BY region ORDER BY AVG(Acceleration_0_100_kmh_sec) ASC) RNK
FROM electric_vehicles
GROUP BY region, Vehicle_Type
)
SELECT
    region,
    vehicle_type,
    Avg_acc,
    Rnk
FROM cte_acc
WHERE Rnk <= 3;
-- Q8. Find which year of manufacturing offers the best balance of range and battery health (highest combined index).
SELECT 
    year,
    ROUND(AVG(Range_km),2) avg_range,
    ROUND(AVG(Battery_Health_Percent),2) 'Avg_battery%',
    ROUND(
        AVG(Range_km) / AVG(Battery_Health_Percent),
        2) range_to_battery
FROM electric_vehicles
GROUP BY year
ORDER BY range_to_battery DESC
LIMIT 1;
-- Q9. Detect vehicles where the electricity cost per kWh and monthly charging cost are inconsistent.
SELECT
    make,
    model,
    ROUND(AVG(Charging_Power_kW) / AVG(Charging_Time_hr),2) electricity_cost,
    ROUND(AVG(Monthly_Charging_Cost_USD),2) monthly_charging_cost,
    ROUND(
        AVG(Monthly_Charging_Cost_USD) - (AVG(Charging_Power_kW) / AVG(Charging_Time_hr))
        ,2) inconsistent
FROM electric_vehicles
GROUP BY make, model
ORDER BY AVG(Monthly_Charging_Cost_USD) - (AVG(Charging_Power_kW) / AVG(Charging_Time_hr)) DESC; 

-- Q10. Rank all vehicle models by total ownership cost (Maintenance + Insurance + Monthly Charging) and identify the most economical models.

SELECT
    make,
    model,
    SUM(Maintenance_Cost_USD + Insurance_Cost_USD + Monthly_Charging_Cost_USD) total_ownership_cost,
    RANK() OVER(ORDER BY SUM(Maintenance_Cost_USD + Insurance_Cost_USD + Monthly_Charging_Cost_USD) ASC) Rnk
FROM electric_vehicles
GROUP BY make, model



