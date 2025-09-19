

CREATE TABLE Item (
	  ItemName VARCHAR (30) NOT NULL,
  ItemType CHAR(1) NOT NULL,
  ItemColour VARCHAR(10),
  PRIMARY KEY (ItemName));

CREATE TABLE Employee (
  EmployeeNumber SMALLINT UNSIGNED NOT NULL ,
  EmployeeName VARCHAR(10) NOT NULL ,
  EmployeeSalary INTEGER UNSIGNED NOT NULL ,
  DepartmentName VARCHAR(10) NOT NULL REFERENCES Department,
  BossNumber SMALLINT UNSIGNED NOT NULL REFERENCES Employee,
  PRIMARY KEY (EmployeeNumber));

CREATE TABLE Department (
  DepartmentName VARCHAR(10) NOT NULL,
  DepartmentFloor SMALLINT UNSIGNED NOT NULL,
  DepartmentPhone SMALLINT UNSIGNED NOT NULL,
  EmployeeNumber SMALLINT UNSIGNED NOT NULL REFERENCES 
    Employee,
  PRIMARY KEY (DepartmentName));

CREATE TABLE Sale (
  SaleNumber INTEGER UNSIGNED NOT NULL,
  SaleQuantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  ItemName VARCHAR(30) NOT NULL REFERENCES Item,
  DepartmentName VARCHAR(10) NOT NULL REFERENCES Department,
  PRIMARY KEY (SaleNumber));

CREATE TABLE Supplier (
  SupplierNumber INTEGER UNSIGNED NOT NULL,
  SupplierName VARCHAR(30) NOT NULL,
  PRIMARY KEY (SupplierNumber));

CREATE TABLE Delivery (
  DeliveryNumber INTEGER UNSIGNED NOT NULL,
  DeliveryQuantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  ItemName VARCHAR(30) NOT NULL REFERENCES Item,
  DepartmentName VARCHAR(10) NOT NULL REFERENCES Department,
  SupplierNumber INTEGER UNSIGNED NOT NULL REFERENCES  
     Supplier,
  PRIMARY KEY (DeliveryNumber));

-- using the data in the text files, insert into the tables this information


-- -----------------------------------
-- Check
-- -----------------------------------
. schema
. table

-- -----------------------------------
-- Querying multiple tables
-- -----------------------------------

-- 1. names of employees in the Marketing department
SELECT EmployeeName 
FROM Employee 
WHERE DepartmentName = 'Marketing';

-- 2. items sold by the departments on the second floor
SELECT ItemName
FROM Sale JOIN Department ON Sale.DepartmentName = Department.DepartmentName 
WHERE DepartmentFloor='2';

-- alternative:
SELECT DISTINCT ItemName
FROM Sale, Department 
WHERE Sale.DepartmentName = Department.DepartmentName 
AND Department.DepartmentFloor=2;

-- try NATURAL JOIN (joins based on columns of same name)
SELECT DISTINCT ItemName
FROM (Sale NATURAL JOIN Department)
WHERE Department.DepartmentFloor=2;

-- try JOIN (without ON, will perform Cartesian product => not what we want here)
SELECT DISTINCT ItemName
FROM (Sale JOIN Department)
WHERE Department.DepartmentFloor=2;

-- 3. Identify by floor the items available on floors other than the second floor
SELECT DISTINCT DepartmentFloor, ItemName 
FROM Department, Sale 
WHERE Department.DepartmentName = Sale.DepartmentName
AND Department.DepartmentFloor <> 2;

-- solution:
SELECT DISTINCT ItemName, Department.DepartmentFloor AS 'On Floor'
FROM Delivery, Department
WHERE Delivery.DepartmentName = Department.DepartmentName
AND Department.DepartmentFloor <> 2
ORDER BY Department.DepartmentFloor, ItemName;

-- 4. Find the average salary of the employees in the Clothes department





-- 5. Find, for each department, the average salary of the employees in that department and report by descending salary.

-- 6. List the items delivered by exactly one supplier (i.e. the items always delivered by the same supplier).

-- 7. List the suppliers that deliver at least 10 items.

-- 8. Count the number of direct employees of each manager

-- 9. Find, for each department that sells items of type 'E' the average salary of the employees.

-- 10. Find the total number of items of type 'E' sold by departments on the second floor

-- 11. What is the average delivery quantity of items of type 'N' delivered by each company?



-- -----------------------------------
-- Nested Queries
-- -----------------------------------


-- 1. What are the names of items sold by departments on the second floor? This was previously


-- 2. Find the salary of Clare's manager.


-- 3. Find the name and salary of the managers with more than two employees


-- 4. List the names of the employees who earn more than any employee in the Marketing department


-- 5. Among all the departments with a total salary greater than £25000, find the departments that sell Stetsons.


-- 6. Find the suppliers that deliver compasses and at least one other kind of item


-- 7. Find the suppliers that deliver compasses and at least three other kinds of item


-- 8. List the departments for which each item delivered to the department is delivered to some other department as well





