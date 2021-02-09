
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