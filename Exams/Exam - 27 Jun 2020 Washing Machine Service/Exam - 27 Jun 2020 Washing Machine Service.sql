
--1.	Database design

CREATE TABLE Clients(
	ClientId INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Phone CHAR(12) NOT NULL
)

CREATE TABLE Mechanics(
	MechanicId INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	[Address] VARCHAR(255) NOT NULL
)

CREATE TABLE Models(
	ModelId INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs(
	JobId INT PRIMARY KEY IDENTITY NOT NULL,
	ModelId INT REFERENCES Models(ModelId) NOT NULL,
	[Status] VARCHAR(11) CHECK([Status] IN('Pending', 'In Progress', 'Finished')) DEFAULT 'Pending' NOT NULL,
	ClientId INT REFERENCES Clients(ClientId) NOT NULL,
	MechanicId INT REFERENCES Mechanics(MechanicId),
	IssueDate DATE NOT NULL,
	FinishDate DATE
)

CREATE TABLE Orders(
	OrderId INT PRIMARY KEY IDENTITY NOT NULL,
	JobId INT REFERENCES Jobs(JobId) NOT NULL,
	IssueDate DATE,
	Delivered BIT DEFAULT 0 NOT NULL
)

CREATE TABLE Vendors(
	VendorId INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts(
	PartId INT PRIMARY KEY IDENTITY NOT NULL,
	SerialNumber VARCHAR(50) UNIQUE NOT NULL,
	[Description] VARCHAR(255),
	Price MONEY CHECK(Price > 0 AND Price <= 9999.99) NOT NULL,
	VendorId INT REFERENCES Vendors(VendorId) NOT NULL,
	StockQty INT CHECK(StockQty >= 0) DEFAULT 0
)

CREATE TABLE OrderParts(
	OrderId INT REFERENCES Orders(OrderId) NOT NULL,
	PartId INT REFERENCES Parts(PartId) NOT NULL,
	Quantity INT CHECK(Quantity > 0) DEFAULT 1,
	PRIMARY KEY(OrderId, PartId)
)

CREATE TABLE PartsNeeded(
	JobId INT REFERENCES Jobs(JobId) NOT NULL,
	PartId INT REFERENCES Parts(PartId) NOT NULL,
	Quantity INT CHECK(Quantity > 0) DEFAULT 1 NOT NULL,
	PRIMARY KEY(JobId, PartId)
)


--2.	Insert

INSERT INTO Clients(FirstName, LastName, Phone)
VALUES
('Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell', '908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie', 'Knipp', '805-690-1682'),
('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts(SerialNumber, [Description], Price, VendorId)
VALUES
('WP8182119', 'Door Boot Seal', 117.86, 2),
('W10780048', 'Suspension Rod', 42.81, 1),
('W10841140', 'Silicone Adhesive ', 6.77, 4),
('WPY055980', 'High Temperature Adhesive', 13.94, 3)


--3.	Update

UPDATE Jobs
SET MechanicId = 3, [Status] = 'In Progress'
WHERE [Status] = 'Pending'


--4.	Delete

DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM Orders
WHERE OrderId = 19


--5.	Mechanic Assignments

SELECT m.FirstName + ' ' + m.LastName AS Mechanic, j.[Status], j.IssueDate FROM Mechanics AS m
JOIN Jobs AS j ON m.MechanicId = j.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId


--6.	Current Clients

SELECT c.FirstName + ' ' + c.LastName AS Client,
DATEDIFF(DAY, j.IssueDate, '2017-04-24') AS [Days going], j.[Status] AS [Status]
FROM Clients AS c
JOIN Jobs AS j ON j.ClientId = c.ClientId
WHERE j.Status != 'Finished'
ORDER BY [Days going] DESC, c.ClientId


--7.	Mechanic Performance

SELECT m.FirstName + ' ' + m.LastName AS Mechanic, AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days] FROM Mechanics AS m
JOIN Jobs AS j ON m.MechanicId = j.MechanicId
GROUP BY m.MechanicId, m.FirstName, m.LastName
ORDER BY m.MechanicId


--8.	Available Mechanics

SELECT FirstName + ' ' + LastName AS Available FROM Mechanics
WHERE MechanicId NOT IN
	(
	SELECT MechanicId
	 FROM Jobs
	WHERE Status != 'Finished' AND MechanicId IS NOT NULL
	)
ORDER BY MechanicId


--9.	Past Expenses

SELECT j.JobId, ISNULL(SUM(op.Quantity * p.Price), 0) AS Total FROM Orders AS o
JOIN OrderParts AS op ON op.OrderId = o.OrderId
JOIN Parts AS p ON p.PartId = op.PartId
FULL JOIN Jobs AS j ON o.JobId = j.JobId
WHERE j.[Status] = 'Finished'
GROUP BY j.JobId
ORDER BY Total DESC, j.JobId


--10.	Missing Parts

SELECT pn.PartId, p.Description, OrderParts. FROM OrderParts AS op
JOIN Orders AS o ON o.OrderId = op.OrderId
JOIN Parts AS p ON p.PartId = op.PartId
JOIN Jobs AS j ON j.JobId = o.JobId
JOIN PartsNeeded	 AS pn ON pn.PartId = p.PartId

--PartsNeeded, Parts, Jobs, OrderParts, Orders

SELECT * FROM 
	(SELECT p.PartId,
		p.Description,
		SUM(pn.Quantity) AS [Required],
		p.StockQty AS [In Stock],
		(SELECT ISNULL(SUM(op.Quantity), 0)
			FROM OrderParts op
			JOIN Orders o ON o.OrderId = op.OrderId
			WHERE o.Delivered = 0 AND op.PartId = p.PartId) AS Ordered
	FROM PartsNeeded AS pn
	JOIN Parts AS p ON p.PartId = pn.PartId
	JOIN Jobs AS j ON j.JobId = pn.JobId
	WHERE j.Status != 'Finished'
	GROUP BY p.PartId, p.[Description], p.StockQty) AS p
WHERE Required > [In Stock] + Ordered
ORDER BY p.PartId


--11.	Place Order

CREATE PROCEDURE usp_PlaceOrder(@jobId INT, @partSN VARCHAR(50), @quantity INT) AS

IF @quantity <= 0
	THROW 50012, 'Part quantity must be more than zero!', 1

ELSE IF
(SELECT COUNT(*)
FROM Jobs
WHERE JobId = @jobId) <> 1
	THROW 50013, 'Job not found!', 1

ELSE IF
(SELECT Status
FROM Jobs
WHERE JobId = @jobId) = 'Finished'
	THROW 50011, 'This job is not active!', 1

ELSE IF
(SELECT COUNT(*)
FROM Parts
WHERE SerialNumber = @partSN) <> 1
	THROW 50014, 'Part not found!', 1

ELSE
BEGIN
	IF  (SELECT COUNT(*)
		FROM Orders
		WHERE JobId = @jobId AND IssueDate IS NULL) <> 1

	BEGIN
		INSERT INTO Orders (JobId, IssueDate) VALUES
		(@jobId, NULL)
	END

	DECLARE @orderId INT =
		(SELECT OrderId
		FROM Orders
		WHERE JobId = @jobId AND IssueDate IS NULL)

	DECLARE @partId INT =
		(SELECT PartId
		FROM Parts
		WHERE SerialNumber = @partSN)

	IF  (SELECT COUNT(*)
		FROM OrderParts
		WHERE OrderId = @orderId AND PartId = @partId) <> 1

		BEGIN
		INSERT INTO OrderParts(OrderId, PartId, Quantity) VALUES
		(@orderId, @partId, @quantity)
		END

	ELSE BEGIN
		 UPDATE OrderParts
		 SET Quantity += @quantity
		 WHERE OrderId = @orderId AND PartId = @partId 
		 END
END


--12.	Cost Of Order

CREATE FUNCTION udf_GetCost (@jobId INT) RETURNS DECIMAL(15, 2) AS
BEGIN
	DECLARE @sum DECIMAL(15, 2) =
	(SELECT ISNULL(SUM(op.Quantity * p.Price), 0)
	FROM Orders o
	JOIN OrderParts op ON o.OrderId = op.OrderId
	JOIN Parts p ON op.PartId = p.PartId
	WHERE o.JobId = @jobId)
	RETURN @sum
END