--Problem 16.	Create SoftUni Database

CREATE DATABASE SoftUni

USE SoftUni

CREATE TABLE Towns(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Addresses(
Id INT PRIMARY KEY IDENTITY,
AddressText NVARCHAR(100) NOT NULL,
TownId INT FOREIGN KEY REFERENCES Towns(Id) NOT NULL
)

CREATE TABLE Departments(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(50),
LastName NVARCHAR(50) NOT NULL,
JobTitle NVARCHAR(50) NOT NULL,
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL,
HireDate DATE NOT NULL,
Salary DECIMAL(10,2) NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
)



--Problem 17.	Backup Database

-- right click on the database
--tasks -> back up...



--Problem 18.	Basic Insert

INSERT INTO Towns([Name])
VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

INSERT INTO Departments([Name])
VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')

INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary)
VALUES 
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 
(SELECT TOP 1 Id FROM Departments WHERE [Name] = 'Software Development'),
'02/01/2013', '3500.00'),

('Petar', 'Petrov', 'Petrov', 'Senior Engineer',
(SELECT TOP 1 Id FROM Departments WHERE [Name] = 'Engineering'),
'03/02/2004', '4000.00'),

('Maria', 'Petrova', 'Ivanova', 'Intern',
(SELECT TOP 1 Id FROM Departments WHERE [Name] = 'Quality Assurance'),
'08/28/2016', '525.25'),


('Georgi', 'Teziev', 'Ivanov', 'CEO',
(SELECT TOP 1 Id FROM Departments WHERE [Name] = 'Sales'),
'12/09/2007', '3000.00'),

('Peter', 'Pan', 'Pan', 'Intern', 
(SELECT TOP 1 Id FROM Departments WHERE [Name] = 'Marketing'),
'08/28/2016', '599.88')



-- 19. Basic Select All Fields

SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees



--20. Basic Select All Fields and Order Them

SELECT * FROM Towns
ORDER BY [Name] ASC

SELECT * FROM Departments
ORDER BY [Name] ASC

SELECT * FROM Employees
ORDER BY Salary DESC



--21. Basic Select Some Fields

SELECT [Name] FROM Towns
ORDER BY [Name] ASC

SELECT [Name] FROM Departments
ORDER BY [Name] ASC

SELECT FirstName,LastName,JobTitle, Salary FROM Employees
ORDER BY Salary DESC



--22. Increase Employees Salary

UPDATE Employees
SET Salary *=1.1;

SELECT Salary FROM Employees



--23. Decrease Tax Rate

USE Hotel

UPDATE Payments

SET TaxRate*=0.97

SELECT TaxRate FROM Payments


--24. Delete All Records

TRUNCATE TABLE Occupancies
