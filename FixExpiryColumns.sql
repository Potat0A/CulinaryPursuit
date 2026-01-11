/* =========================================
   FIX EXPIRY COLUMNS
   Add ExpiryTimespanValue and ExpiryTimespanUnit
   Remove old ExpiryMonths column
========================================= */

-- Step 1: Find and drop the CHECK constraint on ExpiryMonths
DECLARE @ConstraintName NVARCHAR(200)
SELECT @ConstraintName = name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('dbo.Rewards')
  AND definition LIKE '%ExpiryMonths%'

IF @ConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.Rewards DROP CONSTRAINT ' + @ConstraintName)
    PRINT 'Dropped constraint: ' + @ConstraintName
END
GO

-- Step 2: Drop old ExpiryMonths column
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Rewards') AND name = 'ExpiryMonths')
BEGIN
    ALTER TABLE dbo.Rewards DROP COLUMN ExpiryMonths;
    PRINT 'Dropped column: ExpiryMonths'
END
GO

-- Step 3: Add new ExpiryTimespanValue column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Rewards') AND name = 'ExpiryTimespanValue')
BEGIN
    ALTER TABLE dbo.Rewards
    ADD ExpiryTimespanValue INT NULL
        CHECK (ExpiryTimespanValue > 0 OR ExpiryTimespanValue IS NULL);
    PRINT 'Added column: ExpiryTimespanValue'
END
GO

-- Step 4: Add new ExpiryTimespanUnit column
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Rewards') AND name = 'ExpiryTimespanUnit')
BEGIN
    ALTER TABLE dbo.Rewards
    ADD ExpiryTimespanUnit NVARCHAR(10) NULL
        CHECK (ExpiryTimespanUnit IN ('Days', 'Weeks', 'Months') OR ExpiryTimespanUnit IS NULL);
    PRINT 'Added column: ExpiryTimespanUnit'
END
GO

PRINT ''
PRINT '✓ Expiry columns updated successfully!'
PRINT '  - Removed: ExpiryMonths'
PRINT '  - Added: ExpiryTimespanValue (INT)'
PRINT '  - Added: ExpiryTimespanUnit (NVARCHAR - Days/Weeks/Months)'
GO
