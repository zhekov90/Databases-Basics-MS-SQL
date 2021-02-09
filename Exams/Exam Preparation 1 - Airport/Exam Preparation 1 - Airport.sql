
--1.	Database Design

CREATE TABLE Planes(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	Seats INT NOT NULL,
	[Range] INT NOT NULL
)

CREATE TABLE Flights(
	Id INT PRIMARY KEY IDENTITY,
	DepartureTime DATETIME2,
	ArrivalTime DATETIME2,
	Origin VARCHAR(50) NOT NULL,
	Destination VARCHAR(50) NOT NULL,
	PlaneId INT NOT NULL REFERENCES Planes(Id)
)

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	[Address] VARCHAR(30) NOT NULL,
	PassportId CHAR(11) NOT NULL
)

CREATE TABLE LuggageTypes(
	Id INT PRIMARY KEY IDENTITY,
	[Type] VARCHAR(30) NOT NULL
)

CREATE TABLE Luggages(
	Id INT PRIMARY KEY IDENTITY,
	LuggageTypeId INT NOT NULL REFERENCES LuggageTypes(Id),
	PassengerId INT NOT NULL REFERENCES Passengers(Id)
)

CREATE TABLE Tickets(
	Id INT PRIMARY KEY IDENTITY,
	PassengerId INT NOT NULL REFERENCES Passengers(Id),
	FlightId INT NOT NULL REFERENCES Flights(Id),
	LuggageId INT NOT NULL REFERENCES Luggages(Id),
	Price DECIMAL(16,2) NOT NULL
)


--2.	Insert

INSERT INTO Planes([Name], Seats, [Range])
VALUES
('Airbus 336', 112, 5132),
('Airbus 330', 432, 5325),
('Boeing 369', 231, 2355),
('Stelt 297', 254, 2143),
('Boeing 338', 165, 5111),
('Airbus 558', 387, 1342),
('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes([Type])
VALUES
('Crossbody Bag'),
('School Backpack'),
('Shoulder Bag')


--3.	Update

UPDATE Tickets
SET Price *= 1.13
WHERE FlightId = (SELECT TOP(1) Id FROM Flights WHERE Destination = 'Carlsbad')


--4.	Delete

DELETE FROM Tickets
WHERE FlightId = (SELECT TOP(1) Id FROM Flights WHERE Destination = 'Ayn Halagim')

DELETE FROM Flights
WHERE Destination = 'Ayn Halagim'


--5.	The "Tr" Planes

SELECT * FROM Planes
WHERE [Name] LIKE '%tr%'
ORDER BY Id, [Name], Seats, [Range]


--6.	Flight Profits

SELECT FlightId, SUM(Price) AS Price FROM Tickets
GROUP BY FlightId
ORDER BY Price DESC, FlightId


--7.	Passenger Trips

SELECT p.FirstName + ' ' + p.LastName AS [Full Name], f.Origin, f.Destination FROM Passengers AS p
JOIN Tickets AS t ON t.PassengerId = p.Id
JOIN Flights AS f ON f.Id = t.FlightId
ORDER BY [Full Name], Origin, Destination


--8.	Non Adventures People

SELECT p.FirstName AS [First Name], p.LastName AS [Last Name], p.Age FROM Passengers AS p
FULL JOIN Tickets AS t ON t.PassengerId = p.Id
WHERE t.Id IS NULL
ORDER BY p.Age DESC, [First Name], [Last Name]


--9.	Full Info

SELECT p.FirstName + ' ' + p.LastName AS [Full Name], pl.[Name] AS [Plane Name], f.Origin + ' - ' + f.Destination AS Trip, lt.[Type] AS [Luggage Type] FROM Passengers AS p
JOIN Tickets AS t ON t.PassengerId = p.Id
JOIN Flights AS f ON f.Id = t.FlightId
JOIN Luggages AS l ON l.Id = t.LuggageId
JOIN LuggageTypes AS lt ON lt.Id = l.LuggageTypeId
JOIN Planes AS pl ON pl.Id = f.PlaneId
ORDER BY [Full Name], [Plane Name], Origin, Destination, [Luggage Type]


--10.	PSP

SELECT pl.[Name], pl.Seats, COUNT(p.Id) AS [Passengers Count] FROM Passengers AS p
RIGHT JOIN Tickets AS t ON t.PassengerId = p.Id
RIGHT JOIN Flights AS f ON f.Id = t.FlightId
RIGHT JOIN Planes AS pl ON pl.Id = f.PlaneId
GROUP BY pl.[Name], pl.Seats
ORDER BY [Passengers Count] DESC, pl.[Name], pl.Seats


--11.	Vacation
GO

CREATE FUNCTION udf_CalculateTickets(@origin VARCHAR(50), @destination VARCHAR(50), @peopleCount INT) 
RETURNS VARCHAR(100)
AS
BEGIN

IF(@peopleCount <=0)
BEGIN
	RETURN 'Invalid people count!'
END

DECLARE @flightId INT = (
						SELECT f.Id From Flights AS f
						JOIN Tickets AS t ON t.FlightId = f.Id
						WHERE f.Destination = @destination AND f.Origin = @origin
						)

IF(@flightId IS NULL)
BEGIN
	RETURN 'Invalid flight!'
END

DECLARE @ticketPrice DECIMAL(16,2) = (
									 SELECT t.Price FROM Flights AS f
									 JOIN Tickets AS t ON t.FlightId = f.Id
									 WHERE f.Destination = @destination AND f.Origin = @origin
						)

DECLARE @totalPrice DECIMAL(16,2) = @ticketPrice * @peopleCount
RETURN 'Total price ' + CAST(@totalPrice AS VARCHAR(50))

END

GO 

SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 33)
-- should return 
-- Total price 2419.89


--12.	Wrong Data

CREATE PROC usp_CancelFlights
AS
BEGIN
	UPDATE Flights
	SET DepartureTime = NULL, ArrivalTime = NULL
	WHERE ArrivalTime > DepartureTime
END

EXEC usp_CancelFlights
--should return 
--(49 rows affected)