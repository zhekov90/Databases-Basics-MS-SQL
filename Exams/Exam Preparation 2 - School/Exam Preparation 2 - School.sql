
--1. Database Design

CREATE TABLE Subjects
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
Name NVARCHAR(20) NOT NULL,
Lessons INT NOT NULL,
)

CREATE TABLE Exams
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
Date DATE,
SubjectId INT FOREIGN KEY REFERENCES Subjects(Id)
)

CREATE TABLE Students
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
FirstName NVARCHAR(20) NOT NULL,
MiddleName NVARCHAR(20),
LastName NVARCHAR(20) NOT NULL,
Age INT NOT NULL CHECK (Age > 0),
Address NVARCHAR(30),
Phone NVARCHAR(10)
)

CREATE TABLE Teachers
(
Id INT PRIMARY KEY IDENTITY NOT NULL,
FirstName NVARCHAR(20) NOT NULL,
LastName NVARCHAR(20) NOT NULL,
Address NVARCHAR(20) NOT NULL,
Phone NVARCHAR(10),
SubjectId INT FOREIGN KEY REFERENCES Subjects(Id)
)

CREATE TABLE StudentsExams
(
StudentId INT NOT NULL,
ExamId INT NOT NULL,
Grade DECIMAL(15,2) NOT NULL CHECK (Grade >= 2 AND Grade <= 6),

CONSTRAINT PK_StudentsExams PRIMARY KEY (StudentId, ExamId),

CONSTRAINT FK_StudentsExams_Students FOREIGN KEY (StudentId) REFERENCES Students (Id),
CONSTRAINT FK_StudentsExams_Exams FOREIGN KEY (ExamId) REFERENCES Exams (Id),
)

CREATE TABLE StudentsTeachers
(

StudentId INT NOT NULL,
TeacherId INT NOT NULL,

CONSTRAINT PK_StudentsTeachers PRIMARY KEY (StudentId, TeacherId),
CONSTRAINT FK_StudentsTeachers_Students FOREIGN KEY (StudentId) REFERENCES Students (Id),
CONSTRAINT FK_StudentsTeachers_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers (Id),
)

CREATE TABLE StudentsSubjects
(
Id INT PRIMARY KEY IDENTITY,
StudentId INT NOT NULL,
SubjectId INT NOT NULL,
Grade DECIMAL(15,2) NOT NULL  CHECK (Grade >= 2 AND Grade <= 6),

CONSTRAINT FK_StudentsSubjects_Students FOREIGN KEY (StudentId) REFERENCES Students (Id),
CONSTRAINT FK_StudentsSubjects_Subjects FOREIGN KEY (SubjectId) REFERENCES Subjects (Id),
)


--2. Insert

INSERT INTO Teachers(FirstName, LastName,	[Address],	Phone,	SubjectId)
VALUES
('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
('Gerrard', 'Lowin', '370 Talisman Plaza', '3324874824', 2),
('Merrile', 'Lambdin', '81 Dahle Plaza	', '4373065154', 5),
('Bert', 'Ivie', '2 Gateway Circle', '4409584510', 4)

INSERT INTO Subjects([Name], Lessons)
VALUES
('Geometry', 12),
('Health', 10),
('Drama', 7),
('Sports', 9)


--3. Update

UPDATE StudentsSubjects
SET Grade = 6.00
WHERE (SubjectId = 1 OR SubjectId = 2) AND Grade >= 5.50


--4. Delete

DELETE FROM StudentsTeachers
WHERE TeacherId IN (SELECT Id FROM Teachers WHERE Phone LIKE '%72%')

DELETE Teachers
WHERE Phone LIKE '%72%'


--5. Teen Students

SELECT FirstName, LastName, Age FROM Students
WHERE Age >= 12
ORDER BY FirstName, LastName


--6. Students Teachers

SELECT s.FirstName, s.LastName, COUNT(TeacherId) AS TeachersCount FROM StudentsTeachers AS st
JOIN Students AS s ON s.Id = st.StudentId
JOIN Teachers AS t ON t.Id = st.TeacherId
GROUP BY s.FirstName, s.LastName


--7. Students to Go

SELECT s.FirstName + ' ' + s.LastName AS [Full Name] FROM StudentsExams AS se
RIGHT JOIN Students AS s ON s.Id = se.StudentId
FULL JOIN Exams AS e ON e.Id = se.ExamId
WHERE se.ExamId IS NULL AND s.FirstName + ' ' + s.LastName IS NOT NULL
ORDER BY [Full Name]


--8. Top Students

SELECT TOP(10) s.FirstName, s.LastName, FORMAT(AVG(se.Grade), 'N2') AS Grade  FROM Students AS s
JOIN StudentsExams AS se ON se.StudentId = s.Id
GROUP BY s.FirstName, s.LastName
ORDER BY Grade DESC, s.FirstName, s.LastName


--9. Not So In The Studying

SELECT s.FirstName + ISNULL(' ' + s.MiddleName, '') + ' ' + s.LastName AS [Full Name] FROM Students AS s
FULL JOIN StudentsSubjects AS ss ON ss.StudentId = s.Id
WHERE ss.SubjectId IS NULL
ORDER BY [Full Name]


--10. Average Grade per Subject

SELECT s.[Name], AVG(ss.Grade) AS AverageGrade FROM Subjects AS s
JOIN Exams AS e ON e.SubjectId = s.Id
JOIN StudentsSubjects AS ss ON ss.SubjectId = s.Id
GROUP BY s.[Name], ss.SubjectId
ORDER BY ss.SubjectId


--11. Exam Grades
GO

CREATE FUNCTION udf_ExamGradesToUpdate(@studentId INT, @grade DECIMAL(15,2))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @studentExist INT = (SELECT TOP(1) StudentId FROM StudentsExams WHERE StudentId = @studentId)

	IF @studentExist IS NULL
	BEGIN
		RETURN ('The student with provided id does not exist in the school!')
	END

	IF @grade > 6.00
	BEGIN
		RETURN ('Grade cannot be above 6.00!')
	END

	DECLARE @studentFirstName NVARCHAR(20) = (SELECT TOP(1) FirstName FROM Students WHERE Id = @studentId);
	DECLARE @biggestGrade DECIMAL(15,2) = @grade + 0.50;
	DECLARE @count INT = (SELECT Count(Grade) FROM StudentsExams
		WHERE StudentId = @studentId AND Grade >= @grade AND Grade <= @biggestGrade)
	RETURN ('You have to update ' + CAST(@count AS nvarchar(10)) + ' grades for the student ' + @studentFirstName)
END

SELECT dbo.udf_ExamGradesToUpdate(12, 6.20)
--should return
--Grade cannot be above 6.00!
SELECT dbo.udf_ExamGradesToUpdate(12, 5.50)
--should return
--You have to update 2 grades for the student Agace
SELECT dbo.udf_ExamGradesToUpdate(121, 5.50)
--should return
--The student with provided id does not exist in the school!


--12. Exclude from school
GO 

CREATE PROC usp_ExcludeFromSchool @StudentId INT
AS 
DECLARE @TargetStudentId INT = (SELECT Id FROM Students WHERE Id = @StudentId)

IF (@TargetStudentId IS NULL)
BEGIN
	RAISERROR('This school has no student with the provid1ed id!', 16, 1)
	RETURN
END

	DELETE FROM StudentsExams
	WHERE StudentId = @StudentToBeDeleted

	DELETE FROM StudentsSubjects
	WHERE StudentId = @StudentToBeDeleted

	DELETE FROM StudentsTeachers
	WHERE StudentId = @StudentToBeDeleted

	DELETE FROM Students
	WHERE Id = @StudentToBeDeleted

END

EXEC usp_ExcludeFromSchool 1
SELECT COUNT(*) FROM Students
--should return 119

EXEC usp_ExcludeFromSchool 301
--should return
--This school has no student with the provided id!