# 🚗 Electric Vehicle Analytics using SQL

![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)
![Contributions](https://img.shields.io/badge/Contributions-Welcome-brightgreen?style=for-the-badge)

[![GitHub Stars](https://img.shields.io/github/stars/yourusername/ev-analytics-sql?style=social)](https://github.com/yourusername/ev-analytics-sql)
[![GitHub Forks](https://img.shields.io/github/forks/yourusername/ev-analytics-sql?style=social)](https://github.com/yourusername/ev-analytics-sql)
[![LinkedIn](https://img.shields.io/badge/Connect-LinkedIn-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/yourprofile)

## 📌 Project Overview

This project focuses on analyzing **Electric Vehicle (EV) data** using **advanced SQL techniques** to uncover insights related to **performance, cost efficiency, environmental impact, and ownership economics**.

The project is designed to simulate **real-world, MNC-level SQL interview problems**, emphasizing analytical thinking over simple query writing.

---

## 🛠 Tools & Technologies

- **Database:** MySQL  
- **Language:** SQL  
- **Techniques Used:**
  - JOINs
  - CTEs (WITH clause)
  - Subqueries
  - Window Functions (`RANK`)
  - Aggregations (`SUM`, `AVG`)
  - Conditional logic (`CASE WHEN`)
  - Statistical functions (`STDDEV`)

---

## 🗂 Database Setup

```sql
CREATE DATABASE electric_vehicle_db;
USE electric_vehicle_db;

CREATE DATABASE EV_ANALYTICS;
USE EV_ANALYTICS;
```

---

## 📋 Table Schema

### ELECTRIC_VEHICLES

```sql
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
```

### 🔍 Sample Query

```sql
SELECT * FROM electric_vehicles;
```

---

## 📊 Business Questions & SQL Solutions

### Q1. Top 5 EV models with highest range efficiency

```sql
SELECT
    make,
    model,
    ROUND(AVG(Range_km / Battery_Capacity_kWh), 2) AS Avg_Range_per_kWh
FROM electric_vehicles
GROUP BY make, model
ORDER BY Avg_Range_per_kWh DESC
LIMIT 5;
```

---

### Q2. Region-wise CO₂ savings analysis

```sql
SELECT 
    region,
    make,
    model,
    ROUND(AVG(CO2_Saved_tons), 2) AS CO2_Saved,
    ROUND(AVG(Temperature_C)) AS Avg_Temperature
FROM electric_vehicles
GROUP BY region, make, model
ORDER BY region, CO2_Saved DESC;
```

---

### Q3. Correlation between battery health and mileage

```sql
SELECT 
    ROUND(
        (
            (AVG(Battery_Health_Percent * Mileage_km) 
            - (AVG(Battery_Health_Percent) * AVG(Mileage_km)))
            /
            (STDDEV(Battery_Health_Percent) * STDDEV(Mileage_km))
        ), 3
    ) AS Battery_Mileage_Correlation
FROM electric_vehicles;
```

---

### Q4. Vehicles with resale value above regional average

```sql
WITH cte_avg_resale_value AS (
    SELECT 
        region,
        make,
        model,
        year,
        Resale_Value_USD AS resale_value,
        ROUND(AVG(Resale_Value_USD) OVER(PARTITION BY region), 2) AS region_avg_resale_value
    FROM electric_vehicles
)
SELECT *
FROM cte_avg_resale_value
WHERE resale_value > region_avg_resale_value
ORDER BY region, resale_value DESC;
```

---

### Q5. Charging cost comparison (Personal vs Commercial)

```sql
SELECT 
    ROUND(AVG(CASE WHEN Usage_Type = 'Personal' THEN Monthly_Charging_Cost_USD END), 2) AS Personal_Avg_Cost,
    ROUND(AVG(CASE WHEN Usage_Type = 'Commercial' THEN Monthly_Charging_Cost_USD END), 2) AS Commercial_Avg_Cost
FROM electric_vehicles;
```

---

### Q6. Lowest maintenance cost per kilometer

```sql
SELECT 
    make,
    ROUND(SUM(Maintenance_Cost_USD) / SUM(Mileage_km), 4) AS Avg_Maintenance_Cost_per_km
FROM electric_vehicles
GROUP BY make
ORDER BY Avg_Maintenance_Cost_per_km
LIMIT 1;
```

---

### Q7. Top 3 fastest vehicle types by region

```sql
WITH cte_acc AS (
    SELECT
        region,
        vehicle_type,
        ROUND(AVG(Acceleration_0_100_kmh_sec), 2) AS Avg_Acceleration,
        RANK() OVER(PARTITION BY region ORDER BY AVG(Acceleration_0_100_kmh_sec)) AS Rnk
    FROM electric_vehicles
    GROUP BY region, vehicle_type
)
SELECT *
FROM cte_acc
WHERE Rnk <= 3;
```

---

### Q8. Best manufacturing year (range vs battery health)

```sql
SELECT 
    year,
    ROUND(AVG(Range_km), 2) AS Avg_Range,
    ROUND(AVG(Battery_Health_Percent), 2) AS Avg_Battery_Health,
    ROUND(AVG(Range_km) / AVG(Battery_Health_Percent), 2) AS Range_to_Battery_Index
FROM electric_vehicles
GROUP BY year
ORDER BY Range_to_Battery_Index DESC
LIMIT 1;
```

---

### Q9. Detect charging cost inconsistencies

```sql
SELECT
    make,
    model,
    ROUND(AVG(Charging_Power_kW) / AVG(Charging_Time_hr), 2) AS Calculated_Electricity_Cost,
    ROUND(AVG(Monthly_Charging_Cost_USD), 2) AS Monthly_Charging_Cost,
    ROUND(
        AVG(Monthly_Charging_Cost_USD) 
        - (AVG(Charging_Power_kW) / AVG(Charging_Time_hr)), 
        2
    ) AS Inconsistency
FROM electric_vehicles
GROUP BY make, model
ORDER BY Inconsistency DESC;
```

---

### Q10. Rank vehicle models by total ownership cost

```sql
SELECT
    make,
    model,
    SUM(Maintenance_Cost_USD + Insurance_Cost_USD + Monthly_Charging_Cost_USD) AS Total_Ownership_Cost,
    RANK() OVER (
        ORDER BY SUM(Maintenance_Cost_USD + Insurance_Cost_USD + Monthly_Charging_Cost_USD)
    ) AS Rnk
FROM electric_vehicles
GROUP BY make, model;
```

---

## 📈 Key Insights

- EV efficiency differs significantly across models
- Some regions deliver higher environmental benefits
- Better battery health improves resale value
- Commercial EVs have higher operating costs
- Ownership cost ranking helps identify economical models

---

## 🎯 Learning Outcomes

- Solved real-world business problems using SQL
- Applied advanced SQL concepts confidently
- Built an interview-ready analytics project
- Strengthened data-driven thinking

---

## 📌 Author

**Suman Saha**  
Aspiring Data Analyst | SQL | Excel | Power BI

---

## 📝 License

This project is open source and available for educational purposes.

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

---

## ⭐ Show your support

Give a ⭐️ if this project helped you!
