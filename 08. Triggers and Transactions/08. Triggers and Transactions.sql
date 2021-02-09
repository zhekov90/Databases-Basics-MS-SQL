
-- 1.	Create Table Logs

CREATE TABLE Logs
(
LogId int IDENTITY,
AccountId int,
OldSum money,
NewSum money,
CONSTRAINT PK_Logs PRIMARY KEY(LogId),
CONSTRAINT FK_Logs_Accounts FOREIGN KEY(AccountId) REFERENCES Accounts(Id)
)

GO

CREATE TRIGGER tr_BalanceChange ON Accounts AFTER UPDATE
AS
BEGIN
	INSERT INTO Logs(AccountId, OldSum, NewSum)
	SELECT i.Id, d.Balance, i.Balance 
	FROM inserted AS i
	INNER JOIN deleted AS d
	ON i.Id = d.Id
END


-- 2.	Create Table Emails

CREATE TABLE NotificationEmails
(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT,
	[Subject] VARCHAR(MAX),
	Body VARCHAR(MAX)
)

GO

CREATE TRIGGER tr_EmailNotificationOnBalanceChange ON Logs AFTER INSERT
AS
BEGIN
	INSERT INTO NotificationEmails(Recipient, Subject, Body)
	SELECT	AccountId, 
		CONCAT('Balance change for account: ', AccountId), 
		CONCAT('On ', GETDATE(), ' your balance was changed from ', OldSum, ' to ', NewSum, '.') 
	FROM inserted
END


-- 3.	Deposit Money

CREATE PROCEDURE usp_DepositMoney(@accountId INT, @moneyAmount MONEY)
AS
	BEGIN TRANSACTION
		UPDATE Accounts
		SET Balance += @moneyAmount
		WHERE Id = @accountId
	COMMIT

GO


-- 4.	Withdraw Money

CREATE PROCEDURE usp_WithdrawMoney(@accountId INT, @moneyAmount MONEY)
AS
BEGIN TRANSACTION

	UPDATE Accounts
	SET Balance -= @moneyAmount
	WHERE Id = @accountId
	
	DECLARE @currentBalance money = (SELECT Balance FROM Accounts WHERE Id = @accountId)

	IF(@currentBalance < 0)
		BEGIN
			ROLLBACK
			RAISERROR('Insufficient funds!', 16, 1)
			RETURN
		END
	ELSE
		BEGIN
			COMMIT
		END

GO


-- 5.	Money Transfer

CREATE PROCEDURE usp_TransferMoney(@senderId INT, @receiverId INT, @amount MONEY)
AS
BEGIN TRANSACTION

IF(@amount < 0)
	BEGIN
		ROLLBACK
		RAISERROR('Amount is less then 0!', 16, 1)
		RETURN
	END

EXEC usp_WithdrawMoney @senderId, @amount
EXEC usp_DepositMoney @receiverId, @amount

COMMIT


-- 7.	*Massive Shopping

DECLARE @UserName VARCHAR(50) = 'Stamat'
DECLARE @GameName VARCHAR(50) = 'Safflower'
DECLARE @UserID int = (
						SELECT Id FROM Users WHERE Username = @UserName
					  )
DECLARE @GameID int = (
					   SELECT Id FROM Games WHERE Name = @GameName
					  )
DECLARE @UserMoney money = (
							SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID
						   )
DECLARE @ItemsTotalPrice money
DECLARE @UserGameID int = (
						   SELECT Id FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID
						  )

BEGIN TRANSACTION
	SET @ItemsTotalPrice = (
							SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12
							)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
		BEGIN
			INSERT INTO UserGameItems
			SELECT i.Id, @UserGameID FROM Items AS i
			WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 11 AND 12)

			UPDATE UsersGames
			SET Cash -= @ItemsTotalPrice
			WHERE GameId = @GameID AND UserId = @UserID
			COMMIT
		END
	ELSE
		BEGIN
			ROLLBACK
		END

SET @UserMoney = (SELECT Cash FROM UsersGames WHERE UserId = @UserID AND GameId = @GameID)
BEGIN TRANSACTION
	SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21)

	IF(@UserMoney - @ItemsTotalPrice >= 0)
		BEGIN
			INSERT INTO UserGameItems
			SELECT i.Id, @UserGameID FROM Items AS i
			WHERE i.Id IN (SELECT Id FROM Items WHERE MinLevel BETWEEN 19 AND 21)

			UPDATE UsersGames
			SET Cash -= @ItemsTotalPrice
			WHERE GameId = @GameID AND UserId = @UserID
			COMMIT
		END
	ELSE
		BEGIN
			ROLLBACK
		END

SELECT Name AS [Item Name]
FROM Items
WHERE Id IN (SELECT ItemId FROM UserGameItems WHERE UserGameId = @userGameID)
ORDER BY [Item Name]


-- 8.	Employees with Three Projects

CREATE PROC usp_AssignProject(@EmloyeeId INT , @ProjectID INT)
AS
BEGIN TRANSACTION
DECLARE @ProjectsCount INT;
SET @ProjectsCount = (SELECT COUNT(ProjectID) FROM EmployeesProjects WHERE EmployeeID = @emloyeeId)
IF(@ProjectsCount >= 3)
	BEGIN 
	 ROLLBACK
	 RAISERROR('The employee has too many projects!', 16, 1)
	 RETURN
	END
INSERT INTO EmployeesProjects
     VALUES
(@EmloyeeId, @ProjectID)
 
 COMMIT