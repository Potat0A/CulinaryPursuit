/* =========================================
   CULINARY PURSUIT - REWARDS SYSTEM
   Complete database schema for rewards integration
   Author: JunJie (Integrated by Claude)
   Created: 2026-01-11
========================================= */

/* =========================================
   REWARDS TABLE
   Stores reward items that customers can redeem with points
========================================= */
CREATE TABLE Rewards (
    RewardID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    PointsRequired INT NOT NULL CHECK (PointsRequired > 0),
    Image VARBINARY(MAX) NULL,
    ImagePath NVARCHAR(500) NULL,
    Category NVARCHAR(100) NULL,
    IsAvailable BIT NOT NULL DEFAULT 1,
    StockQuantity INT NULL, -- NULL means unlimited stock
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedDate DATETIME NULL,

    -- Expiry Configuration Fields
    ExpiryType NVARCHAR(20) NULL CHECK (ExpiryType IN ('FixedDate', 'Timespan') OR ExpiryType IS NULL),
    ExpiryDate DATETIME NULL,
    ExpiryMonths INT NULL CHECK (ExpiryMonths > 0 OR ExpiryMonths IS NULL),

    -- Category-Specific Fields
    DiscountPercentage DECIMAL(5,2) NULL CHECK (DiscountPercentage >= 0 AND DiscountPercentage <= 100 OR DiscountPercentage IS NULL),
    VoucherAmount DECIMAL(10,2) NULL CHECK (VoucherAmount >= 0 OR VoucherAmount IS NULL),
    PartneringStores NVARCHAR(200) NULL
);
GO

/* =========================================
   REWARD REDEMPTIONS TABLE
   Tracks customer reward redemptions
========================================= */
CREATE TABLE RewardRedemptions (
    RedemptionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    RewardID INT NOT NULL,
    PointsUsed INT NOT NULL,
    RedemptionDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending'
        CHECK (Status IN ('Pending', 'Completed', 'Cancelled', 'Used')),
    ExpiryDate DATETIME NULL, -- Calculated expiry date when reward is redeemed

    CONSTRAINT FK_RewardRedemptions_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_RewardRedemptions_Rewards
        FOREIGN KEY (RewardID) REFERENCES Rewards(RewardID)
);
GO

/* =========================================
   POINTS TRANSACTIONS TABLE
   Tracks all points transactions (earned, spent, expired)
========================================= */
CREATE TABLE PointsTransactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    TransactionType NVARCHAR(50) NOT NULL
        CHECK (TransactionType IN ('Earned', 'Spent', 'Expired', 'SpinWheel', 'Redeemed', 'Used')),
    Points INT NOT NULL, -- Positive for earned, negative for spent/expired
    Description NVARCHAR(500) NULL,
    RelatedID INT NULL, -- Can reference RewardID, OrderID, etc.
    TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    ExpiryDate DATETIME NULL, -- For points that expire (e.g., spin wheel points expire in 1 year)

    CONSTRAINT FK_PointsTransactions_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- Create indexes for better performance
CREATE INDEX IX_PointsTransactions_CustomerID ON PointsTransactions(CustomerID);
CREATE INDEX IX_PointsTransactions_TransactionDate ON PointsTransactions(TransactionDate);
CREATE INDEX IX_PointsTransactions_ExpiryDate ON PointsTransactions(ExpiryDate);
CREATE INDEX IX_RewardRedemptions_CustomerID ON RewardRedemptions(CustomerID);
CREATE INDEX IX_RewardRedemptions_Status ON RewardRedemptions(Status);
GO

/* =========================================
   SAMPLE DATA - Initial Rewards
========================================= */
-- Vouchers Category
INSERT INTO Rewards (Name, Description, PointsRequired, Category, IsAvailable, StockQuantity, VoucherAmount, ImagePath)
VALUES
('$5 Discount Voucher', 'Get $5 off your next order', 50, 'Vouchers', 1, NULL, 5.00, '/content/rewards/voucher-5.png'),
('$10 Discount Voucher', 'Get $10 off your next order', 100, 'Vouchers', 1, NULL, 10.00, '/content/rewards/voucher-10.png'),
('$25 Discount Voucher', 'Get $25 off your next order', 250, 'Vouchers', 1, NULL, 25.00, '/content/rewards/voucher-25.png'),
('$50 Discount Voucher', 'Get $50 off your next order', 500, 'Vouchers', 1, NULL, 50.00, '/content/rewards/voucher-50.png');

-- Services Category
INSERT INTO Rewards (Name, Description, PointsRequired, Category, IsAvailable, StockQuantity, ImagePath)
VALUES
('Free Delivery', 'Free delivery on your next order', 50, 'Services', 1, NULL, '/content/rewards/free-delivery.png'),
('Priority Order Processing', 'Your order gets processed first', 75, 'Services', 1, NULL, '/content/rewards/priority.png'),
('Chef''s Special Message', 'Get a personalized message from the chef', 100, 'Services', 1, NULL, '/content/rewards/chef-message.png');

-- Upgrades Category
INSERT INTO Rewards (Name, Description, PointsRequired, Category, IsAvailable, StockQuantity, ImagePath)
VALUES
('Premium Meal Upgrade', 'Upgrade to premium meal selection', 150, 'Upgrades', 1, 20, '/content/rewards/premium-upgrade.png'),
('Dessert Add-On', 'Add a premium dessert to your order', 80, 'Upgrades', 1, NULL, '/content/rewards/dessert.png'),
('Drink Upgrade', 'Upgrade to premium beverages', 60, 'Upgrades', 1, NULL, '/content/rewards/drink-upgrade.png');

-- Special Category
INSERT INTO Rewards (Name, Description, PointsRequired, Category, IsAvailable, StockQuantity, ImagePath)
VALUES
('Birthday Special', 'Special birthday treat on your special day', 200, 'Special', 1, NULL, '/content/rewards/birthday.png'),
('Anniversary Package', 'Romantic anniversary meal package', 300, 'Special', 1, 10, '/content/rewards/anniversary.png'),
('Chef''s Table Experience', 'Exclusive chef''s table experience', 1000, 'Special', 1, 5, '/content/rewards/chefs-table.png');

-- Discounts Category (percentage-based)
INSERT INTO Rewards (Name, Description, PointsRequired, Category, IsAvailable, StockQuantity, DiscountPercentage, ImagePath)
VALUES
('10% Off Next Order', 'Get 10% discount on your entire order', 120, 'Discounts', 1, NULL, 10.00, '/content/rewards/discount-10.png'),
('15% Off Next Order', 'Get 15% discount on your entire order', 180, 'Discounts', 1, NULL, 15.00, '/content/rewards/discount-15.png'),
('20% Off Next Order', 'Get 20% discount on your entire order', 250, 'Discounts', 1, NULL, 20.00, '/content/rewards/discount-20.png');
GO

PRINT '✓ Rewards System tables created successfully!'
PRINT '✓ 3 tables created: Rewards, RewardRedemptions, PointsTransactions'
PRINT '✓ 15 sample rewards added'
PRINT '✓ Indexes created for optimal performance'
PRINT ''
PRINT 'Next steps:'
PRINT '1. Integrate reward pages into main project'
PRINT '2. Update master page navigation'
PRINT '3. Test reward functionality'
GO
