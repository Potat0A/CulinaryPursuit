# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CulinaryPursuit is an ASP.NET Web Forms application (.NET Framework 4.7.2) for a restaurant marketplace platform. It connects customers with restaurants/chefs, includes admin approval workflows, and uses a LocalDB SQL Server database.

## Technology Stack

- **Framework**: ASP.NET Web Forms (.NET Framework 4.7.2)
- **Database**: SQL Server LocalDB (LocalDB\MSSQLLocalDB)
- **ORM**: Entity Framework 6.5.1
- **Password Hashing**: SHA256 (BCrypt.Net-Next available but not currently used)
- **Database Provider**: MySql.Data 9.5.0 (package installed but LocalDB connection used)
- **Build Tool**: MSBuild
- **IDE Support**: Visual Studio (IIS Express)

## Building and Running

### Build Commands
```bash
# Build solution (from solution directory)
msbuild CulinaryPursuit.sln /p:Configuration=Debug

# Or use Visual Studio
# Open CulinaryPursuit.sln in Visual Studio and press F5
```

### Running the Application
The application runs on IIS Express at `http://localhost:63372/` with `Landing.aspx` as the default page.

```bash
# Using Visual Studio: F5 or Ctrl+F5
# Or use IIS Express directly from bin/ folder
```

### Database Setup
- Database file: `App_Data/CulinaryPursuitDB.mdf`
- Connection string: LocalDB instance with integrated security
- Schema initialization:
  1. Execute `buildingeverything.sql` to create base tables
  2. Execute `Henry_DatabaseExtensions.sql` to create order/payment tables
- **Important**: Both SQL scripts must be executed for full functionality

## Architecture

### User Roles and Authentication

Three distinct user types with separate authentication flows:

1. **Customer**: Regular users who browse restaurants and place orders
   - Session keys: `UserID`, `UserType`, `CustomerID`, `CustomerName`, `Email`
   - Redirect after login: `CustomerHome.aspx`

2. **Restaurant/Chef**: Restaurant owners who manage menus and view orders
   - Session keys: `UserID`, `UserType`, `RestaurantID`, `RestaurantName`, `Email`
   - Redirect after login: `RestaurantDashboard.aspx`
   - Requires admin approval (`ApprovalStatus` in `Restaurants` table)

3. **Admin**: Platform administrators who approve restaurant applications
   - Session key: `AdminID`
   - Redirect after login: `AdminDashboard.aspx`
   - Separate login page: `AdminLogin.aspx`

### Database Schema

**Base Tables (buildingeverything.sql):**
- **Users**: Base authentication table (UserID, Email, PasswordHash, UserType, IsActive)
- **Customers**: Customer profiles (links to Users via UserID)
- **Restaurants**: Restaurant profiles (links to Users via UserID, includes ApprovalStatus)
- **MenuItems**: Restaurant menu items (RestaurantID, Name, Description, Price, **ImagePath**, Category, IsAvailable)
- **Orders**: Customer orders (OrderID, CustomerID, RestaurantID, OrderDate, FinalAmount, Status)
- **Reviews**: Customer reviews (ReviewID, CustomerID, RestaurantID, OrderID, Rating, ReviewText)

**Extended Tables (Henry_DatabaseExtensions.sql):**
- **Cart**: Shopping cart (CartID, CustomerID, MenuItemID, Quantity, AddedDate)
- **OrderItems**: Order line items (OrderItemID, OrderID, MenuItemID, Quantity, UnitPrice, Subtotal)
- **Payments**: Payment transactions (PaymentID, OrderID, CustomerID, Amount, PaymentMethod, PaymentStatus, TransactionID)
- **PlatformFees**: Restaurant commissions (PlatformFeeID, RestaurantID, OrderID, FeeAmount, FeePercentage, FeeStatus, DueDate)

**Rewards System Tables (RewardsSystem_Complete.sql):**
- **Rewards**: Reward catalog (RewardID, Name, Description, PointsRequired, ImagePath, Category, StockQuantity, ExpiryType, ExpiryDate, ExpiryTimespanValue, ExpiryTimespanUnit, DiscountPercentage, VoucherAmount, PartneringStores, IsAvailable)
- **RewardRedemptions**: Customer redemptions (RedemptionID, CustomerID, RewardID, PointsUsed, RedemptionDate, Status, ExpiryDate)
- **PointsTransactions**: Points history (TransactionID, CustomerID, TransactionType, Points, Description, RelatedID, TransactionDate, ExpiryDate)

**Key Relationships:**
- Users → Customers (1:1, via UserID)
- Users → Restaurants (1:1, via UserID)
- Restaurants → MenuItems (1:many, via RestaurantID)
- Customers → Cart (1:many, via CustomerID)
- Orders → OrderItems (1:many, via OrderID)
- Orders → Payments (1:1, via OrderID)
- Orders → PlatformFees (1:1, via OrderID)

### Page Structure and Master Pages

Four master page templates:
- **public.Master**: Unauthenticated pages (Landing, Login, Signup, Logout)
- **Customer.Master**: Customer-authenticated pages (CustomerHome, CustomerOrdering, CustomerCheckout, CustomerProfile)
- **chef.Master**: Restaurant/Chef-authenticated pages (RestaurantDashboard, ChefMenu, AddMenuItem, ChefRestaurantProfile, SellerAnalytics, PlatformFeePayment)
- **admin.Master**: Admin-authenticated pages (AdminDashboard, AdminApproval, AdminAnalytics, AdminPlatformFees)

**Important**: All master pages must have `<form id="form1" runat="server">` for ASP.NET Web Forms to function properly.

### Authentication Flow

1. **Signup** (`Signup.aspx.cs`):
   - Creates record in `Users` table
   - Creates corresponding profile in `Customers` or `Restaurants` table
   - Uses SQL transactions for atomicity
   - Restaurants default to `ApprovalStatus = 'Pending'`

2. **Login** (`Login.aspx.cs`):
   - Validates against `Users` table joined with profile table
   - Stores role-specific session variables
   - SHA256 password hashing (stored as Base64)
   - Separate login buttons/forms for Customer vs Restaurant

3. **Session Management**:
   - All authenticated pages check `Session["UserID"]` and `Session["UserType"]`
   - Missing session redirects to `Login.aspx`
   - Wrong role redirects with `?forbidden=1` query parameter

### Password Security

Current implementation uses SHA256:
```csharp
using (var sha256 = SHA256.Create())
{
    byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
    return Convert.ToBase64String(bytes);
}
```

**Note**: BCrypt.Net-Next is installed in packages but not currently used. SHA256 is used throughout `Login.aspx.cs` and `Signup.aspx.cs`.

### File Uploads

Upload configuration in `Web.config`:
- Upload path: `~/Uploads/`
- Max file size: 5MB (5242880 bytes)
- Allowed extensions: `.jpg`, `.jpeg`, `.png`, `.gif`
- `maxRequestLength="10240"` in httpRuntime (10MB for entire request)

Upload directories:
- `Uploads/MenuItems/`: Menu item images
- `content/`: Default images (default-avatar.png, default-banner.jpg)

### Key Page Responsibilities

**Public Pages:**
- **Landing.aspx**: Public homepage
- **Login.aspx**: Dual login (Customer/Restaurant)
- **Signup.aspx**: Dual signup (Customer/Chef)
- **Logout.aspx**: Session cleanup and logout

**Customer Pages:**
- **CustomerHome.aspx**: Browse restaurants
- **CustomerOrdering.aspx**: Browse menu items, add to cart
- **CustomerCheckout.aspx**: View cart, place orders
- **CustomerProfile.aspx**: Edit customer profile
- **Rewards.aspx**: Browse reward store, filter by category, redeem rewards
- **redeemrewards.aspx**: View redeemed rewards history, check redemption status
- **PointsTransactions.aspx**: View points transaction history with expiry dates
- **SpinGame.aspx**: Daily spin wheel game (3 spins/day, points expire in 1 year)

**Restaurant/Chef Pages:**
- **RestaurantDashboard.aspx**: Restaurant metrics (orders, earnings, ratings)
- **ChefMenu.aspx**: View restaurant's menu items
- **AddMenuItem.aspx**: Add new menu items
- **ChefRestaurantProfile.aspx**: Edit restaurant profile
- **SellerAnalytics.aspx**: Revenue analytics, sales charts, top items
- **PlatformFeePayment.aspx**: Pay platform fees (10% commission)

**Admin Pages:**
- **AdminLogin.aspx**: Separate admin authentication (redirects to AdminDashboard.aspx)
- **AdminDashboard.aspx**: Platform overview, quick stats
- **AdminApproval.aspx**: Approve/reject restaurant applications
- **AdminAnalytics.aspx**: Platform-wide analytics, revenue trends, Chart.js visualizations
- **AdminPlatformFees.aspx**: Manage restaurant fees, waive/extend payments
- **AdminRewards.aspx**: Manage rewards catalog, edit rewards, toggle availability
- **AddReward.aspx**: Create new rewards with category-specific fields, expiry settings, image upload
- **AdminViewRedemptions.aspx**: View all customer redemptions, filter by status
- **PaymentVoucherSimulator.aspx**: Test voucher functionality for development

## Important Implementation Notes

### Database Connection Pattern
All pages use the same connection string pattern:
```csharp
string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;
using (SqlConnection conn = new SqlConnection(connStr))
{
    conn.Open();
    // Execute queries
}
```

### Chef Story Storage
The "Chef Story" from restaurant signup is stored in `Restaurants.Description` field (not a separate `ChefStory` column).

### Session-Based Authorization
Pages enforce role-based access by checking:
1. `Session["UserID"]` exists
2. `Session["UserType"]` matches expected role
3. Role-specific ID exists (e.g., `Session["RestaurantID"]`)

### SQL Queries
- Uses parameterized queries throughout (no SQL injection vulnerabilities)
- Common pattern: `cmd.Parameters.Add("@ParamName", SqlDbType.Type).Value = value`
- Date queries use SQL Server functions: `GETDATE()`, `CAST(GETDATE() AS date)`

### Admin Approval Workflow
1. Restaurant signs up → `ApprovalStatus = 'Pending'`
2. Admin views in `AdminApproval.aspx`
3. Admin approves → `ApprovalStatus = 'Approved'`, sets `ApprovedDate`
4. Admin rejects → `ApprovalStatus = 'Rejected'`
5. Possible statuses: Pending, Approved, Rejected, Suspended

### Order and Payment Workflow
1. Customer browses menu items on `CustomerOrdering.aspx`
2. Adds items to cart → inserts into `Cart` table
3. Views cart on `CustomerCheckout.aspx`
4. Places order → Transaction creates:
   - `Orders` record(s) (grouped by restaurant)
   - `OrderItems` records (one per menu item)
   - `Payments` record (marked as Completed)
   - `PlatformFees` record (10% of order, due in 30 days)
5. Cart is cleared after successful order
6. Customer `TotalOrders` count incremented

### Platform Fee Model
- **Commission**: 10% of each order total
- **Due Date**: 30 days from order creation
- **Status Flow**: Pending → Paid (or Overdue if unpaid)
- **Admin Actions**: Can waive fees or extend due date by 30 days
- **Restaurant Payment**: Via `PlatformFeePayment.aspx`

### Rewards System (by JunJie - Integrated January 2026)

**Customer Features:**
1. **Points Earning:**
   - Daily spin wheel game (SpinGame.aspx) - 3 spins per day
   - Points from spin wheel expire in 1 year
   - Points tracked in PointsTransactions table

2. **Rewards Store (Rewards.aspx):**
   - Browse available rewards by category (Discounts, Vouchers, Services, Upgrades, Special)
   - Filter and sort options
   - Category-specific rewards:
     - **Discounts**: Percentage-based (e.g., 10% off)
     - **Vouchers**: Fixed amount (e.g., $10 off)
     - **Services**: Free delivery, priority processing
     - **Upgrades**: Premium meal upgrades, add-ons
     - **Special**: Birthday packages, chef's table experience
   - Stock quantity management (limited vs unlimited)
   - Expiry configuration:
     - **FixedDate**: Reward expires on specific date
     - **Timespan**: Reward expires X days/weeks/months after redemption

3. **Redemption Process:**
   - Redeem rewards on Rewards.aspx with confirmation modal
   - Points deducted immediately
   - Redemption tracked in RewardRedemptions table
   - Status flow: Pending → Completed → Used

4. **Transaction History:**
   - View all points transactions on PointsTransactions.aspx
   - Transaction types: Earned, Spent, Expired, SpinWheel, Redeemed, Used
   - Shows expiry dates for points

**Admin Features:**
1. **Reward Management (AdminRewards.aspx):**
   - View all rewards with filter options
   - Edit reward details, toggle availability
   - Track stock quantities
   - Delete rewards

2. **Create Rewards (AddReward.aspx):**
   - Name, description, points required
   - Category selection with dynamic fields
   - Image upload (saved to /Uploads/Rewards/)
   - Stock quantity (NULL = unlimited)
   - Expiry settings (FixedDate or Timespan)
   - Category-specific fields:
     - Discounts: DiscountPercentage
     - Vouchers: VoucherAmount
   - Partnering stores information

3. **Redemption Tracking (AdminViewRedemptions.aspx):**
   - View all customer redemptions
   - Filter by status and customer
   - Track redemption dates and expiry

**Database Schema:**
- `Rewards`: Full catalog with 16 columns including category-specific fields
- `RewardRedemptions`: Customer redemption records with status tracking
- `PointsTransactions`: Complete points audit trail with expiry dates
- `Customers.RewardPoints`: Current point balance (INT)

**Business Rules:**
- Spin wheel: Maximum 3 spins per day per customer
- Spin points: Expire after 1 year
- Reward stock: Decrements on redemption if limited
- Points validation: Cannot redeem if insufficient points
- Image uploads: Max 5MB, JPG/JPEG/PNG/GIF only

## Configuration Files

### Web.config
- Database connection string: `CulinaryPursuitDB`
- App settings: SiteName, AdminEmail, upload configuration, rewards settings
- Session timeout: 60 minutes
- Custom errors: Off (development mode)
- Default document: `Landing.aspx`

### packages.config
Lists all NuGet dependencies including Entity Framework, MySQL connector, BCrypt, etc.

## Common Development Patterns

### Error Display
Pages use client-side JavaScript for error messages:
```csharp
ClientScript.RegisterStartupScript(this.GetType(), "ShowError", script, true);
```

### Alerts
Uses `ScriptManager.RegisterStartupScript` for JavaScript alerts:
```csharp
ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('{msg}');", true);
```

### Post-Redirect Pattern
After successful operations:
```csharp
Response.Redirect("Page.aspx", false);
Context.ApplicationInstance.CompleteRequest();
```

Or with delay:
```csharp
Response.AddHeader("REFRESH", "2;URL=Login.aspx");
```

## Critical Implementation Details

### MenuItems Image Storage
**Important Column Name Difference:**
- **Schema documentation** (buildingeverything.sql) shows: `Image VARBINARY(MAX)`
- **Actual implementation** uses: `ImagePath NVARCHAR(500)`

**Usage:**
```csharp
// AddMenuItem.aspx.cs stores file paths
imagePath = "/Uploads/MenuItems/" + fileName;

// Query pattern for displaying images
SELECT ISNULL(m.ImagePath, 'content/default-avatar.png') AS ImageUrl
FROM MenuItems m
```

**Do NOT** reference `m.Image` in queries - use `m.ImagePath` instead.

### ContentPlaceHolder IDs by Master Page
- **public.Master**: Not applicable (no content placeholders for child pages)
- **Customer.Master**: Uses `ContentPlaceHolder1`
- **chef.Master**: Uses `MainContent` and `HeadContent`
- **admin.Master**: Uses `MainContent` and `HeadContent`

When creating new pages, ensure ContentPlaceHolderID matches the master page's placeholder name.

### Required Using Statements for LINQ Operations
Pages that use LINQ methods (GroupBy, Where, Select, etc.) on DataTable/DataRow collections must include:
```csharp
using System.Linq;
```

Common in: CustomerCheckout.aspx.cs, analytics pages, any page doing data aggregation.

### Database Migration Checklist
When deploying to a new environment:
1. Ensure LocalDB is installed and running: `sqllocaldb start MSSQLLocalDB`
2. Execute `buildingeverything.sql` first
3. Execute `Henry_DatabaseExtensions.sql` second
4. Verify all 10 tables exist before running application
5. Tables: Users, Customers, Restaurants, MenuItems, Orders, Reviews, Cart, OrderItems, Payments, PlatformFees

### Master Page Form Requirements
All master pages MUST have the form tag with an ID:
```html
<form id="form1" runat="server">
```
Without this, ASP.NET Web Forms will not render pages correctly.
