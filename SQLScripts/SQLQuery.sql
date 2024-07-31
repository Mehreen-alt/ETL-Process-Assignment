-- TODO: Replace {FirstName} and {LastName} with your actual first and last names before running this script
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'KoreAssignment_{Mehreen_AbdulRahman}')
BEGIN
    CREATE DATABASE [KoreAssignment_{Mehreen_AbdulRahman}];
END
GO

USE [KoreAssignment_{Mehreen_AbdulRahman}]
GO

-- Check and create stg schema if it does not exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'stg')
BEGIN
    EXEC('CREATE SCHEMA stg');
END
GO

-- Check and create prod schema if it does not exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'prod')
BEGIN
    EXEC('CREATE SCHEMA prod');
END
GO

-- Check and create stg.Users table if it does not exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'stg.Users') AND type in (N'U'))
BEGIN
    CREATE TABLE stg.Users (
        StgID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT,
        FullName NVARCHAR(255),
        Age INT,
        Email NVARCHAR(255),
        RegistrationDate DATE,
        LastLoginDate DATE,
        PurchaseTotal FLOAT
    );
END
GO

-- Check and create prod.Users table if it does not exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'prod.Users') AND type in (N'U'))
BEGIN
    CREATE TABLE prod.Users (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT,
        FullName NVARCHAR(255),
        Age INT,
        Email NVARCHAR(255),
        RegistrationDate DATE,
        LastLoginDate DATE,
        PurchaseTotal FLOAT,
        RecordLastUpdated DATETIME DEFAULT GETDATE()
    );
END
GO


IF (SELECT COUNT(*) FROM prod.Users) = 0
BEGIN
	INSERT INTO prod.Users (UserID, FullName, Age, Email, RegistrationDate, LastLoginDate, PurchaseTotal)
	VALUES
	(101, 'John Doe', 30, 'johndoe@example.com', '2021-01-10', '2023-03-01', 150.00),
	(102, 'Jane Smith', 25, 'janesmith@example.com', '2020-05-15', '2023-02-25', 200.00),
	(103, 'Emily Johnson', 22, 'emilyjohnson@example.com', '2019-03-23', '2023-01-30', 120.50),
	(104, 'Michael Brown', 35, 'michaelbrown@example.com', '2018-07-18', '2023-02-20', 300.75),
	(105, 'Jessica Garcia', 28, 'jessicagarcia@example.com', '2022-08-05', '2023-02-18', 180.25),
	(106, 'David Miller', 40, 'davidmiller@example.com', '2017-12-12', '2023-02-15', 220.40),
	(107, 'Sarah Martinez', 33, 'sarahmartinez@example.com', '2018-11-30', '2023-02-10', 140.60),
	(108, 'James Taylor', 29, 'jamestaylor@example.com', '2019-06-22', '2023-02-05', 210.00),
	(109, 'Linda Anderson', 27, 'lindaanderson@example.com', '2021-04-16', '2023-01-25', 165.95),
	(110, 'Robert Wilson', 31, 'robertwilson@example.com', '2020-02-20', '2023-01-20', 175.00);
END


SELECT * FROM stg.Users;

-- if values dont load truncate and then reload
TRUNCATE TABLE stg.Users 


-- Remove duplicates based on UserID
WITH CTE AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY StgID) AS rn
    FROM 
        stg.Users
)
DELETE FROM CTE WHERE rn > 1;



-- Update null or incorrect age values (replace 'null' and non-numeric values with NULL)
UPDATE stg.Users
SET Age = CASE 
    WHEN TRY_CAST(Age AS INT) IS NULL THEN NULL
    WHEN Age < 0 THEN NULL 
    ELSE Age 
    END;


-- Handle invalid RegistrationDate formats (invalid dates are set to NULL)
UPDATE stg.Users
SET RegistrationDate = CASE 
    WHEN TRY_CAST(RegistrationDate AS DATE) IS NULL THEN NULL
    ELSE RegistrationDate 
    END;

-- Handle invalid LastLoginDate formats (invalid dates are set to NULL)
UPDATE stg.Users
SET LastLoginDate = CASE 
    WHEN TRY_CAST(LastLoginDate AS DATE) IS NULL THEN NULL
    ELSE LastLoginDate 
    END;


-- Correct email format (set to NULL if invalid)
UPDATE stg.Users
SET Email = NULL
WHERE Email NOT LIKE '%_@__%.__%';

-- Insert cleaned data into prod.Users table
INSERT INTO prod.Users (UserID, FullName, Age, Email, RegistrationDate, LastLoginDate, PurchaseTotal)
SELECT 
    UserID, 
    FullName, 
    Age, 
    Email, 
    RegistrationDate, 
    LastLoginDate, 
    PurchaseTotal
FROM 
    stg.Users
WHERE
    UserID IS NOT NULL
    AND FullName IS NOT NULL
    AND Age IS NOT NULL
    AND Email IS NOT NULL
    AND RegistrationDate IS NOT NULL
    AND LastLoginDate IS NOT NULL;

-- check the whole table
SELECT * FROM prod.Users;

-- check for duplicates
SELECT UserID, COUNT(*)
FROM prod.Users
GROUP BY UserID
HAVING COUNT(*) > 1;

-- check for null
SELECT *
FROM prod.Users
WHERE 
    UserID IS NULL OR
    FullName IS NULL OR
    Age IS NULL OR
    Email IS NULL OR
    RegistrationDate IS NULL OR
    LastLoginDate IS NULL;

-- Remove duplicates based on UserID in prod.Users
WITH CTE AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY ID) AS rn
    FROM 
        prod.Users
)
DELETE FROM CTE WHERE rn > 1;


SELECT * FROM prod.Users;


-- Identify new records that do not exist in prod.Users
INSERT INTO prod.Users (UserID, FullName, Age, Email, RegistrationDate, LastLoginDate, PurchaseTotal)
SELECT 
    s.UserID, 
    s.FullName, 
    s.Age, 
    s.Email, 
    s.RegistrationDate, 
    s.LastLoginDate, 
    s.PurchaseTotal
FROM 
    stg.Users s
LEFT JOIN prod.Users p ON s.UserID = p.UserID
WHERE 
    p.UserID IS NULL
    AND s.UserID IS NOT NULL
    AND s.FullName IS NOT NULL
    AND s.Age IS NOT NULL
    AND s.Email IS NOT NULL
    AND s.RegistrationDate IS NOT NULL
    AND s.LastLoginDate IS NOT NULL;


-- Update existing records in prod.Users
UPDATE p
SET 
    p.FullName = s.FullName, 
    p.Age = s.Age, 
    p.Email = s.Email, 
    p.RegistrationDate = s.RegistrationDate, 
    p.LastLoginDate = s.LastLoginDate, 
    p.PurchaseTotal = s.PurchaseTotal,
    p.RecordLastUpdated = GETDATE()
FROM 
    stg.Users s
INNER JOIN prod.Users p ON s.UserID = p.UserID
WHERE 
    s.UserID IS NOT NULL
    AND s.FullName IS NOT NULL
    AND s.Age IS NOT NULL
    AND s.Email IS NOT NULL
    AND s.RegistrationDate IS NOT NULL
    AND s.LastLoginDate IS NOT NULL;



SELECT * FROM prod.Users;


