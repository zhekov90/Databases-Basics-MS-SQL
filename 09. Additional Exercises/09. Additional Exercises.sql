
--Problem 1.	Number of Users for Email Provider

SELECT SUBSTRING([Email], CHARINDEX('@', [Email]) + 1, LEN([Email])) AS [Email Provider], COUNT(*) AS [Number Of Users] FROM Users
GROUP BY SUBSTRING([Email], CHARINDEX('@', [Email]) + 1, LEN([Email]))
ORDER BY [Number Of Users] DESC, [Email Provider]


