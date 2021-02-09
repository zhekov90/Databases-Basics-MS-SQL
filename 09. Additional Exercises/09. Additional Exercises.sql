
--Problem 1.	Number of Users for Email Provider

SELECT SUBSTRING([Email], CHARINDEX('@', [Email]) + 1, LEN([Email])) AS [Email Provider], COUNT(*) AS [Number Of Users] FROM Users
GROUP BY SUBSTRING([Email], CHARINDEX('@', [Email]) + 1, LEN([Email]))
ORDER BY [Number Of Users] DESC, [Email Provider]


--Problem 2.	All User in Games

SELECT g.[Name] AS Game, gt.[Name] AS [Game Type], u.Username, ug.[Level], ug.Cash, c.[Name] FROM  UsersGames AS ug
JOIN Users AS u ON u.Id = ug.UserId
JOIN Games AS g ON g.Id = ug.GameId
JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
JOIN Characters AS c ON c.Id = ug.CharacterId
ORDER BY ug.[Level] DESC, u.Username, g.[Name]


--Problem 3.	Users in Games with Their Items

SELECT u.Username, g.[Name] AS Game, COUNT(i.Id) AS [Items Count], SUM(i.Price) AS [Items Price] FROM  UsersGames AS ug
JOIN Users AS u ON u.Id = ug.UserId
JOIN Games AS g ON g.Id = ug.GameId
JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
JOIN Items AS i ON i.Id = ugi.ItemId
GROUP BY u.Username, g.[Name]
HAVING COUNT(i.Id) >= 10
ORDER BY COUNT(i.Id) DESC, [Items Price] DESC, u.Username


