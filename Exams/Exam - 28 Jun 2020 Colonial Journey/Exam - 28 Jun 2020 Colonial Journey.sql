CREATE DATABASE ColonialJourney 

--Section 1. DDL 

CREATE TABLE Planets(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	PlanetId INT NOT NULL REFERENCES Planets(Id)
)

CREATE TABLE Spaceships(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Manufacturer VARCHAR(30) NOT NULL,
	LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	Ucn VARCHAR(10) NOT NULL UNIQUE,
	BirthDate DATETIME2 NOT NULL
)

CREATE TABLE Journeys(
	Id INT PRIMARY KEY IDENTITY,
	JourneyStart DATETIME2 NOT NULL,
	JourneyEnd DATETIME2 NOT NULL,
	Purpose VARCHAR(11) CHECK(Purpose IN( 'Medical', 'Technical', 'Educational', 'Military')),
	DestinationSpaceportId INT NOT NULL REFERENCES Spaceports(Id) ON DELETE CASCADE, 
	SpaceshipId INT NOT NULL REFERENCES Spaceships(Id) ON DELETE CASCADE
)

CREATE TABLE TravelCards(
	Id INT PRIMARY KEY IDENTITY,
	CardNumber CHAR(10) NOT NULL UNIQUE,
	JobDuringJourney VARCHAR(8) CHECK(JobDuringJourney IN( 'Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
	ColonistId INT NOT NULL REFERENCES Colonists(Id),
	JourneyId INT NOT NULL REFERENCES Journeys(Id) ON DELETE CASCADE
)


--2.	Insert

INSERT INTO Planets
VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')

INSERT INTO Spaceships([Name], Manufacturer, LightSpeedRate)
VALUES
('Golf', 'VW', 3),
('WakaWaka', 'Wakanda', 4),
('Falcon9', 'SpaceX', 1),
('Bed', 'Vidolov', 6)


--3.	Update

UPDATE Spaceships
SET LightSpeedRate += 1
WHERE Id BETWEEN 8 AND 12


--4.	Delete

DELETE FROM TravelCards
      WHERE JourneyId IN (SELECT TOP(3) j.Id
		            FROM Journeys AS j)

DELETE TOP(3) FROM Journeys


--5.	Select all military journeys

SELECT Id, FORMAT(JourneyStart, 'dd/MM/yyyy'),  FORMAT(JourneyEnd, 'dd/MM/yyyy') FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart


--06. Select All Pilots

SELECT c.Id, (c.FirstName + ' ' + c.LastName) AS full_name FROM Colonists AS c
JOIN TravelCards AS t ON t.ColonistId = c.Id
WHERE t.JobDuringJourney = 'Pilot'
ORDER BY c.Id


--07.	Count colonists

SELECT COUNT(*) FROM Colonists AS c
JOIN TravelCards AS t ON t.ColonistId = c.Id
JOIN Journeys AS j ON j.Id = t.JourneyId
WHERE j.Purpose = 'Technical'


--8.	Select spaceships with pilots younger than 30 years

SELECT s.[Name], s.Manufacturer FROM Colonists AS c
JOIN TravelCards AS t ON t.ColonistId = c.Id
JOIN Journeys AS j ON j.Id = t.JourneyId
JOIN Spaceships AS s ON s.Id = j.SpaceshipId
WHERE DATEDIFF(year, c.BirthDate, '2019/01/01') <30 AND t.JobDuringJourney = 'Pilot'
ORDER BY s.[Name]


--9.	Select all planets and their journey count

SELECT p.[Name] AS PlanetName, COUNT(*) AS JourneysCount FROM Journeys AS j
JOIN Spaceports AS s ON s.Id = j.DestinationSpaceportId
JOIN Planets AS p ON p.Id = s.PlanetId
GROUP BY p.[Name]
ORDER BY JourneysCount DESC, PlanetName


--10.	Select Second Oldest Important Colonist

SELECT OldestColonistQuery.JobDuringJourney, OldestColonistQuery.FullName,OldestColonistQuery.JobRank
FROM 
(
	SELECT t.JobDuringJourney,
		   (c.FirstName + ' ' + c.LastName) AS FullName,
		   DENSE_RANK() OVER (PARTITION BY t.JobDuringJourney ORDER BY c.Birthdate) AS JobRank
	FROM TravelCards AS t
	JOIN Colonists AS c ON c.Id = t.ColonistId
	) AS OldestColonistQuery
WHERE OldestColonistQuery.JobRank = 2


--11.	Get Colonists Count

CREATE FUNCTION dbo.udf_GetColonistsCount(@PlanetName VARCHAR(30))
RETURNS INT AS
BEGIN
    RETURN (SELECT COUNT(*) FROM TravelCards AS t
JOIN Journeys AS j ON j.Id = t.JourneyId
JOIN Spaceports AS s ON s.Id = j.DestinationSpaceportId
JOIN Planets AS p ON p.Id = s.PlanetId
JOIN Colonists AS c ON c.Id = t.ColonistId
WHERE p.Name LIKE @PlanetName)
END


--12.	Change Journey Purpose

CREATE PROCEDURE usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(11))
AS
BEGIN TRANSACTION
		IF (NOT EXISTS(
			SELECT * FROM Journeys AS j
			WHERE j.Id = @JourneyId))
		BEGIN
			ROLLBACK
			RAISERROR('The journey does not exist!', 16, 1)
			RETURN
		END

		DECLARE @OldPurpose VARCHAR(11)
		
		SET @OldPurpose = (SELECT j.Purpose FROM Journeys AS j
		WHERE j.Id = @JourneyId)

		IF (@OldPurpose = @NewPurpose)
		BEGIN
			ROLLBACK
			RAISERROR('You cannot change the purpose!', 16, 2)
			RETURN
		END

		UPDATE Journeys
		SET Purpose = @NewPurpose
		WHERE Id = @JourneyId
COMMIT

