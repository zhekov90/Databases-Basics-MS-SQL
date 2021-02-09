
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


--Problem 4.	* User in Games with Their Statistics

SELECT u.Username AS [Username], 
       g.Name AS [Game], 
       MAX(c.Name) AS [Character], 
       SUM(si.Strength) + MAX(sgt.Strength) + MAX(sc.Strength) AS [Strength], 
       SUM(si.Defence) + MAX(sgt.Defence) + MAX(sc.Defence) AS [Defence], 
       SUM(si.Speed) + MAX(sgt.Speed) + MAX(sc.Speed) AS [Speed], 
       SUM(si.Mind) + MAX(sgt.Mind) + MAX(sc.Mind) AS [Mind], 
       SUM(si.Luck) + MAX(sgt.Luck) + MAX(sc.Luck) AS [Luck]
FROM Users AS u
     JOIN UsersGames AS ug ON ug.UserId = u.Id
     JOIN Games AS g ON g.Id = ug.GameId
     JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
     JOIN [Statistics] AS sgt ON sgt.id = gt.BonusStatsId
     JOIN Characters AS c ON c.Id = ug.CharacterId
     JOIN [Statistics] AS sc ON sc.id = c.StatisticId
     JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
     JOIN Items AS i ON i.Id = ugi.ItemId
     JOIN [Statistics] AS si ON si.id = i.StatisticId
GROUP BY u.Username, g.[Name]
ORDER BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC


