# README 

# SSIS ETL Project

## Overview
This project demonstrates an ETL (Extract, Transform, Load) process using SQL Server Integration Services (SSIS). The objective is to extract data from a CSV file, transform it to ensure data quality, and load it into a SQL Server production table via a staging table.

## Setup Instructions

### Prerequisites
- SQL Server Management Studio (SSMS)
- Visual Studio 2022 with SSIS extension
- Git

### Repository Structure
- `data/`: Contains the CSV data file.
- `docs/`: Contains documentation files including this README.
- `src/`: Contains miscellaneous source files.
- `sql/`: Contains SQL scripts for the ETL process.

### Cloning the Repository
1. Clone the repository from GitHub:
   ```sh
   git clone https://github.com/yourusername/your-repo.git

2. Navgate to the project directory:
   cd your-repo

# Running the ETL Process
## Step 1: Setting Up the Database
1. Open SQL Server Management Studio (SSMS).
2. Run the SQL script SQLScripts/SQLQuery.sql to set up the database, schemas, and tables:
-- Run the following in SSMS
USE [KoreAssignment_{Mehreen_AbdulRahman}]
GO

...

-- Run the query till here
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


# Step 2: Loading Data into Staging Table
1. Use SSIS to load data from the CSV file located in the data folder into the stg.Users table.
2. After successful execution, check the data in the stg.Users table in SSMS to ensure it matches the expected values by running the "SELECT * FROM stg.Users;" query.

# Step 3: Data Cleaning and Transformation
1. Run the data cleaning and transformation steps included in the SQLScripts/SQLQuery.sql script to remove duplicates, handle null values, and correct data formats.

# Step 4: Incremental Load to Production Table
Run the incremental load process to insert new records and update existing records in the prod.Users table. This process is also included in the SQLScripts/SQLQuery.sql script.

# Data Cleaning and Transformation
The data cleaning and transformation steps include:
Removing duplicate records.
Handling null and incorrect age values.
Correcting invalid date formats.
Validating email formats.

# Incremental Load Process
The incremental load process ensures that new records are inserted into the production table and existing records are updated accordingly.

# Execution Report
## Records Processed
Total records processed: 29
Records inserted: 9
Records updated: 26
Records excluded: 3

# Challenges Encountered
Duplicate UserID records
Null values in critical fields
Invalid date formats were found in RegistrationDate and LastLoginDate fields.
Incorrect email formats were also identified.
Non-numeric values found in the Age field.

# Solutions
Removed records with null UserID values to maintain data integrity.
Used CTE to identify and remove duplicate records.
Used TRY_CAST to handle invalid date formats and set them to NULL.
Used pattern matching to validate email formats and set invalid emails to NULL.
Applied data transformation to convert non-numeric and negative Age values to NULL.

# Future Improvements
Automate the data loading process using SSIS packages.
Implement additional data validation checks.
Create more testing data

# References
https://docs.microsoft.com/en-us/sql/integration-services/sql-server-integration-services
https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms
