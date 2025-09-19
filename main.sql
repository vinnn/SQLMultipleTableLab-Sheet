

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
SELECT AVG(EmployeeSalary) AS 'Avg Salary' 
FROM Employee
WHERE Employee.DepartmentName = 'Clothes';


-- 5. Find, for each department, the average salary of the employees in that 
-- department and report by descending salary.

SELECT DepartmentName, AVG(EmployeeSalary) AS 'Avg Salary'
FROM Employee
GROUP BY DepartmentName
ORDER BY AVG(EmployeeSalary) DESC;

-- see the following solution (!!!double quotes!!!):
SELECT DepartmentName, AVG(EmployeeSalary) AS 'Avg Salary'
FROM Employee
GROUP BY DepartmentName
ORDER BY "Avg Salary" DESC;


-- 6. List the items delivered by exactly one supplier (i.e. the items 
-- always delivered by the same supplier).
SELECT ItemName
FROM Delivery
GROUP BY ItemName
HAVING COUNT(DISTINCT SupplierNumber) = 1;
-- NOTE: cannot use COUNT() in a WHERE


-- 7. List the suppliers that deliver at least 10 items.
SELECT SupplierName
FROM Supplier, Delivery
WHERE Supplier.SupplierNumber = Delivery.SupplierNumber
GROUP BY SupplierName
HAVING COUNT(DISTINCT ItemName) >= 10;

-- solution (same result but showing supplier number as well):
SELECT Supplier.SupplierNumber, Supplier.SupplierName
FROM Delivery, Supplier
WHERE Delivery.SupplierNumber = Supplier.SupplierNumber
GROUP BY Supplier.SupplierNumber, Supplier.SupplierName
HAVING COUNT(DISTINCT Delivery.ItemName) >= 10;


-- 8. Count the number of direct employees of each manager
SELECT BossNumber, COUNT(EmployeeNumber)
FROM Employee
GROUP BY BossNumber;

-- solution:
SELECT Boss.EmployeeNumber, Boss.EmployeeName, COUNT(*) AS 'Employees'
FROM Employee AS Worker, Employee AS Boss
WHERE Worker.BossNumber = Boss.EmployeeNumber
GROUP BY Boss.EmployeeNumber, Boss.EmployeeName;


-- 9. Find, for each department that sells items of type 'E' the 
-- average salary of the employees.
SELECT Employee.DepartmentName, AVG(Employee.EmployeeSalary) AS 'Avg Salary'
FROM Employee, Sale, Item
WHERE Item.ItemType = 'E'
AND Item.ItemName = Sale.ItemName
AND Sale.DepartmentName = Employee.DepartmentName
GROUP BY Employee.DepartmentName; 

-- solution (same result):
SELECT Department.DepartmentName, AVG(EmployeeSalary) AS 'Average Salary'
FROM Employee, Department, Sale, Item
WHERE Employee.DepartmentName = Department.DepartmentName
AND Department.DepartmentName = Sale.DepartmentName
AND Sale.ItemName = Item.ItemName
AND ItemType='E'
GROUP BY Department.DepartmentName;


-- 10. Find the total number of items of type 'E' sold by 
-- departments on the second floor
SELECT SUM(Sale.SaleQuantity)
FROM Item, Sale, Department
WHERE Item.ItemType = 'E' 
AND Item.ItemName = Sale.ItemName
AND Sale.DepartmentName = Department.DepartmentName
AND Department.DepartmentFloor = 2
GROUP BY Department.DepartmentFloor;

-- solution (same result):
SELECT SUM(SaleQuantity) AS 'Number of Items'
FROM Department, Sale, Item
WHERE Department.DepartmentName = Sale.DepartmentName
AND Sale.ItemName = Item.ItemName
AND ItemType = 'E' 
AND DepartmentFloor = '2';


-- 11. What is the average delivery quantity of items of 
-- type 'N' delivered by each company?
SELECT Supplier.SupplierName, AVG(Delivery.DeliveryQuantity)
FROM Delivery, Item, Supplier
WHERE Delivery.ItemName = Item.ItemName
AND Item.ItemType = 'N'
AND Delivery.SupplierNumber = Supplier.SupplierNumber
GROUP BY Delivery.SupplierNumber;

-- solution (question understood differently):
SELECT Delivery.SupplierNumber, SupplierName, Delivery.ItemName, 
AVG(Delivery.DeliveryQuantity) AS 'Avg Qty'
FROM ((Delivery NATURAL JOIN Supplier) NATURAL JOIN Item)
WHERE Item.ItemType = 'N'
GROUP BY Delivery.SupplierNumber, SupplierName, Delivery.ItemName
ORDER BY Delivery.SupplierNumber, SupplierName, "Avg Qty" DESC, Delivery.ITemName;


-- -----------------------------------
-- Nested Queries
-- -----------------------------------

-- 1. What are the names of items sold by departments on the second floor? This 
-- was previously solved in the preceding section by use of a join. However it could
-- be more efficiently solved by using an inner query

-- no nesting
SELECT DISTINCT Sale.ItemName
FROM Sale, Department
WHERE Sale.DepartmentName = Department.DepartmentName
AND Department.DepartmentFloor = 2;

-- nested
SELECT DISTINCT ItemName
FROM Sale
WHERE DepartmentName
IN (
  SELECT DepartmentName
  FROM Department
  WHERE DepartmentFloor = 2
); 


-- 2. Find the salary of Clare's manager.
SELECT EmployeeSalary
FROM Employee
WHERE EmployeeNumber 
IN (
  SELECT BossNumber
  FROM Employee
  WHERE EmployeeName='Clare'
);

-- solution (same result):
SELECT EmployeeName, EmployeeSalary
FROM Employee
WHERE EmployeeNumber 
= (
  SELECT BossNumber
  FROM Employee
  WHERE EmployeeName='Clare'
);


-- 3. Find the name and salary of the 
-- managers with more than two employees
SELECT EmployeeName, EmployeeSalary
FROM Employee
WHERE EmployeeNumber 
IN (
  SELECT BossNumber
  FROM Employee
  GROUP BY BossNumber
  HAVING COUNT(EmployeeName) > 2
);

-- solution (same result):
SELECT EmployeeName, EmployeeSalary
FROM Employee
WHERE EmployeeNumber 
IN (
  SELECT BossNumber
  FROM Employee
  GROUP BY BossNumber
  HAVING COUNT(*) > 2
);


-- 4. List the names of the employees 
-- who earn more than any employee in 
-- the Marketing department
SELECT EmployeeName
FROM Employee
WHERE EmployeeSalary 
> (
  SELECT MAX(EmployeeSalary)
  FROM Employee
  WHERE DepartmentName = 'Marketing'
);

-- 5. Among all the departments with a total salary greater than £25000, find 
-- the departments that sell Stetsons.
SELECT DepartmentName
FROM Sale
WHERE ItemName = 'Stetsons'
AND DepartmentName 
IN (
  SELECT DepartmentName
  FROM Employee
  GROUP BY DepartmentName
  HAVING SUM(EmployeeSalary) > 25000
);


-- 6. Find the suppliers that deliver compasses and at least one other kind of item
SELECT SupplierName
FROM Supplier
WHERE SupplierNumber 
IN (
  SELECT SupplierNumber
  FROM Delivery
  WHERE ItemName='Compass'
  AND 1
  <= (
    SELECT COUNT(DISTINCT ItemName)
    FROM Delivery
    WHERE ItemName <> 'Compass'
  )
);

-- other solution:
SELECT DISTINCT Delivery.SupplierNumber, Supplier.SupplierName
FROM (Supplier NATURAL JOIN Delivery)
WHERE ItemName <> 'Compass'
AND SupplierNumber
IN (
  SELECT SupplierNumber
  FROM Delivery
  WHERE ItemName = 'Compass'
);


-- 7. Find the suppliers that deliver compasses and at least three other 
-- kinds of item








-- 8. List the departments for which each item delivered to the department is 
-- delivered to some other department as well





