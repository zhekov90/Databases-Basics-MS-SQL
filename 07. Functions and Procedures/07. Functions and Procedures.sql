
--1.	Employees with Salary Above 35000

CREATE PROC usp_GetEmployeesSalaryAbove35000 
AS
BEGIN
	SELECT FirstName, LastName FROM Employees
	WHERE Salary > 35000
END

EXEC usp_GetEmployeesSalaryAbove35000
GO


--2.	Employees with Salary Above Number

CREATE PROC usp_GetEmployeesSalaryAboveNumber (@minSalary DECIMAL(18,4)) 
AS
BEGIN
	SELECT FirstName, LastName FROM Employees
	WHERE Salary >= @minSalary
END

EXEC usp_GetEmployeesSalaryAboveNumber 48100
GO


--3.	Town Names Starting With

CREATE PROC usp_GetTownsStartingWith(@value VARCHAR(50))
AS
BEGIN
	SELECT [Name] AS Town FROM Towns
	WHERE LEFT([Name], LEN(@value)) = @value
END

EXEC usp_GetTownsStartingWith 'b'
GO


--4.	Employees from Town

CREATE PROC usp_GetEmployeesFromTown(@townName VARCHAR(50))
AS
BEGIN
	SELECT e.FirstName AS [First Name], e.LastName AS [Last Name] FROM Employees AS e
	JOIN Addresses AS a ON a.AddressID = e.AddressID
	JOIN Towns AS t ON t.TownID = a.TownID
	WHERE t.[Name] = @townName
END

EXEC usp_GetEmployeesFromTown 'Sofia'
GO


--5.	Salary Level Function

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(7)
AS
BEGIN
	DECLARE @salaryLevel VARCHAR(50)

	IF(@salary < 30000)
	BEGIN
		SET @salaryLevel = 'Low'
	END

	ELSE IF(@salary BETWEEN 30000 AND 50000)
	BEGIN
		SET @salaryLevel = 'Average'
	END

	ELSE IF(@salary > 50000)
	BEGIN
		SET @salaryLevel = 'High'
	END
	RETURN @salaryLevel
END


GO

SELECT Salary, dbo.ufn_GetSalaryLevel(Salary) AS SalaryLevel FROM Employees

GO

--6.	Employees by Salary Level

CREATE PROC usp_EmployeesBySalaryLevel(@salaryLevel VARCHAR(50))
AS
BEGIN
	SELECT FirstName, LastName FROM Employees
	WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel
END

EXEC usp_EmployeesBySalaryLevel 'High'

GO


--7.	Define Function

CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50)) 
RETURNS BIT
AS
BEGIN
DECLARE @currentIndex int = 1;

WHILE(@currentIndex <= LEN(@word))
	BEGIN

	DECLARE @currentLetter varchar(1) = SUBSTRING(@word, @currentIndex, 1);

	IF(CHARINDEX(@currentLetter, @setOfLetters)) = 0
	BEGIN
	RETURN 0;
	END

	SET @currentIndex += 1;
	END

RETURN 1;
END

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia') -- returns 1
SELECT dbo.ufn_IsWordComprised('oistmiahf', 'halves') -- returns 0

GO


--8.	* Delete Employees and Departments

CREATE PROC usp_DeleteEmployeesFromDepartment(@departmentId INT)
AS
BEGIN
	DELETE FROM EmployeesProjects
	WHERE EmployeeID IN (
						SELECT EmployeeID FROM Employees
						WHERE DepartmentID = @departmentId
						)

	UPDATE Employees
	SET ManagerID = NULL
	WHERE ManagerID IN(
						SELECT EmployeeID FROM Employees
						WHERE DepartmentID = @departmentId
					  )

	ALTER TABLE Departments
	ALTER COLUMN ManagerID INT

	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN(
						SELECT EmployeeID FROM Employees
						WHERE DepartmentID = @departmentId
					  )

	DELETE FROM Employees
	WHERE DepartmentID = @departmentId

	DELETE FROM Departments
	WHERE DepartmentID = @departmentId

	SELECT COUNT(*) FROM Employees
	WHERE DepartmentID = @departmentId
END

EXEC usp_DeleteEmployeesFromDepartment 1

GO


--9.	Find Full Name

CREATE PROC usp_GetHoldersFullName
AS
BEGIN
	SELECT FirstName + ' ' + LastName AS [Full Name] FROM AccountHolders
END

EXEC usp_GetHoldersFullName

GO


--10.	People with Balance Higher Than

CREATE PROC usp_GetHoldersWithBalanceHigherThan(@number DECIMAL(15,2))
AS
BEGIN
	SELECT ah.FirstName, ah.LastName FROM AccountHolders AS ah
	JOIN Accounts AS a ON a.AccountHolderId = ah.Id
	GROUP BY ah.FirstName, ah.LastName
	HAVING  SUM(a.Balance) > @number
	ORDER BY ah.FirstName, ah.LastName
END

EXEC usp_GetHoldersWithBalanceHigherThan 50000.00

GO


--11.	Future Value Function

CREATE FUNCTION ufn_CalculateFutureValue(@sum DECIMAL(15,4), @yearlyInterestRate FLOAT, @years INT)
RETURNS DECIMAL(15,4)
AS
BEGIN
	DECLARE @result DECIMAL(15,4) = @sum * (POWER((1 + @yearlyInterestRate), @years))

	RETURN @result
END

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5) -- should return 1610.5100

GO


--12.	Calculating Interest

CREATE PROC usp_CalculateFutureValueForAccount(@accountId INT, @interestRate FLOAT)
AS
BEGIN
	SELECT a.Id AS [Account Id], ah.FirstName AS [First Name], ah.LastName AS [Last Name], a.Balance AS [Current Balance], dbo.ufn_CalculateFutureValue(a.Balance, @interestRate, 5) FROM AccountHolders AS ah
	JOIN Accounts AS a ON a.AccountHolderId = ah.Id
	WHERE a.Id = @accountId
END

EXEC usp_CalculateFutureValueForAccount 1, 0.1
--should return 
--				Account Id	First Name	Last Name	Current Balance	Balance in 5 years
--
--					1		Susan		Cane		123.12			198.2860

GO


--13.	*Scalar Function: Cash in User Games Odd Rows

CREATE FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(50))
RETURNS TABLE
AS
RETURN SELECT (
				SELECT SUM(Cash) AS SumCash 
				FROM (
					 SELECT g.[Name],
							ug.Cash,
							(ROW_NUMBER() OVER (PARTITION BY g.[Name] ORDER BY ug.Cash DESC)) AS		rowNumber
						FROM Games AS g
				JOIN UsersGames AS ug ON g.Id = ug.GameId
				WHERE g.Name = @gameName) AS ordered
				WHERE rowNumber % 2 = 1
			  ) AS [SumCash]


SELECT * FROM  dbo.ufn_CashInUsersGames('Love in a mist')
--should return table "SumCash" with result 8585.00


