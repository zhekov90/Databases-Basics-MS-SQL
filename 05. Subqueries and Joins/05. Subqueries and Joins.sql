
	--01. Employee Address

SELECT TOP(5) EmployeeID, JobTitle, e.AddressID, a.AddressText FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY e.AddressID


	--2.	Addresses with Towns

SELECT TOP(50) FirstName, LastName, t.[Name] AS Town, a.AddressText FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON t.TownID = a.TownID
ORDER BY FirstName, LastName


	--3.	Sales Employee

SELECT e.EmployeeID, e.FirstName, e.LastName, d.[Name] AS DepartmentName FROM Employees AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE d.Name = 'Sales'
ORDER BY e.EmployeeID


	--4.	Employee Departments

SELECT TOP(5) e.EmployeeID, e.FirstName, e.Salary, d.[Name] AS DepartmentName FROM Employees AS e
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID


	--5.	Employees Without Project

SELECT TOP(3) e.EmployeeID, e.FirstName FROM Employees AS e
 LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
WHERE ep.ProjectID IS NULL
ORDER BY e.EmployeeID


	--6.	Employees Hired After

SELECT FirstName, LastName, HireDate, d.[Name] AS DeptName FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE HireDate > '1999-01-01' AND d.[Name] IN ('Sales', 'Finance')
ORDER BY HireDate


	--7.	Employees with Project

SELECT TOP(5) e.EmployeeID, e.FirstName, p.[Name] AS ProjectName FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '2002-08-13' AND p.EndDate IS NULL
ORDER BY e.EmployeeID


	--8.	Employee 24

SELECT e.EmployeeID, e.FirstName, 
	CASE
		WHEN YEAR(p.StartDate) >= 2005
		THEN NULL
		ELSE p.[Name]
	END ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON p.ProjectID = ep.ProjectID
WHERE e.EmployeeID = 24


	--9.	Employee Manager

SELECT e.EmployeeID, e.FirstName, e.ManagerID, m.FirstName FROM Employees AS e
JOIN Employees AS m ON m.EmployeeID = e.ManagerID
WHERE e.ManagerID IN(3,7)
ORDER BY e.EmployeeID


	--10. Employee Summary

SELECT TOP(50) e.EmployeeID, 
	CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
	CONCAT(m.FirstName, ' ',  m.LastName) AS ManagerName,
	d.[Name] AS DepartmentName
FROM Employees AS e
JOIN Employees AS m ON m.EmployeeID = e.ManagerID
JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
ORDER BY e.EmployeeID


	--11. Min Average Salary

SELECT MIN(avg) AS [MinAverageSalary] FROM 
(
	SELECT AVG(Salary) AS [avg]
	FROM Employees
	GROUP BY DepartmentID
) AS AverageSalary


	--12. Highest Peaks in Bulgaria

SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation FROM Countries AS c
JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
JOIN Mountains AS m ON m.Id = mc.MountainId
JOIN Peaks AS p ON p.MountainId = m.Id
WHERE c.CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY p.Elevation DESC


	--13. Count Mountain Ranges

SELECT c.CountryCode, COUNT(m.MountainRange) AS [MountainRanges] FROM Countries AS c
JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
JOIN Mountains AS m ON m.Id = mc.MountainId
WHERE c.CountryCode IN ('US','RU','BG')
GROUP BY c.CountryCode


	--14. Countries with or without Rivers

SELECT TOP(5) c.CountryName, r.RiverName FROM Countries AS c
FULL OUTER JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
FULL OUTER JOIN Rivers AS r ON r.Id = cr.RiverId
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName


	--15. *Continents and Currencies

SELECT Ordered.ContinentCode,
	   Ordered.CurrencyCode,
	   Ordered.CurrencyUsage
  FROM Continents AS c
  JOIN (
	   SELECT ContinentCode AS [ContinentCode],
	   COUNT(CurrencyCode) AS [CurrencyUsage],
	   CurrencyCode as [CurrencyCode],
	   DENSE_RANK() OVER (PARTITION BY ContinentCode
	                      ORDER BY COUNT(CurrencyCode) DESC
						  ) AS [Rank]
	   FROM Countries
	   GROUP BY ContinentCode, CurrencyCode
	   HAVING COUNT(CurrencyCode) > 1
	   )
	   AS Ordered
    ON c.ContinentCode = Ordered.ContinentCode
 WHERE Ordered.Rank = 1


	--16. Countries Without Any Mountains

SELECT COUNT(*) AS CountryCode FROM
(
	SELECT mc.CountryCode
		FROM Countries AS c
		LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
		WHERE mc.CountryCode IS NULL
) AS CountriesWtihoutMountains


	--17. Highest Peak and Longest River by Country

SELECT TOP(5) Ordered.CountryName,
			  MAX(Ordered.PeakElevation) AS HighestPeakElevation,
			  MAX(Ordered.RiverLength) AS LongestRiverLength
	FROM (
	SELECT c.CountryName AS CountryName, p.Elevation AS PeakElevation, r.Length AS RiverLength 
	FROM Countries AS c
		LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
		LEFT JOIN CountriesRivers AS cr ON cr.CountryCode = c.CountryCode
		LEFT JOIN Rivers AS r ON r.Id = cr.RiverId
		LEFT JOIN Peaks AS p ON p.MountainId = mc.MountainId) AS Ordered

GROUP BY Ordered.CountryName
ORDER BY MAX(Ordered.PeakElevation) DESC,
		 MAX(Ordered.RiverLength) DESC,
		 Ordered.CountryName


	--18. Highest Peak Name and Elevation by Country


WITH chp AS
(SELECT c.CountryName, p.PeakName, p.Elevation, m.MountainRange,
   ROW_NUMBER()
   OVER ( PARTITION BY c.CountryName
     ORDER BY p.Elevation DESC ) AS rn
 FROM Countries AS c
   LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
   LEFT JOIN MountainsCountries AS mc ON mc.CountryCode = c.CountryCode
   LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
   LEFT JOIN Peaks p ON p.MountainId = m.Id)

SELECT TOP(5)
  chp.CountryName AS [Country],
  ISNULL(chp.PeakName, '(no highest peak)') AS [Highest Peak Name],
  ISNULL(chp.Elevation, 0) AS [Highest Peak Elevation],
  CASE 
	WHEN chp.PeakName IS NOT NULL THEN chp.MountainRange
	ELSE '(no mountain)'
  END AS Mountain
FROM chp
WHERE rn = 1
ORDER BY chp.CountryName, chp.PeakName