using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class Rewards : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check customer authentication
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (Session["CustomerID"] == null)
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Always load points to ensure they're current
            LoadCustomerPoints();
            
            if (!IsPostBack)
            {
                LoadRewards();
            }
        }

        // --------------------
        // LOAD CUSTOMER POINTS
        // --------------------
        private void LoadCustomerPoints()
        {
            try
            {
                if (Session["CustomerID"] == null)
                {
                    lblPointsBalance.Text = "0";
                    Session["CustomerPoints"] = 0;
                    return;
                }

                int customerId = Convert.ToInt32(Session["CustomerID"]);
                string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(@"
SELECT RewardPoints FROM dbo.Customers WHERE CustomerID = @CustomerID", conn))
                {
                    cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    int points = result != null && result != DBNull.Value ? Convert.ToInt32(result) : 0;
                    lblPointsBalance.Text = points.ToString();
                    Session["CustomerPoints"] = points;
                }
            }
            catch (Exception ex)
            {
                // Log error and set default value
                System.Diagnostics.Debug.WriteLine($"LoadCustomerPoints Error: {ex.Message}");
                lblPointsBalance.Text = "0";
                Session["CustomerPoints"] = 0;
            }
        }

        // --------------------
        // LOAD CATEGORIES
        // --------------------
        private void LoadCategories()
        {
            // Categories are now hardcoded in the dropdown, so this method is no longer needed
            // But keeping it for backward compatibility if needed
        }

        // --------------------
        // LOAD REWARDS
        // --------------------
        private void LoadRewards()
        {
            if (Session["CustomerID"] == null)
            {
                rptRewards.Visible = false;
                lblEmpty.Visible = true;
                return;
            }

            int customerId = Convert.ToInt32(Session["CustomerID"]);
            string categoryFilter = ddlCategory.SelectedValue;
            string sortBy = ddlSort.SelectedValue;
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            // Whitelist sort options to prevent SQL injection
            string[] allowedSorts = { "PointsRequired ASC", "PointsRequired DESC", "Name ASC", "Name DESC", "CreatedDate DESC", "CreatedDate ASC" };
            if (Array.IndexOf(allowedSorts, sortBy) == -1)
            {
                sortBy = "CreatedDate DESC"; // Default sort
            }

            // Exclude rewards already redeemed by this customer
            string query = @"
SELECT r.RewardID, r.Name, r.Description, r.PointsRequired, r.Category, 
       r.IsAvailable, r.StockQuantity, r.ImagePath, r.PartneringStores,
       r.ExpiryType, r.ExpiryDate, r.ExpiryTimespanValue, r.ExpiryTimespanUnit
FROM dbo.Rewards r
WHERE r.IsAvailable = 1
  AND r.RewardID NOT IN (
      SELECT RewardID 
      FROM dbo.RewardRedemptions 
      WHERE CustomerID = @CustomerID AND Status = 'Completed'
  )";

            if (!string.IsNullOrWhiteSpace(categoryFilter))
            {
                query += " AND r.Category = @Category";
            }

            query += " ORDER BY " + sortBy;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                if (!string.IsNullOrWhiteSpace(categoryFilter))
                {
                    cmd.Parameters.Add("@Category", SqlDbType.NVarChar, 100).Value = categoryFilter;
                }

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptRewards.DataSource = dt;
                        rptRewards.DataBind();
                        lblEmpty.Visible = false;
                    }
                    else
                    {
                        rptRewards.Visible = false;
                        lblEmpty.Visible = true;
                    }
                }
            }
        }

        // --------------------
        // REDEEM REWARD
        // --------------------
        protected void btnConfirmRedeem_Click(object sender, EventArgs e)
        {
            int rewardId = Convert.ToInt32(hdnRedeemRewardID.Value);
            ProcessRedemption(rewardId);
        }

        protected void rptRewards_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Redeem")
            {
                // This is now handled by confirmation modal
                // The actual redemption happens in btnConfirmRedeem_Click
            }
        }

        private void ProcessRedemption(int rewardId)
        {
                int customerId = Convert.ToInt32(Session["CustomerID"]);
                int currentPoints = Convert.ToInt32(Session["CustomerPoints"] ?? 0);

                string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Check reward availability and points
                    using (SqlCommand checkCmd = new SqlCommand(@"
SELECT PointsRequired, StockQuantity, IsAvailable, Name
FROM dbo.Rewards
WHERE RewardID = @RewardID", conn))
                    {
                        checkCmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;

                        using (SqlDataReader reader = checkCmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                ShowStatus("Error: Reward not found.", true);
                                return;
                            }

                            int pointsRequired = Convert.ToInt32(reader["PointsRequired"]);
                            bool isAvailable = Convert.ToBoolean(reader["IsAvailable"]);
                            object stockObj = reader["StockQuantity"];
                            string rewardName = reader["Name"].ToString();

                            if (!isAvailable)
                            {
                                ShowStatus("Error: This reward is no longer available.", true);
                                return;
                            }

                            if (currentPoints < pointsRequired)
                            {
                                ShowStatus($"Error: You need {pointsRequired} points to redeem this reward. You have {currentPoints} points.", true);
                                return;
                            }

                            // Check stock if applicable
                            if (stockObj != DBNull.Value)
                            {
                                int stock = Convert.ToInt32(stockObj);
                                if (stock <= 0)
                                {
                                    ShowStatus("Error: This reward is out of stock.", true);
                                    return;
                                }
                            }
                        }
                    }

                    // Start transaction
                    using (SqlTransaction trans = conn.BeginTransaction())
                    {
                        try
                        {
                            // Get points required, expiry info, reward name and update stock
                            int pointsRequired;
                            string rewardName = "";
                            DateTime? calculatedExpiryDate = null;
                            using (SqlCommand getPointsCmd = new SqlCommand(@"
SELECT PointsRequired, StockQuantity, ExpiryType, ExpiryDate, ExpiryTimespanValue, ExpiryTimespanUnit, Name
FROM dbo.Rewards
WHERE RewardID = @RewardID", conn, trans))
                            {
                                getPointsCmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                                
                                using (SqlDataReader reader = getPointsCmd.ExecuteReader())
                                {
                                    if (!reader.Read())
                                    {
                                        throw new Exception("Reward not found.");
                                    }
                                    
                                    pointsRequired = Convert.ToInt32(reader["PointsRequired"]);
                                    rewardName = reader["Name"].ToString();
                                    object stockObj = reader["StockQuantity"];
                                    
                                    // Calculate expiry date
                                    object expiryTypeObj = reader["ExpiryType"];
                                    if (expiryTypeObj != DBNull.Value && expiryTypeObj != null)
                                    {
                                        string expiryType = expiryTypeObj.ToString();
                                        if (expiryType == "FixedDate")
                                        {
                                            object expiryDateObj = reader["ExpiryDate"];
                                            if (expiryDateObj != DBNull.Value && expiryDateObj != null)
                                            {
                                                calculatedExpiryDate = Convert.ToDateTime(expiryDateObj);
                                            }
                                        }
                                        else if (expiryType == "Timespan")
                                        {
                                            object expiryValueObj = reader["ExpiryTimespanValue"];
                                            object expiryUnitObj = reader["ExpiryTimespanUnit"];
                                            if (expiryValueObj != DBNull.Value && expiryValueObj != null && 
                                                expiryUnitObj != DBNull.Value && expiryUnitObj != null)
                                            {
                                                int value = Convert.ToInt32(expiryValueObj);
                                                string unit = expiryUnitObj.ToString();
                                                
                                                if (unit == "Days")
                                                {
                                                    calculatedExpiryDate = DateTime.Now.AddDays(value);
                                                }
                                                else if (unit == "Weeks")
                                                {
                                                    calculatedExpiryDate = DateTime.Now.AddDays(value * 7);
                                                }
                                                else if (unit == "Months")
                                                {
                                                    calculatedExpiryDate = DateTime.Now.AddMonths(value);
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Update stock if applicable
                                    if (stockObj != DBNull.Value)
                                    {
                                        int stock = Convert.ToInt32(stockObj);
                                        if (stock > 0)
                                        {
                                            reader.Close();
                                            using (SqlCommand updateStockCmd = new SqlCommand(@"
UPDATE dbo.Rewards
SET StockQuantity = StockQuantity - 1
WHERE RewardID = @RewardID AND StockQuantity > 0", conn, trans))
                                            {
                                                updateStockCmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                                                updateStockCmd.ExecuteNonQuery();
                                            }
                                        }
                                    }
                                }
                            }

                            // Deduct points from customer
                            using (SqlCommand deductCmd = new SqlCommand(@"
UPDATE dbo.Customers
SET RewardPoints = RewardPoints - @Points
WHERE CustomerID = @CustomerID AND RewardPoints >= @Points", conn, trans))
                            {
                                deductCmd.Parameters.Add("@Points", SqlDbType.Int).Value = pointsRequired;
                                deductCmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                                
                                int rowsAffected = deductCmd.ExecuteNonQuery();
                                if (rowsAffected == 0)
                                {
                                    throw new Exception("Insufficient points.");
                                }
                            }

                            // Check if user already has an active redemption for this reward
                            using (SqlCommand checkActiveCmd = new SqlCommand(@"
SELECT COUNT(*) FROM dbo.RewardRedemptions 
WHERE CustomerID = @CustomerID AND RewardID = @RewardID AND Status != 'Used'", conn, trans))
                            {
                                checkActiveCmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                                checkActiveCmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                                int activeCount = Convert.ToInt32(checkActiveCmd.ExecuteScalar());
                                
                                if (activeCount > 0)
                                {
                                    throw new Exception("You already have an active redemption for this reward. Please use it before redeeming again.");
                                }
                            }

                            // Create redemption record with expiry date (Status = 'Pending' until used)
                            using (SqlCommand redeemCmd = new SqlCommand(@"
INSERT INTO dbo.RewardRedemptions (CustomerID, RewardID, PointsUsed, Status, ExpiryDate)
VALUES (@CustomerID, @RewardID, @PointsUsed, 'Pending', @ExpiryDate)", conn, trans))
                            {
                                redeemCmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                                redeemCmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                                redeemCmd.Parameters.Add("@PointsUsed", SqlDbType.Int).Value = pointsRequired;
                                
                                if (calculatedExpiryDate.HasValue)
                                {
                                    redeemCmd.Parameters.Add("@ExpiryDate", SqlDbType.DateTime).Value = calculatedExpiryDate.Value;
                                }
                                else
                                {
                                    redeemCmd.Parameters.Add("@ExpiryDate", SqlDbType.DateTime).Value = DBNull.Value;
                                }
                                
                                redeemCmd.ExecuteNonQuery();
                            }

                            // Record transaction in PointsTransactions (points spent)
                            using (SqlCommand transCmd = new SqlCommand(@"
INSERT INTO dbo.PointsTransactions (CustomerID, TransactionType, Points, Description, RelatedID)
VALUES (@CustomerID, 'Redeemed', @Points, @Description, @RewardID)", conn, trans))
                            {
                                transCmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                                transCmd.Parameters.Add("@Points", SqlDbType.Int).Value = -pointsRequired; // Negative for spent
                                transCmd.Parameters.Add("@Description", SqlDbType.NVarChar, 500).Value = 
                                    $"Redeemed reward: {rewardName}";
                                transCmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                                transCmd.ExecuteNonQuery();
                            }

                            trans.Commit();

                            // Reload points from database to ensure accuracy
                            LoadCustomerPoints();
                            
                            ShowStatus($"✅ Successfully redeemed! Your reward is now available in Redeem Rewards.", false);
                            LoadRewards();
                        }
                        catch (Exception ex)
                        {
                            trans.Rollback();
                            ShowStatus($"Error: {ex.Message}", true);
                        }
                    }
                }
            }

        // --------------------
        // FILTER/SORT EVENTS
        // --------------------
        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadRewards();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadRewards();
        }

        // --------------------
        // UI HELPERS
        // --------------------
        protected bool GetRedeemEnabled(object isAvailable, object pointsRequired)
        {
            try
            {
                bool available = Convert.ToBoolean(isAvailable);
                if (!available) return false;

                int required = Convert.ToInt32(pointsRequired);
                int customerPoints = Session["CustomerPoints"] != null 
                    ? Convert.ToInt32(Session["CustomerPoints"]) 
                    : 0;

                return required <= customerPoints;
            }
            catch
            {
                return false;
            }
        }

        protected string GetRewardImage(object imagePath)
        {
            if (imagePath != null && imagePath != DBNull.Value && !string.IsNullOrWhiteSpace(imagePath.ToString()))
            {
                string path = imagePath.ToString();
                if (!path.StartsWith("http"))
                {
                    path = ResolveUrl("~" + (path.StartsWith("/") ? path : "/" + path));
                }
                return $"<img src=\"{HttpUtility.HtmlAttributeEncode(path)}\" alt=\"Reward Image\" />";
            }
            return "<div class=\"no-image\">🏆</div>";
        }

        protected string GetBadgeClass(object stockQuantity)
        {
            if (stockQuantity == DBNull.Value || stockQuantity == null)
            {
                return "badge-green";
            }
            return "badge-exclusive";
        }

        protected string GetBadgeText(object stockQuantity)
        {
            if (stockQuantity == DBNull.Value || stockQuantity == null)
            {
                return "ORDINARY";
            }
            return "EXCLUSIVE";
        }

        protected string GetPartneringStores(object partneringStores)
        {
            if (partneringStores != null && partneringStores != DBNull.Value && !string.IsNullOrWhiteSpace(partneringStores.ToString()))
            {
                return partneringStores.ToString();
            }
            return "Various Partners";
        }

        protected bool HasExpiryInfo(object expiryType, object expiryDate, object expiryTimespanValue, object expiryTimespanUnit)
        {
            if (expiryType != null && expiryType != DBNull.Value && !string.IsNullOrWhiteSpace(expiryType.ToString()))
            {
                return true;
            }
            return false;
        }

        protected string FormatExpiryInfo(object expiryType, object expiryDate, object expiryTimespanValue, object expiryTimespanUnit)
        {
            if (expiryType == null || expiryType == DBNull.Value || string.IsNullOrWhiteSpace(expiryType.ToString()))
            {
                return "No expiry";
            }

            string type = expiryType.ToString();
            if (type == "FixedDate")
            {
                if (expiryDate != null && expiryDate != DBNull.Value)
                {
                    try
                    {
                        DateTime date = Convert.ToDateTime(expiryDate);
                        return date.ToString("dd/MM/yyyy");
                    }
                    catch
                    {
                        return "Invalid date";
                    }
                }
                return "Date not set";
            }
            else if (type == "Timespan")
            {
                if (expiryTimespanValue != null && expiryTimespanValue != DBNull.Value && 
                    expiryTimespanUnit != null && expiryTimespanUnit != DBNull.Value)
                {
                    try
                    {
                        int value = Convert.ToInt32(expiryTimespanValue);
                        string unit = expiryTimespanUnit.ToString();
                        string unitText = unit.ToLower();
                        if (value > 1 && unit == "Days") unitText = "days";
                        else if (value > 1 && unit == "Weeks") unitText = "weeks";
                        else if (value > 1 && unit == "Months") unitText = "months";
                        return $"{value} {unitText} from redemption";
                    }
                    catch
                    {
                        return "Invalid timespan";
                    }
                }
                return "Timespan not set";
            }

            return "No expiry";
        }

        protected string GetRedeemConfirmScript(object rewardId, object rewardName, object pointsRequired)
        {
            string name = rewardName?.ToString() ?? "";
            name = name.Replace("'", "\\'").Replace("\"", "&quot;");
            return $"return confirmRedeem({rewardId}, '{name}', {pointsRequired});";
        }

        private void ShowStatus(string message, bool isError)
        {
            string safe = HttpUtility.HtmlEncode(message);
            lblStatus.Text = $"<div class='msg-status {(isError ? "msg-error" : "msg-success")}'>{safe}</div>";
        }
    }
}