/* =========================================
   ADDITIONAL TABLES FOR ORDER & PAYMENT SYSTEM
   Author: Henry
   Created: 2026-01-08
========================================= */

/* =========================================
   SHOPPING CART
========================================= */
CREATE TABLE Cart (
    CartID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    MenuItemID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    AddedDate DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Cart_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Cart_MenuItems
        FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);
GO

/* =========================================
   ORDER ITEMS (Details of each order)
========================================= */
CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    MenuItemID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderItems_MenuItems
        FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);
GO

/* =========================================
   PAYMENTS (Customer payments for orders)
========================================= */
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    CustomerID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,
    PaymentStatus NVARCHAR(20) NOT NULL DEFAULT 'Completed'
        CHECK (PaymentStatus IN ('Pending','Completed','Failed','Refunded')),
    TransactionID NVARCHAR(100) NULL,
    PaymentDate DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_Payments_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

/* =========================================
   PLATFORM FEES (Restaurants pay platform)
========================================= */
CREATE TABLE PlatformFees (
    PlatformFeeID INT IDENTITY(1,1) PRIMARY KEY,
    RestaurantID INT NOT NULL,
    OrderID INT NULL,
    FeeAmount DECIMAL(10,2) NOT NULL,
    FeePercentage DECIMAL(5,2) NOT NULL DEFAULT 10.00,
    FeeStatus NVARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (FeeStatus IN ('Pending','Paid','Overdue','Waived')),
    DueDate DATETIME NOT NULL,
    PaidDate DATETIME NULL,
    PaymentMethod NVARCHAR(50) NULL,
    Notes NVARCHAR(500) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_PlatformFees_Restaurants
        FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID),
    CONSTRAINT FK_PlatformFees_Orders
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
GO

/* =========================================
   REVIEWS (Customer reviews for restaurants)
========================================= */
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Reviews')
BEGIN
    CREATE TABLE Reviews (
        ReviewID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT NOT NULL,
        RestaurantID INT NOT NULL,
        OrderID INT NULL,
        Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
        ReviewText NVARCHAR(1000) NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_Reviews_Customers
            FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
        CONSTRAINT FK_Reviews_Restaurants
            FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID),
        CONSTRAINT FK_Reviews_Orders
            FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
    );
END
GO

/* =========================================
   ADD INDEXES FOR PERFORMANCE
========================================= */
CREATE INDEX IX_Cart_CustomerID ON Cart(CustomerID);
CREATE INDEX IX_OrderItems_OrderID ON OrderItems(OrderID);
CREATE INDEX IX_Payments_OrderID ON Payments(OrderID);
CREATE INDEX IX_PlatformFees_RestaurantID ON PlatformFees(RestaurantID);
CREATE INDEX IX_PlatformFees_Status ON PlatformFees(FeeStatus);
CREATE INDEX IX_Reviews_RestaurantID ON Reviews(RestaurantID);
GO

/* =========================================
   SAMPLE PLATFORM FEE CONFIGURATION
========================================= */
-- You can adjust the default fee percentage in Web.config or create a settings table
-- Default: 10% platform fee on each order
