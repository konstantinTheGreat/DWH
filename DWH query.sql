--  Create staging tables:
CREATE TABLE staging_order_details (
    orderid     INT NOT NULL,
    productid   INT NOT NULL,
    unitprice   DECIMAL(10, 2) NOT NULL,
    qty         SMALLINT NOT NULL,
    discount    DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (orderid, productid)
);


CREATE TABLE staging_customers (
    custid       SERIAL PRIMARY KEY,
    companyname  VARCHAR(40) NOT NULL,
    contactname  VARCHAR(30),
    contacttitle VARCHAR(30),
    address      VARCHAR(60),
    city         VARCHAR(15),
    region       VARCHAR(15),
    postalcode   VARCHAR(10),
    country      VARCHAR(15),
    phone        VARCHAR(24),
    fax          VARCHAR(24)
);


CREATE TABLE staging_employees (
    empid            SERIAL PRIMARY KEY,
    lastname         VARCHAR(20) NOT NULL,
    firstname        VARCHAR(10) NOT NULL,
    title            VARCHAR(30),
    titleofcourtesy  VARCHAR(25),
    birthdate        TIMESTAMP,
    hiredate         TIMESTAMP,
    address          VARCHAR(60),
    city             VARCHAR(15),
    region           VARCHAR(15),
    postalcode       VARCHAR(10),
    country          VARCHAR(15),
    phone            VARCHAR(24),
    extension        VARCHAR(4),
    photo            BYTEA,
    notes            TEXT,
    mgrid            INT,
    photopath        VARCHAR(255)
);



CREATE TABLE staging_products (
    productid       SERIAL PRIMARY KEY,
    productname     VARCHAR(40) NOT NULL,
    supplierid      INT,
    categoryid      INT,
    quantityperunit VARCHAR(20),
    unitprice       DECIMAL(10, 2),
    unitsinstock    SMALLINT,
    unitsonorder    SMALLINT,
    reorderlevel    SMALLINT,
    discontinued    CHAR(1) NOT NULL
);



CREATE TABLE staging_categories (
    categoryid   SERIAL PRIMARY KEY,
    categoryname VARCHAR(15) NOT NULL,
    description  TEXT,
    picture      BYTEA
);




CREATE TABLE staging_shippers (
    shipperid   SERIAL PRIMARY KEY,
    companyname VARCHAR(40) NOT NULL,
    phone       VARCHAR(44)
);




CREATE TABLE staging_suppliers (
    supplierid   SERIAL PRIMARY KEY,
    companyname  VARCHAR(40) NOT NULL,
    contactname  VARCHAR(30),
    contacttitle VARCHAR(30),
    address      VARCHAR(60),
    city         VARCHAR(15),
    region       VARCHAR(15),
    postalcode   VARCHAR(10),
    country      VARCHAR(15),
    phone        VARCHAR(24),
    fax          VARCHAR(24),
    homepage     TEXT
);



CREATE TABLE staging_orders(
    orderid        SERIAL PRIMARY KEY NOT NULL,
    custid         VARCHAR(15) NULL,
    empid          INT NULL,
    orderdate      TIMESTAMP NULL,
    requireddate   TIMESTAMP NULL,
    shippeddate    TIMESTAMP NULL,
    shipperid      INT NULL,
    freight        DECIMAL(10, 2) NULL,
    shipname       VARCHAR(40) NULL,
    shipaddress    VARCHAR(60) NULL,
    shipcity       VARCHAR(15) NULL,
    shipregion     VARCHAR(15) NULL,
    shippostalcode VARCHAR(10) NULL,
    shipcountry    VARCHAR(15) NULL
);





-- 2. Dimension tables

CREATE TABLE DimDate (
    DateID SERIAL PRIMARY KEY,
    Date DATE NOT NULL,
    Day INT NOT NULL,
    Month INT NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    WeekOfYear INT NOT NULL
);

CREATE TABLE DimCustomer (
    CustomerID SERIAL PRIMARY KEY,
    CompanyName VARCHAR(40) NOT NULL,
    ContactName VARCHAR(30),
    ContactTitle VARCHAR(30),
    Address VARCHAR(60),
    City VARCHAR(15),
    Region VARCHAR(15),
    PostalCode VARCHAR(10),
    Country VARCHAR(15),
    Phone VARCHAR(24)
);

CREATE TABLE DimEmployee (
    EmployeeID SERIAL PRIMARY KEY,
    LastName VARCHAR(20) NOT NULL,
    FirstName VARCHAR(10) NOT NULL,
    Title VARCHAR(30),
    BirthDate TIMESTAMP,
    HireDate TIMESTAMP,
    Address VARCHAR(60),
    City VARCHAR(15),
    Region VARCHAR(15),
    PostalCode VARCHAR(10),
    Country VARCHAR(15),
    HomePhone VARCHAR(24),
    Extension VARCHAR(4)
);


CREATE TABLE DimCategory (
    CategoryID SERIAL PRIMARY KEY,
    CategoryName VARCHAR(15) NOT NULL,
    Description TEXT
);


CREATE TABLE DimShipper (
    ShipperID SERIAL PRIMARY KEY,
    CompanyName VARCHAR(40) NOT NULL,
    Phone VARCHAR(44)
);


CREATE TABLE DimSupplier (
    SupplierID SERIAL PRIMARY KEY,
    CompanyName VARCHAR(40) NOT NULL,
    ContactName VARCHAR(30),
    ContactTitle VARCHAR(30),
    Address VARCHAR(60),
    City VARCHAR(15),
    Region VARCHAR(15),
    PostalCode VARCHAR(10),
    Country VARCHAR(15),
    Phone VARCHAR(24)
);

CREATE TABLE DimProduct (
    ProductID SERIAL PRIMARY KEY,
    ProductName VARCHAR(40) NOT NULL,
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit VARCHAR(20),
    UnitPrice DECIMAL(10, 2),
    UnitsInStock SMALLINT,
    FOREIGN KEY (SupplierID) REFERENCES DimSupplier(SupplierID),
    FOREIGN KEY (CategoryID) REFERENCES DimCategory(CategoryID)
);

CREATE TABLE FactSales (
    SalesID SERIAL PRIMARY KEY,
    DateID INT,
    CustomerID INT,
    ProductID INT,
    EmployeeID INT,
    CategoryID INT,
    ShipperID INT,
    SupplierID INT,
    QuantitySold INT,
    UnitPrice DECIMAL(10, 2),
    Discount DECIMAL(10, 2),
    TotalAmount DECIMAL(15, 2),
    TaxAmount DECIMAL(15, 2),
    FOREIGN KEY (DateID) REFERENCES DimDate(DateID),
    FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
    FOREIGN KEY (EmployeeID) REFERENCES DimEmployee(EmployeeID),
    FOREIGN KEY (CategoryID) REFERENCES DimCategory(CategoryID),
    FOREIGN KEY (ShipperID) REFERENCES DimShipper(ShipperID),
    FOREIGN KEY (SupplierID) REFERENCES DimSupplier(SupplierID)
);




INSERT INTO staging_customers 
SELECT * FROM Customer;

INSERT INTO staging_categories 
SELECT * FROM Category;

INSERT INTO staging_order_details
SELECT * FROM orderdetail;

INSERT INTO staging_products
SELECT * FROM product;

INSERT INTO staging_shippers
SELECT * FROM shipper;

INSERT INTO staging_suppliers
SELECT * FROM supplier;

INSERT INTO staging_employees
SELECT * FROM employee;

INSERT INTO staging_orders
SELECT * FROM salesorder ;


--- . Transforming the data from and loading it into the respective dimension tables







INSERT INTO DimSupplier (SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone)
SELECT supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone
FROM staging_suppliers;

INSERT INTO DimShipper (ShipperID, CompanyName, Phone)
SELECT shipperid, companyname, phone
FROM staging_shippers;

INSERT INTO DimEmployee (EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, Address, City, Region, PostalCode, Country, HomePhone, Extension)
SELECT empid, lastname, firstname, title, birthdate, hiredate, address, city, region, postalcode, country, phone, extension
FROM staging_employees;

INSERT INTO DimCategory (CategoryID, CategoryName, Description)
SELECT categoryid, categoryname, description
FROM staging_categories;

INSERT INTO DimCustomer (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone) 
SELECT custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone 
FROM staging_customers;

INSERT INTO DimProduct (ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock)
SELECT ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock
FROM staging_products;

INSERT INTO DimDate (Date, Day, Month, Year, Quarter, WeekOfYear)
SELECT
    DISTINCT DATE(orderdate) AS Date,
    EXTRACT(DAY FROM DATE(orderdate)) AS Day,
    EXTRACT(MONTH FROM DATE(orderdate)) AS Month,
    EXTRACT(YEAR FROM DATE(orderdate)) AS Year,
    EXTRACT(QUARTER FROM DATE(orderdate)) AS Quarter,
    EXTRACT(WEEK FROM DATE(orderdate)) AS WeekOfYear
FROM
    staging_orders;


INSERT INTO FactSales (DateID, CustomerID, ProductID, EmployeeID, CategoryID, ShipperID, SupplierID, QuantitySold, UnitPrice, Discount, TotalAmount, TaxAmount) 
SELECT
    d.DateID,   
    c.custid,  
    p.ProductID,  
    e.empid,  
    cat.CategoryID,  
    s.ShipperID,  
    sup.SupplierID, 
    od.qty, 
    od.UnitPrice, 
    od.Discount,    
    (od.qty * od.UnitPrice - od.Discount) AS TotalAmount,
    (od.qty * od.UnitPrice - od.Discount) * 0.1 AS TaxAmount     
FROM staging_order_details od 
JOIN staging_orders o ON od.OrderID = o.OrderID 
JOIN staging_customers c ON o.custid = c.custid::varchar 
JOIN staging_products p ON od.ProductID = p.ProductID  
LEFT JOIN staging_employees e ON o.empid = e.empid  
LEFT JOIN staging_categories cat ON p.CategoryID = cat.CategoryID 
LEFT JOIN staging_shippers s ON o.shipperid = s.ShipperID  
LEFT JOIN staging_suppliers sup ON p.SupplierID = sup.SupplierID
LEFT JOIN DimDate d ON o.orderdate = d.Date;


-- 6) validation
--checking record counts
SELECT 'DimCustomer', COUNT(*) AS RecordCount FROM DimCustomer;
SELECT 'DimProduct', COUNT(*) AS RecordCount FROM DimProduct;
SELECT 'DimEmployee', COUNT(*) AS RecordCount FROM DimEmployee;
SELECT 'DimCategory', COUNT(*) AS RecordCount FROM DimCategory;
SELECT 'DimShipper', COUNT(*) AS RecordCount FROM DimShipper;
SELECT 'DimSupplier', COUNT(*) AS RecordCount FROM DimSupplier;
SELECT 'DimDate', COUNT(*) AS RecordCount FROM DimDate;
SELECT 'FactSales', COUNT(*) AS RecordCount FROM FactSales;

--missing references in FactSales( if there are an y)
SELECT 'FactSales - Missing Customer References' AS TableName
FROM FactSales 
WHERE NOT EXISTS (SELECT 1 FROM DimCustomer WHERE FactSales.CustomerID = DimCustomer.CustomerID)
LIMIT 1;

--aggregation check
SELECT SUM(TotalAmount) AS TotalSalesAmount
FROM FactSales;


--comparing columns from source and destination tables
SELECT 'Source vs DimCustomer', 
       COUNT(*) AS TotalRecords,
       SUM(CASE WHEN s.companyname = d.companyname THEN 1 ELSE 0 END) AS MatchingCompanyNames,
       SUM(CASE WHEN s.contactname = d.contactname THEN 1 ELSE 0 END) AS MatchingContactNames
FROM staging_customers s
JOIN DimCustomer d ON s.custid = d.CustomerID;



