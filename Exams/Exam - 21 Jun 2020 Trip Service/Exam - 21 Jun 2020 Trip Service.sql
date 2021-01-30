
--1. Database design

CREATE TABLE Cities(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	CountryCode CHAR(2) NOT NULL
)

CREATE TABLE Hotels(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	CityId INT NOT NULL REFERENCES Cities(Id),
	EmployeeCount INT NOT NULL,
	BaseRate DECIMAL(5,2)
)

CREATE TABLE Rooms(
	Id INT PRIMARY KEY IDENTITY,
	Price DECIMAL(5,2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	Beds INT NOT NULL,
	HotelId INT NOT NULL REFERENCES Hotels(Id)
)

CREATE TABLE Trips(
	Id INT PRIMARY KEY IDENTITY,
	RoomId INT NOT NULL REFERENCES Rooms(Id),
	BookDate DATETIME2 NOT NULL ,
	ArrivalDate DATETIME2 NOT NULL,
	ReturnDate DATETIME2 NOT NULL,
	CancelDate DATETIME2,
	CONSTRAINT CK_BookDate CHECK(BookDate<ArrivalDate),
	CONSTRAINT CK_ArrivalDate CHECK(ArrivalDate<ReturnDate)
)

CREATE TABLE Accounts(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(50) NOT NULL,
	MiddleName NVARCHAR(20),
	LastName NVARCHAR(50) NOT NULL,
	CityId INT NOT NULL REFERENCES Cities(Id),
	BirthDate DATETIME2 NOT NULL,
	Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips(
	AccountId INT NOT NULL REFERENCES Accounts(Id),
	TripId INT NOT NULL REFERENCES Trips(Id),
	Luggage INT NOT NULL CHECK(Luggage>=0),
	PRIMARY KEY(AccountId, TripId)
)


--2. Insert

INSERT INTO Accounts(FirstName, MiddleName, LastName, CityId, BirthDate, Email)
VALUES
('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips(RoomId, BookDate, ArrivalDate, ReturnDate, CancelDate)
VALUES
(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)


--3. Update

UPDATE Rooms
SET Price *= 1.14
WHERE HotelId IN(5, 7, 9)


--4. Delete

DELETE FROM AccountsTrips
WHERE AccountId = 47


--5. EEE-Mails

SELECT a.FirstName, a.LastName, FORMAT(a.BirthDate, 'MM-dd-yyyy'), c.[Name] AS Hometown, a.Email FROM Accounts AS a
JOIN Cities AS c ON c.Id = a.CityId
WHERE LEFT(a.Email, 1) = 'e'
ORDER BY c.[Name]


--6. City Statistics

SELECT c.[Name] AS City, COUNT(*) AS Hotels FROM Cities AS c, Hotels AS h
WHERE h.CityId = c.Id
GROUP BY c.[Name]
ORDER BY Hotels DESC, City


--7. Longest and Shortest Trips

SELECT a.Id AS AccountId, a.FirstName + ' ' + a.LastName AS FullName,
MAX(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS LongestTrip,
MIN(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate)) AS ShortestTrip
FROM Accounts AS a
JOIN AccountsTrips AS atr ON a.Id = atr.AccountId
JOIN Trips AS t ON atr.TripId = t.Id
WHERE a.MiddleName IS NULL AND t.CancelDate IS NULL
GROUP BY a.Id, a.FirstName, a.LastName
ORDER BY LongestTrip DESC, ShortestTrip


--8. Metropolis

SELECT TOP(10) c.Id, c.[Name] AS City, c.CountryCode AS Country, COUNT(a.Id) AS Accounts
FROM Cities AS c
JOIN Accounts AS a ON c.Id = a.CityId
GROUP BY c.Id, c.[Name], c.CountryCode
ORDER BY COUNT(a.Id) DESC


--9. Romantic Getaways

SELECT a.Id, a.Email, c.[Name] AS City, COUNT(t.Id) AS Trips  FROM Accounts AS a
JOIN AccountsTrips AS at ON at.AccountId = a.Id
JOIN Trips AS t ON t.Id = at.TripId
JOIN Rooms AS r ON r.Id = t.RoomId
JOIN Hotels AS h ON h.Id = r.HotelId
JOIN Cities AS c ON c.Id = a.CityId
WHERE a.CityId = h.CityId
GROUP BY a.Id, a.Email, c.[Name]
ORDER BY Trips DESC, a.Id


--10. GDPR Violation

SELECT t.Id, a.FirstName + ' ' + ISNULL(a.MiddleName + ' ', '') + a.LastName AS [Full Name], cfrom.[Name] AS [From], cto.[Name] AS [To], 
	CASE 
	WHEN t.CancelDate IS NULL THEN CONCAT(DATEDIFF(DAY, t.ArrivalDate, t.ReturnDate), ' days')
	ELSE 'Canceled'
	END AS Duration
FROM Trips AS t 
JOIN AccountsTrips AS at ON [at].TripId = t.Id
JOIN Accounts AS a ON a.Id = [at].AccountId
JOIN Cities AS cfrom ON cfrom.Id = a.CityId
JOIN Rooms AS r ON t.RoomId = r.Id
JOIN Hotels AS h ON r.HotelId = h.Id
JOIN Cities AS cto ON cto.Id = h.CityId
ORDER BY [Full Name], t.Id


--11. Available Room

CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATETIME2, @People INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @Room TABLE
	(
		Id INT NOT NULL,
		Price DECIMAL(20, 2) NOT NULL,
		[Type] NVARCHAR(20) NOT NULL,
		Beds INT NOT NULL
	)

	INSERT INTO @Room
	SELECT TOP(1) r.Id, (r.Price + h.BaseRate) * @People AS Price, r.Type, r.Beds
	FROM Rooms AS r
	JOIN Hotels h ON h.Id = r.HotelId
	WHERE r.HotelId = @HotelId
		AND r.Beds >= @People
		AND r.Id NOT IN
		(
		SELECT r.Id FROM Rooms AS r
		JOIN Trips AS t ON t.RoomId = r.Id
		WHERE @Date BETWEEN t.ArrivalDate AND t.ReturnDate
		)
	ORDER BY Price DESC

	DECLARE @RoomId INT = (SELECT Id FROM @Room)

	IF @RoomId IS NULL
	RETURN 'No rooms available'

	DECLARE @Price DECIMAL(20, 2) = (SELECT Price FROM @Room)

	DECLARE @Type NVARCHAR(20) = (SELECT Type FROM @Room)

	DECLARE @Beds INT = (SELECT Beds FROM @Room)
	RETURN FORMATMESSAGE('Room %d: %s (%d beds) - $%s', @RoomId, @Type, @Beds, CONVERT(NVARCHAR, @Price))
END


--12. Switch Room

CREATE PROCEDURE usp_SwitchRoom(@TripId INT, @TargetRoomId INT) AS

DECLARE @TripHotelId INT = 
	(
	SELECT h.Id FROM Hotels AS h
	JOIN Rooms AS r ON r.HotelId = h.Id
	JOIN Trips AS t ON t.RoomId = r.Id
	WHERE t.Id = @TripId
	)

DECLARE @BedsRequired INT =
	(
	SELECT COUNT(*) FROM AccountsTrips
	WHERE TripId = @TripId
	)

DECLARE @TargetHotelId INT =
	(
	SELECT h.Id FROM Hotels AS h
	JOIN Rooms AS r ON r.HotelId = h.Id
	WHERE r.Id = @TargetRoomId
	)

DECLARE @TargetRoomBeds INT =
	(
	SELECT Beds
	FROM Rooms 
	WHERE Id = @TargetRoomId
	)

IF @TargetHotelId != @TripHotelId
BEGIN
	RAISERROR('Target room is in another hotel!', 16, 1)
	RETURN
END
		
IF @BedsRequired > @TargetRoomBeds
BEGIN
	RAISERROR('Not enough beds in target room!', 16, 1)
	RETURN
END

UPDATE Trips
SET RoomId = @TargetRoomId
WHERE Id = @TripId