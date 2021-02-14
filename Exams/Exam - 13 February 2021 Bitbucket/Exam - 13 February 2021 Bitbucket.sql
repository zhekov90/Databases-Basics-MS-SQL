
CREATE DATABASE Bitbucket

USE Bitbucket


--1.	Database Design

CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
	RepositoryId INT NOT NULL REFERENCES Repositories(Id),
	ContributorId INT NOT NULL REFERENCES Users(Id),
	PRIMARY KEY(RepositoryId, ContributorId)
)

CREATE TABLE Issues
(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(255) NOT NULL,
	IssueStatus CHAR(6) NOT NULL,
	RepositoryId INT NOT NULL REFERENCES Repositories(Id),
	AssigneeId INT NOT NULL REFERENCES Users(Id)
)

CREATE TABLE Commits
(
	Id INT PRIMARY KEY IDENTITY,
	[Message] VARCHAR(255) NOT NULL,
	IssueId INT REFERENCES Issues(Id),
	RepositoryId INT NOT NULL REFERENCES Repositories(Id),
	ContributorId INT NOT NULL REFERENCES Users(Id)
)

CREATE TABLE Files
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	Size DECIMAL(15,2) NOT NULL,
	ParentId INT REFERENCES Files(Id),
	CommitId INT NOT NULL REFERENCES Commits(Id)
)


--2.	Insert

INSERT INTO Files([Name], Size, ParentId, CommitId)
VALUES
('Trade.idk', 2598.0, 1, 1),
('menu.net', 9238.31, 2, 2),
('Administrate.soshy', 1246.93, 3, 3),
('Controller.php', 7353.15, 4, 4),
('Find.java', 9957.86, 5, 5),
('Controller.json', 14034.87, 3, 6),
('Operate.xix', 7662.92, 7, 7)

INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId)
VALUES
('Critical Problem with HomeController.cs file', 'open', 1, 4),
('Typo fix in Judge.html', 'open', 4, 3),
('Implement documentation for UsersService.cs', 'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9, 8)


--3.	Update

UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6


--4.	Delete

DELETE FROM RepositoriesContributors
WHERE RepositoryId = 3

DELETE FROM Issues
WHERE RepositoryId = 3


--5.	Commits

SELECT Id, [Message], RepositoryId, ContributorId FROM Commits
ORDER BY Id, [Message], RepositoryId, ContributorId


--6.	Front-end

SELECT Id, [Name], Size FROM Files
WHERE Size > 1000 AND [Name] LIKE '%html%'
ORDER BY Size DESC, Id, [Name]


--7.	Issue Assignment

SELECT i.Id, CONCAT(u.Username, ' : ', i.Title) AS IssueAssignee FROM Issues AS i
JOIN Users AS u ON u.Id = i.AssigneeId
ORDER BY i.Id DESC, i.AssigneeId


--8.	Single Files

SELECT f1.Id, f1.[Name], CONCAT(f1.Size, 'KB') AS Size FROM Files AS f1
LEFT JOIN Files AS f2 ON f1.Id = f2.ParentId
WHERE f2.ParentId IS NULL
ORDER BY f1.Id, f1.[Name], f1.Size DESC


--9.	Commits in Repositories

SELECT TOP(5) r.Id, r.[Name], COUNT(*) AS Commits FROM Commits AS c
JOIN Repositories AS r ON r.Id = c.RepositoryId
JOIN RepositoriesContributors AS rc ON rc.RepositoryId = r.Id
GROUP BY r.Id, r.[Name]
ORDER BY COUNT(*) DESC, r.Id, r.[Name]


--10.	Average Size

SELECT u.Username, AVG(f.Size) FROM Commits AS c
JOIN Users AS u ON u.Id = c.ContributorId
JOIN Files AS f ON f.CommitId = c.Id
GROUP BY u.Username
ORDER BY AVG(f.Size) DESC, u.Username


--11.	 All User Commits

GO 

CREATE FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
AS
BEGIN 
	RETURN (SELECT COUNT(c.Id) FROM Commits AS c
JOIN Users AS u ON u.Id = c.ContributorId
WHERE u.Username = @username)
END

--SELECT dbo.udf_AllUserCommits('UnderSinduxrein')

--should return 6


