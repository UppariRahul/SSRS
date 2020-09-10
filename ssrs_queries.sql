-- MODULE : B9DA102 Data Storage Solutions for Data Analytics
-- GROUP B (Slot 4)

-- Subramaniam Kazhuparambil (10524303)
-- Rahul Ramchandra Uppari (10523807)
-- Deeksha Sharma (10522688) 
-- Mohit Singh (10525046)
-- QUERIES for creating SSRS reports --

-- SSRS Driver-At-Fault Report --

SELECT Year(CarCrashDate_Dim.CrashDate), Driver_Dim.DriverAtFault, COUNT(CrashAnalysis_Fact.PersonKey)
FROM CarCrashDate_Dim 
INNER JOIN CrashAnalysis_Fact ON CarCrashDate_Dim.CarCrashDateKey = CrashAnalysis_Fact.CarCrashDateKey 
INNER JOIN Driver_Dim ON CrashAnalysis_Fact.PersonKey = Driver_Dim.PersonKey
GROUP BY YEAR(CarCrashDate_Dim.CrashDate), Driver_Dim.DriverAtFault
ORDER BY YEAR(CarCrashDate_Dim.CrashDate), COUNT(CrashAnalysis_Fact.PersonKey)
GO

-- SSRS Weather Report --

SELECT MONTH(CarCrashDate_Dim.CrashDate) AS MONTH, CrashConditions_Dim.Weather,
COUNT(CrashAnalysis_Fact.PersonKey) AS CaseCount, CASE
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '1' THEN 'January'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '2' THEN 'February'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '3' THEN 'March'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '4' THEN 'April'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '5' THEN 'May'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '6' THEN 'June'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '7' THEN 'July'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '8' THEN 'August'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '9' THEN 'September'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '10' THEN 'October'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '11' THEN 'November'
WHEN CONVERT(VARCHAR,  MONTH(CarCrashDate_Dim.CrashDate), 10) = '12' THEN 'December'
END AS MONTH_
FROM CrashConditions_Dim 
INNER JOIN CrashAnalysis_Fact ON CrashConditions_Dim.CrashConditionsKey = CrashAnalysis_Fact.CrashConditionsKey
INNER JOIN CarCrashDate_Dim ON CrashAnalysis_Fact.CarCrashDateKey = CarCrashDate_Dim.CarCrashDateKey
GROUP BY MONTH(CarCrashDate_Dim.CrashDate),CrashConditions_Dim.Weather
ORDER BY MONTH(CarCrashDate_Dim.CrashDate)
GO

-- SSRS Time Report --

SELECT YEAR(CarCrashDate_Dim.CrashDate) AS YEAR, CASE
WHEN CONVERT(VARCHAR, CrashAnalysis_Fact.TimeOfDay, 8) between '00:00:00' and '06:00:00' THEN 'Night (Midnight to 6am)'
 WHEN CONVERT(VARCHAR, CrashAnalysis_Fact.TimeOfDay, 8) between '06:00:01' and '12:00:00' THEN 'Morning (6am - 12 noon)' 
  WHEN CONVERT(VARCHAR, CrashAnalysis_Fact.TimeOfDay, 8) between '12:00:01' and '18:00:00' THEN 'Afternoon (12 noon - 6pm)' 
   when convert(VARCHAR, CrashAnalysis_Fact.TimeOfDay, 8) between '18:00:01' and '23:59:59' THEN 'Evening (6pm - Midnight)'
END AS Crash, COUNT(CaseKey) AS CaseCount
FROM CarCrashDate_Dim INNER JOIN CrashAnalysis_Fact ON CarCrashDate_Dim.CarCrashDateKey = CrashAnalysis_Fact.CarCrashDateKey
GROUP BY YEAR(CarCrashDate_Dim.CrashDate), CASE
WHEN CONVERT(VARCHAR, CrashAnalysis_Fact.TimeOfDay, 8) between '00:00:00' and '06:00:00' THEN 'Night (Midnight to 6am)'
 WHEN CONVERT(VARCHAR, CrashAnalysis_Fact.TimeOfDay, 8) between '06:00:01' and '12:00:00' THEN 'Morning (6am - 12 noon)' 
  WHEN CONVERT(VARCHAR, CrashAnalysis_Fact.TimeOfDay, 8) between '12:00:01' and '18:00:00' THEN 'Afternoon (12 noon - 6pm)' 
   when convert(VARCHAR, CrashAnalysis_Fact.TimeOfDay, 8) between '18:00:01' and '23:59:59' THEN 'Evening (6pm - Midnight)'
END
ORDER BY YEAR
GO

-- SSRS Year-Monthly % CHANGE REPORT --

SELECT CrashYear1, CrashMonth1, CaseCount1,
CASE
	WHEN CAST(ROUND(CAST((CaseCount1 - CaseCount2) AS FLOAT)/CAST(CaseCount2 AS FLOAT), 2)*100 AS VARCHAR(10)) IS NOT NULL
	THEN CONCAT(CAST(ROUND(CAST((CaseCount1 - CaseCount2) AS FLOAT)/CAST(CaseCount2 AS FLOAT), 2)*100 AS VARCHAR(10)), '%')
	ELSE 'N/A'
END AS '% Change in No. Of Crashes'
FROM
	(SELECT CAST(CarCrashDate_Dim.Year_ AS INT) AS CrashYear1,
			MONTH(CarCrashDate_Dim.CrashDate) AS CrashMonth1,
			COUNT(CrashAnalysis_Fact.CaseKey) AS CaseCount1
			FROM CarCrashDate_Dim 
			INNER JOIN CrashAnalysis_Fact ON CrashAnalysis_Fact.CarCrashDateKey = CarCrashDate_Dim.CarCrashDateKey
			GROUP BY CarCrashDate_Dim.Year_, MONTH(CarCrashDate_Dim.CrashDate)
	) Obj1
LEFT OUTER JOIN
	( SELECT CAST(CarCrashDate_Dim.Year_ AS INT) + 1 AS CrashYear2,
			MONTH(CarCrashDate_Dim.CrashDate) AS CrashMonth2,
			COUNT(CrashAnalysis_Fact.CaseKey) AS CaseCount2
			FROM CarCrashDate_Dim 
			INNER JOIN CrashAnalysis_Fact ON CrashAnalysis_Fact.CarCrashDateKey = CarCrashDate_Dim.CarCrashDateKey
			GROUP BY CarCrashDate_Dim.Year_, MONTH(CarCrashDate_Dim.CrashDate)
	) Obj2
ON Obj1.CrashYear1 = Obj2.CrashYear2
AND Obj1.CrashMonth1 = Obj2.CrashMonth2
ORDER BY CrashYear1, CrashMonth1
GO

