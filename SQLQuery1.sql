

-- ═══════════════════════════════════════════════════════════
-- 👥 USERS & AUTHENTICATION
-- ═══════════════════════════════════════════════════════════

CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Email NVARCHAR(255) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(500) NOT NULL,
    UserType NVARCHAR(20) NOT NULL CHECK (UserType IN ('Customer', 'Restaurant', 'Admin')),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    LastLoginDate DATETIME NULL,
    INDEX idx_email (Email),
    INDEX idx_usertype (UserType)
);

-- ═══════════════════════════════════════════════════════════
-- 🍽️ CUSTOMERS
-- ═══════════════════════════════════════════════════════════

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    Name NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    Address NVARCHAR(500) NULL,
    ProfilePicture NVARCHAR(500) NULL,
    RewardPoints INT DEFAULT 0,
    TotalOrders INT DEFAULT 0,
    PreferredCuisines NVARCHAR(500) NULL, -- Comma-separated
    DietaryRestrictions NVARCHAR(500) NULL,
    CreatedDate DATETIME DEFAULT GETDATE(),
    INDEX idx_userid (UserID)
);

-- ═══════════════════════════════════════════════════════════
-- 👨‍🍳 RESTAURANTS/HOME CHEFS
-- ═══════════════════════════════════════════════════════════

CREATE TABLE Restaurants (
    RestaurantID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    ChefName NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    Address NVARCHAR(500) NOT NULL,
    CuisineType NVARCHAR(100) NOT NULL,
    Logo NVARCHAR(500) NULL,
    Banner NVARCHAR(500) NULL,
    Rating DECIMAL(3,2) DEFAULT 0.00,
    TotalReviews INT DEFAULT 0,
    ApprovalStatus NVARCHAR(20) DEFAULT 'Pending' CHECK (ApprovalStatus IN ('Pending', 'Approved', 'Rejected', 'Suspended')),
    IsActive BIT DEFAULT 1,
    OpeningHours NVARCHAR(500) NULL, -- JSON format
    CreatedDate DATETIME DEFAULT GETDATE(),
    ApprovedDate DATETIME NULL,
    INDEX idx_userid (UserID),
    INDEX idx_approval (ApprovalStatus),
    INDEX idx_cuisine (CuisineType)
);

-- ═══════════════════════════════════════════════════════════
-- 🍱 MENU ITEMS
-- ═══════════════════════════════════════════════════════════

CREATE TABLE MenuItems (
    MenuItemID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT NOT NULL FOREIGN KEY REFERENCES Restaurants(RestaurantID),
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    Price DECIMAL(10,2) NOT NULL,
    ImageURL NVARCHAR(500) NULL,
    Category NVARCHAR(100) NULL, -- Appetizer, Main, Dessert, etc.
    IsAvailable BIT DEFAULT 1,
    IsVegetarian BIT DEFAULT 0,
    IsVegan BIT DEFAULT 0,
    IsHalal BIT DEFAULT 0,
    SpicyLevel INT DEFAULT 0 CHECK (SpicyLevel BETWEEN 0 AND 5),
    PrepTime INT NULL, -- Minutes
    CreatedDate DATETIME DEFAULT GETDATE(),
    INDEX idx_restaurant (RestaurantID),
    INDEX idx_available (IsAvailable)
);

-- ═══════════════════════════════════════════════════════════
-- 🛒 ORDERS
-- ═══════════════════════════════════════════════════════════

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    RestaurantID INT NOT NULL FOREIGN KEY REFERENCES Restaurants(RestaurantID),
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) NOT NULL,
    DeliveryFee DECIMAL(10,2) DEFAULT 0,
    DiscountAmount DECIMAL(10,2) DEFAULT 0,
    FinalAmount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Confirmed', 'Preparing', 'Ready', 'Delivered', 'Cancelled')),
    DeliveryAddress NVARCHAR(500) NOT NULL,
    SpecialInstructions NVARCHAR(1000) NULL,
    EstimatedDeliveryTime DATETIME NULL,
    ActualDeliveryTime DATETIME NULL,
    INDEX idx_customer (CustomerID),
    INDEX idx_restaurant (RestaurantID),
    INDEX idx_status (Status),
    INDEX idx_date (OrderDate)
);

CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
    MenuItemID INT NOT NULL FOREIGN KEY REFERENCES MenuItems(MenuItemID),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Subtotal DECIMAL(10,2) NOT NULL,
    SpecialRequests NVARCHAR(500) NULL,
    INDEX idx_order (OrderID)
);

-- ═══════════════════════════════════════════════════════════
-- 💳 PAYMENTS
-- ═══════════════════════════════════════════════════════════

CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL, -- Credit Card, PayNow, GrabPay, etc.
    PaymentStatus NVARCHAR(50) DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Completed', 'Failed', 'Refunded')),
    TransactionID NVARCHAR(200) NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    INDEX idx_order (OrderID),
    INDEX idx_status (PaymentStatus)
);

-- ═══════════════════════════════════════════════════════════
-- ⭐ REVIEWS & RATINGS
-- ═══════════════════════════════════════════════════════════

CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    RestaurantID INT NOT NULL FOREIGN KEY REFERENCES Restaurants(RestaurantID),
    OrderID INT NULL FOREIGN KEY REFERENCES Orders(OrderID),
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(2000) NULL,
    FoodQuality INT NULL CHECK (FoodQuality BETWEEN 1 AND 5),
    Packaging INT NULL CHECK (Packaging BETWEEN 1 AND 5),
    Delivery INT NULL CHECK (Delivery BETWEEN 1 AND 5),
    ImageURL NVARCHAR(500) NULL,
    IsVisible BIT DEFAULT 1,
    ReviewDate DATETIME DEFAULT GETDATE(),
    INDEX idx_restaurant (RestaurantID),
    INDEX idx_customer (CustomerID)
);

-- ═══════════════════════════════════════════════════════════
-- 💬 CHAT/MESSAGES
-- ═══════════════════════════════════════════════════════════

CREATE TABLE Conversations (
    ConversationID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    RestaurantID INT NOT NULL FOREIGN KEY REFERENCES Restaurants(RestaurantID),
    StartDate DATETIME DEFAULT GETDATE(),
    LastMessageDate DATETIME NULL,
    IsActive BIT DEFAULT 1,
    INDEX idx_customer (CustomerID),
    INDEX idx_restaurant (RestaurantID)
);

CREATE TABLE Messages (
    MessageID INT PRIMARY KEY IDENTITY(1,1),
    ConversationID INT NOT NULL FOREIGN KEY REFERENCES Conversations(ConversationID),
    SenderID INT NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    Message NVARCHAR(2000) NOT NULL,
    MessageType NVARCHAR(50) DEFAULT 'Text', -- Text, Image, File
    AttachmentURL NVARCHAR(500) NULL,
    IsRead BIT DEFAULT 0,
    SentDate DATETIME DEFAULT GETDATE(),
    INDEX idx_conversation (ConversationID),
    INDEX idx_sender (SenderID)
);

-- ═══════════════════════════════════════════════════════════
-- 🏆 REWARDS SYSTEM
-- ═══════════════════════════════════════════════════════════

CREATE TABLE RewardTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    Points INT NOT NULL,
    TransactionType NVARCHAR(50) NOT NULL, -- Earned, Redeemed, Expired
    Description NVARCHAR(500) NULL,
    OrderID INT NULL FOREIGN KEY REFERENCES Orders(OrderID),
    TransactionDate DATETIME DEFAULT GETDATE(),
    INDEX idx_customer (CustomerID)
);

CREATE TABLE RewardItems (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    PointsCost INT NOT NULL,
    ImageURL NVARCHAR(500) NULL,
    Stock INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE RewardRedemptions (
    RedemptionID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    ItemID INT NOT NULL FOREIGN KEY REFERENCES RewardItems(ItemID),
    PointsUsed INT NOT NULL,
    RedemptionDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(50) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Fulfilled', 'Cancelled')),
    VoucherCode NVARCHAR(100) NULL,
    INDEX idx_customer (CustomerID)
);

-- ═══════════════════════════════════════════════════════════
-- 📰 NEWS & EVENTS
-- ═══════════════════════════════════════════════════════════

CREATE TABLE News (
    NewsID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(300) NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    ImageURL NVARCHAR(500) NULL,
    Category NVARCHAR(100) NULL,
    PublishDate DATETIME DEFAULT GETDATE(),
    IsPublished BIT DEFAULT 1,
    Views INT DEFAULT 0
);

CREATE TABLE Events (
    EventID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(300) NOT NULL,
    Description NVARCHAR(MAX) NOT NULL,
    EventDate DATETIME NOT NULL,
    Location NVARCHAR(500) NULL,
    ImageURL NVARCHAR(500) NULL,
    RegistrationURL NVARCHAR(500) NULL,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);

-- ═══════════════════════════════════════════════════════════
-- 📊 ANALYTICS VIEWS
-- ═══════════════════════════════════════════════════════════

GO
CREATE VIEW vw_RestaurantAnalytics AS
SELECT 
    r.RestaurantID,
    r.Name AS RestaurantName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(o.FinalAmount) AS TotalRevenue,
    AVG(o.FinalAmount) AS AverageOrderValue,
    r.Rating,
    r.TotalReviews,
    COUNT(DISTINCT CASE WHEN o.OrderDate >= DATEADD(day, -30, GETDATE()) THEN o.OrderID END) AS OrdersLast30Days
FROM Restaurants r
LEFT JOIN Orders o ON r.RestaurantID = o.RestaurantID
GROUP BY r.RestaurantID, r.Name, r.Rating, r.TotalReviews;
GO

-- ═══════════════════════════════════════════════════════════
-- 🔧 STORED PROCEDURES
-- ═══════════════════════════════════════════════════════════

-- Update Restaurant Rating after new review
GO
CREATE PROCEDURE sp_UpdateRestaurantRating
    @RestaurantID INT
AS
BEGIN
    UPDATE Restaurants
    SET Rating = (SELECT AVG(CAST(Rating AS DECIMAL(3,2))) FROM Reviews WHERE RestaurantID = @RestaurantID AND IsVisible = 1),
        TotalReviews = (SELECT COUNT(*) FROM Reviews WHERE RestaurantID = @RestaurantID AND IsVisible = 1)
    WHERE RestaurantID = @RestaurantID;
END;
GO

-- ═══════════════════════════════════════════════════════════
-- 🌱 SEED DATA
-- ═══════════════════════════════════════════════════════════

-- Insert default admin user
INSERT INTO Users (Email, PasswordHash, UserType) 
VALUES ('admin@culinarypursuit.com', 'hashed_password_here', 'Admin');

PRINT 'Database schema created successfully!';
GO