CREATE DATABASE Minions

USE Minions

CREATE TABLE Minions(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL,
	Age TINYINT
)

CREATE TABLE Towns(
	Id INT PRIMARY KEY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

ALTER TABLE Minions
ADD TownId INT FOREIGN KEY REFERENCES Towns(Id)

--04. Insert Records in Both Tables

INSERT INTO Towns(Id, [Name])
	VALUES
			(1, 'Sofia'),
			(2, 'Plovdiv'),
			(3, 'Varna')

INSERT INTO Minions(Id, [Name], Age, TownId)
	VALUES
			(1, 'Kevin', 22, 1),
			(2, 'Bob', 15, 3),
			(3, 'Steward', NULL, 2)

SELECT * FROM Minions

SELECT * FROM Towns

TRUNCATE TABLE Minions

DROP TABLE Minions
DROP TABLE Towns

--07. Create Table People

CREATE TABLE People(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX)
	CHECK(DATALENGTH(Picture) <= 2000 * 1024),
	Height DECIMAL(3,2),
	[Weight] DECIMAL(5,2),
	Gender CHAR(1) NOT NULL,
	Birthdate VARCHAR(20) NOT NULL,
	Biography NVARCHAR(MAX)
)

INSERT INTO People([Name], Height, [Weight], Gender, Birthdate,Biography)
	VALUES
('Zdravko', 1.80, 80, 'm', '01.01.1990', 
 'asdasd'),
 ('Ivan', 1.75, 92, 'm', '01.02.1990', 
 'sdgffk'),
 ('Georgi', 1.78, 85, 'm', '01.03.1990', 
 'yuty'),
 ('Pesho', 1.69, 87, 'm', '01.04.1990', 
 'djhk'),
 ('Valeri', 1.72, 91, 'm', '01.05.1990', 
 'sfhgj')

SELECT * FROM People

--08. Create Table Users

CREATE TABLE Users(
	Id BIGINT PRIMARY KEY IDENTITY NOT NULL,
	Username VARCHAR(30) UNIQUE NOT NULL, 
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture VARBINARY(MAX)
	CHECK(DATALENGTH(ProfilePicture) <= 900 * 1024),
	LastLoginTime DATETIME2 NOT NULL,
	IsDeleted BIT NOT NULL
)

INSERT INTO	Users(Username, [Password], LastLoginTime, IsDeleted)
VALUES
('Zdravko', '123456', '01.01.2021', 0),
('Georgi', '345476', '01.02.2021', 1),
('Ivan', '132467', '01.03.2021', 0),
('Iliqn', '45678', '01.04.2021', 1),
('Valeri', '12468', '01.05.2021', 0)

SELECT * FROM Users

TRUNCATE TABLE Users

--Problem 9.	Change Primary Key

ALTER TABLE Users
DROP CONSTRAINT [PK__Users__3214EC070B7B415F]

ALTER TABLE Users
ADD CONSTRAINT PK_Users_CompositeIdUsername
PRIMARY KEY(Id, Username)

--Problem 10.	Add Check Constraint

ALTER TABLE Users
ADD CONSTRAINT CK_Users_PasswordLength
CHECK(LEN([Password]) >=5)

--Problem 11.	Set Default Value of a Field

ALTER TABLE Users
ADD CONSTRAINT DF_Users_LastLoginTime
DEFAULT GETDATE() FOR LastLoginTime

--Problem 12.	Set Unique Field

ALTER TABLE Users
DROP CONSTRAINT [PK_Users_CompositeIdUsername]

ALTER TABLE Users
ADD CONSTRAINT PK_Users_Id
PRIMARY KEY(Id)

ALTER TABLE Users
ADD CONSTRAINT CK_Users_UsernameLength
CHECK(LEN(Username) >=3)

--Problem 13.	Movies Database

CREATE DATABASE Movies --Remove for Judge

CREATE TABLE Directors(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	DirectorName VARCHAR(30) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Directors(DirectorName)
VALUES
('Martin Scorsese'),
('Steven Spielberg'),
('Quentin Tarantino'),
('Alfred Hitchcock'),
('Stanley Kubrick')


CREATE TABLE Genres(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	GenreName VARCHAR(30) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Genres(GenreName)
VALUES
('Horror'),
('Romance'),
('Science fiction'),
('Thriller'),
('Action')


CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CategoryName VARCHAR(30) NOT NULL,
	Notes VARCHAR(MAX)
)

INSERT INTO Categories(CategoryName)
VALUES
('Comedy'),
('Crime'),
('Drama'),
('Fantasy'),
('Historical')


CREATE TABLE Movies(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Title VARCHAR(100) NOT NULL,
	DirectorId INT NOT NULL,
	CopyrightYear INT,
	[Length] VARCHAR(20),
	GenreId INT NOT NULL,
	CategoryId INT NOT NULL,
	Rating INT,
	Notes VARCHAR(MAX)
)

INSERT INTO Movies(Title, DirectorId, CopyrightYear, [Length],GenreId,CategoryId,Rating)
VALUES
('Film1', 2,1988, '120min', 2, 1, 5),
('Film2', 4,1948, '130min', 5, 3, 6),
('Film3', 1,1968, '110min', 4, 4, 5),
('Film4', 3,1989, '80min', 3, 5, 5),
('Film5', 5,1997, '90min', 1, 2, 4)

--Problem 14.	Car Rental Database

CREATE DATABASE CarRental

USE CarRental

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CategoryName VARCHAR(50) NOT NULL,
	DailyRate INT NOT NULL,
	WeeklyRate INT NOT NULL,
	MonthlyRate INT NOT NULL,
	WeekendRate INT NOT NULL
)

CREATE TABLE Cars(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	PlateNumber VARCHAR(20) NOT NULL,
	Manufacturer VARCHAR(20) NOT NULL,
	Model VARCHAR(20) NOT NULL,
	CarYear INT NOT NULL,
	CategoryId INT NOT NULL,
	Doors INT,
	Picture VARBINARY(MAX),
	Condition VARCHAR(20),
	Available CHAR(1)
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Title VARCHAR(20),
	Notes VARCHAR(MAX)

)

CREATE TABLE Customers(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	DriverLicenceNumber VARCHAR(20) NOT NULL,
	FullName VARCHAR(20) NOT NULL,
	[Address] VARCHAR(20),
	City VARCHAR(20),
	ZIPCode VARCHAR(20),
	Notes VARCHAR(MAX)

)

CREATE TABLE RentalOrders(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId INT NOT NULL,
	CustomerId INT,
	CarId INT NOT NULL,
	TankLevel INT,
	KilometrageStart INT,
	KilometrageEnd INT,
	TotalKilometrage INT,
	StartDate DATE,
	EndDate DATE,
	TotalDays INT,
	RateApplied INT,
	TaxRate INT,
	OrderStatus VARCHAR(20),
	Notes VARCHAR(MAX)

)

INSERT INTO Categories(CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate)
VALUES
('asdf', 3, 4, 5, 6),
('gjfhgdf', 73, 64, 55, 6),
('jfhd', 23, 14, 35, 46)

INSERT INTO Cars(PlateNumber, Manufacturer, Model, CarYear,CategoryId)
VALUES
('AA40BB', 'BMW', 'X6', '2020', 1),
('AA50BB', 'Opel', 'Meriva', '2007', 2),
('AA770BB', 'Audi', 'A3', '2003', 3)

INSERT INTO Employees(FirstName, LastName)
VALUES
('Ivan', 'Ivanov'),
('Pesho', 'Peshov'),
('Geprgi', 'Petkov')

INSERT INTO Customers(DriverLicenceNumber, FullName)
VALUES
('5746', 'Martin Ivanov'),
('2367', 'Pesho Iliev'),
('84563', 'Petko Zhekov')

INSERT INTO RentalOrders(EmployeeId, CarId)
VALUES
	(1,2),
	(2,3),
	(1,3)


	--Problem 15.	Hotel Database

CREATE DATABASE Hotel

USE Hotel

CREATE TABLE Employees(
Id INT PRIMARY KEY IDENTITY NOT NULL,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(20) NOT NULL,
Title VARCHAR(20),
Notes VARCHAR(MAX)
)

INSERT INTO Employees(FirstName, LastName)
VALUES
('Ivan', 'Ivanov'),
('Gosho', 'Petrow'),
('Pesho', 'Draganov')

CREATE TABLE Customers(
AccountNumber INT PRIMARY KEY IDENTITY NOT NULL,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(20) NOT NULL,
PhoneNumber VARCHAR(20),
EmergencyName VARCHAR(20),
EmergencyNumber VARCHAR(20),
Notes VARCHAR(MAX)
)

INSERT INTO Customers(FirstName,LastName)
VALUES
('Dragan', 'Cankov'),
('Ivo', 'Stoqnov'),
('Petar', 'Petrov')

CREATE TABLE RoomStatus(
Id INT PRIMARY KEY IDENTITY NOT NULL,
RoomStatus BIT,
Notes VARCHAR(MAX)
)

INSERT INTO RoomStatus(RoomStatus, Notes)
VALUES
(1, 'Check the AC'),
(2, 'Needs clean towels'),
(3, 'Clean the room before 11')

CREATE TABLE RoomTypes(
RoomType VARCHAR(20) PRIMARY KEY,
Notes VARCHAR(MAX)
)

INSERT INTO RoomTypes(RoomType, Notes)
VALUES
('Single bedroom', '1 bedroom'),
('Double bedroom', '2 bedrooms'),
('Apartment', '6+1 people')

CREATE TABLE BedTypes(
BedType VARCHAR(20) PRIMARY KEY,
Notes VARCHAR(MAX)
)

INSERT INTO BedTypes(BedType, Notes)
VALUES
('Kingsize bed', '2 adults + 1 children'),
('Twin bed', '2 separate beds'),
('Single bed', '1 person')

CREATE TABLE Rooms(
RoomNumber INT PRIMARY KEY IDENTITY NOT NULL,
RoomType VARCHAR(20) FOREIGN KEY REFERENCES RoomTypes(RoomType),
BedType VARCHAR(20) FOREIGN KEY REFERENCES BedTypes(BedType),
Rate DECIMAL(6,2),
RoomStatus NVARCHAR(50),
Notes NVARCHAR(MAX)
)

INSERT INTO Rooms(Rate, Notes)
VALUES 
(10,'Available'),
(13,'Available til 01.06.2021'),
(15,'Unavailable')

CREATE TABLE Payments(
Id INT PRIMARY KEY IDENTITY NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
PaymentDate DATE,
AccountNumber BIGINT,
FirstDateOccupied DATE,
LastDateOccupied DATE,
TotalDays AS DATEDIFF(DAY, FirstDateOccupied, LastDateOccupied),
AmountCharged DECIMAL(14,2),
TaxRate DECIMAL(8, 2),
TaxAmount DECIMAL(8, 2),
PaymentTotal DECIMAL(15, 2),
Notes VARCHAR(MAX)
)
 
INSERT INTO Payments (EmployeeId, PaymentDate, AmountCharged)
VALUES
(1, '12/12/2018', 2000.40),
(2, '12/12/2018', 1500.40),
(3, '12/12/2018', 1000.40)

CREATE TABLE Occupancies(
Id  INT PRIMARY KEY IDENTITY NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
DateOccupied DATE,
AccountNumber BIGINT,
RoomNumber INT FOREIGN KEY REFERENCES Rooms(RoomNumber),
RateApplied DECIMAL(6,2),
PhoneCharge DECIMAL(6,2),
Notes VARCHAR(MAX)
)
 
INSERT INTO Occupancies (EmployeeId, RateApplied, Notes) VALUES
(1, 23.90, 'asd'),
(2, 15.00, 'dfg'),
(3, 18.33, 'gfh')

