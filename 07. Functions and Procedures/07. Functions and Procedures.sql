
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
