
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


