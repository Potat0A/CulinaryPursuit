/* =========================================
   USERS
========================================= */
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(500) NOT NULL,
    UserType NVARCHAR(20) NOT NULL
        CHECK (UserType IN ('Customer', 'Restaurant', 'Admin')),
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastLoginDate DATETIME NULL
);
GO

/* =========================================
   CUSTOMERS
========================================= */
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    Address NVARCHAR(500) NULL,
    ProfilePicture VARBINARY(MAX) NULL,
    RewardPoints INT NOT NULL DEFAULT 0,
    TotalOrders INT NOT NULL DEFAULT 0,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Customers_Users
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

/* =========================================
   RESTAURANTS
========================================= */
CREATE TABLE Restaurants (
    RestaurantID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    ChefName NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    Address NVARCHAR(500) NOT NULL,
    CuisineType NVARCHAR(100) NOT NULL,
    Logo VARBINARY(MAX) NULL,
    Banner VARBINARY(MAX) NULL,
    Rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    TotalReviews INT NOT NULL DEFAULT 0,
    ApprovalStatus NVARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (ApprovalStatus IN ('Pending','Approved','Rejected','Suspended')),
    IsActive BIT NOT NULL DEFAULT 1,
    OpeningHours NVARCHAR(500) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ApprovedDate DATETIME NULL,

    CONSTRAINT FK_Restaurants_Users
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

/* =========================================
   MENU ITEMS
========================================= */
CREATE TABLE MenuItems (
    MenuItemID INT IDENTITY(1,1) PRIMARY KEY,
    RestaurantID INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    Price DECIMAL(10,2) NOT NULL,
    Image VARBINARY(MAX) NULL,
    Category NVARCHAR(100) NULL,
    IsAvailable BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_MenuItems_Restaurants
        FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID)
);
GO

/* =========================================
   ORDERS
========================================= */
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    RestaurantID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    FinalAmount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending',

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Orders_Restaurants
        FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID)
);
GO

INSERT INTO Users
(Email, PasswordHash, UserType, IsActive, CreatedDate, LastLoginDate)
VALUES
-- Admin
('admin@culinarypursuit.com',
 'Z0K7yW30tJfrMc=',
 'Admin',
 1,
 '2025-12-19 18:07:31',
 NULL),

-- Customer
('shanjevisty@gmail.com',
 '73l8gRjwLtfklgfdXT+MdiMEjwGPVMSylxe16iYpk8=',
 'Customer',
 1,
 '2025-12-19 18:49:21',
 NULL),

-- Restaurant
('chef@kitchen.com',
 '73l8gRjwLtfklgfdXT+MdiMEjwGPVMSylxe16iYpk8=',
 'Restaurant',
 1,
 '2025-12-19 18:58:09',
 NULL),

-- Restaurant (testing)
('testing@testing.com',
 '73l8gRjwLtfklgfdXT+MdiMEjwGPVMSylxe16iYpk8=',
 'Restaurant',
 1,
 '2025-12-21 11:35:29',
 NULL),

-- Customer (testing)
('testing@testing.coms',
 '73l8gRjwLtfklgfdXT+MdiMEjwGPVMSylxe16iYpk8=',
 'Customer',
 1,
 '2026-01-03 19:58:22',
 NULL);
