--1. Records’ Count

SELECT COUNT(*) AS [Count] FROM WizzardDeposits


--2. Longest Magic Wand

SELECT TOP(1) MagicWandSize AS LongestMagicWand FROM WizzardDeposits
ORDER BY MagicWandSize DESC


--3. Longest Magic Wand Per Deposit Groups

SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand FROM WizzardDeposits
GROUP BY DepositGroup


--4. * Smallest Deposit Group Per Magic Wand Size

SELECT TOP(2) DepositGroup
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)


--5. Deposits Sum

SELECT  DepositGroup,  SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
GROUP BY DepositGroup 


--6. Deposits Sum for Ollivander Family

SELECT  DepositGroup,  SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup 


--07. Deposits Filter

SELECT  DepositGroup,  SUM(DepositAmount) AS TotalSum
FROM WizzardDeposits
WHERE MagicWandCreator = 'Ollivander family'
GROUP BY DepositGroup
HAVING SUM(DepositAmount) < 150000
ORDER BY SUM(DepositAmount) DESC


--8.  Deposit Charge

SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge FROM WizzardDeposits
GROUP BY MagicWandCreator, DepositGroup
ORDER BY MagicWandCreator, DepositGroup


--09. Age Groups

SELECT AgeGroupsQuery.AgeGroup, COUNT(*) AS WizardCount
FROM
	(SELECT
		CASE 
			WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
			WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
			WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
			WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
			WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
			WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
			WHEN Age >=61 THEN '[61+]'
		END AS AgeGroup
		FROM WizzardDeposits
	) AS AgeGroupsQuery
GROUP BY AgeGroupsQuery.AgeGroup


--10. First Letter

SELECT DISTINCT LEFT(FirstName, 1) AS FirstLetter FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY FirstName


--11. Average Interest 

SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS AverageInterest FROM WizzardDeposits
WHERE DepositStartDate > '01/01/1985'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired


--12. * Rich Wizard, Poor Wizard

SELECT SUM(WizardDeposit.[Difference]) AS SumDifference FROM
(
SELECT FirstName, DepositAmount,
LEAD(FirstName) OVER (ORDER BY Id) AS GuestWizard,
LEAD(DepositAmount) OVER (ORDER BY Id) AS GuestDeposit,
DepositAmount - LEAD(DepositAmount) OVER (ORDER BY Id) AS [Difference]
FROM WizzardDeposits
) AS WizardDeposit


--13. Departments Total Salaries

SELECT DepartmentID, SUM(Salary) FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID


--14. Employees Minimum Salaries

SELECT DepartmentID, MIN(Salary) FROM Employees
WHERE DepartmentID IN(2, 5, 7) AND HireDate > 01/01/2000
GROUP BY DepartmentID


--15. Employees Average Salaries

SELECT *
INTO EmployeesSalariesMoreThan30000
FROM Employees AS e
WHERE e.Salary > 30000

DELETE EmployeesSalariesMoreThan30000
WHERE ManagerID = 42

UPDATE EmployeesSalariesMoreThan30000
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) AS AverageSalary FROM EmployeesSalariesMoreThan30000
GROUP BY DepartmentID


--16. Employees Maximum Salaries

SELECT DepartmentID, MAX(Salary) AS MaxSalary FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000


--17. Employees Count Salaries

SELECT COUNT(*) AS [Count] FROM Employees
WHERE ManagerID IS NULL


--18. *3rd Highest Salary

SELECT RankSalariesQuery.DepartmentID, RankSalariesQuery.Salary AS ThirdHighestSalary FROM 
(
	SELECT DepartmentID, MAX(Salary) AS Salary, DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS	DenseRank
	FROM Employees
	GROUP BY DepartmentID, Salary
) AS RankSalariesQuery
WHERE DenseRank = 3
ORDER BY DepartmentID


--19. **Salary Challenge


SELECT TOP(10) FirstName, LastName, DepartmentID FROM Employees AS e1
WHERE e1.Salary > (SELECT AVG(Salary) FROM Employees AS e2
WHERE e2.DepartmentID = e1.DepartmentID
GROUP BY DepartmentID)
ORDER BY DepartmentID