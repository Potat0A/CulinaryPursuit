using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class redeemrewards : System.Web.UI.Page
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
                LoadRedeemedRewards();
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
        // LOAD REDEEMED REWARDS
        // --------------------
        private void LoadRedeemedRewards()
        {
            if (Session["CustomerID"] == null)
            {
                rptRedeemedRewards.Visible = false;
                lblEmpty.Visible = true;
                return;
            }

            int customerId = Convert.ToInt32(Session["CustomerID"]);
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            string categoryFilter = ddlCategory.SelectedValue;
            string sortBy = ddlSort.SelectedValue;
            
            // Whitelist sort options
            string[] allowedSorts = { "RedemptionDate DESC", "RedemptionDate ASC", "ExpiryDate ASC", "PointsUsed ASC", "PointsUsed DESC" };
            if (Array.IndexOf(allowedSorts, sortBy) == -1)
            {
                sortBy = "RedemptionDate DESC";
            }
            
            string query = @"
SELECT rr.RedemptionID, rr.PointsUsed, rr.RedemptionDate, rr.ExpiryDate, rr.Status,
       r.RewardID, r.Name, r.Description, r.ImagePath, r.PartneringStores, r.StockQuantity, r.Category
FROM dbo.RewardRedemptions rr
INNER JOIN dbo.Rewards r ON rr.RewardID = r.RewardID
WHERE rr.CustomerID = @CustomerID AND rr.Status != 'Used'";
            
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
                        rptRedeemedRewards.DataSource = dt;
                        rptRedeemedRewards.DataBind();
                        lblEmpty.Visible = false;
                    }
                    else
                    {
                        rptRedeemedRewards.Visible = false;
                        lblEmpty.Visible = true;
                    }
                }
            }
        }

        // --------------------
        // USE REWARD
        // --------------------
        protected void rptRedeemedRewards_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // This is now handled by client-side confirmation modal
            // The actual redirect happens in JavaScript
        }

        protected void btnConfirmUse_Click(object sender, EventArgs e)
        {
            // This method is kept for server-side handling if needed
            // Currently handled by JavaScript redirect
        }

        // --------------------
        // UI HELPERS
        // --------------------
        protected bool IsExpired(object expiryDate)
        {
            if (expiryDate == null || expiryDate == DBNull.Value)
                return false;

            try
            {
                DateTime expiry = Convert.ToDateTime(expiryDate);
                return DateTime.Now > expiry;
            }
            catch
            {
                return false;
            }
        }

        protected string FormatExpiryDate(object expiryDate)
        {
            if (expiryDate == null || expiryDate == DBNull.Value)
                return "No expiry";

            try
            {
                DateTime expiry = Convert.ToDateTime(expiryDate);
                return expiry.ToString("dd/MM/yyyy");
            }
            catch
            {
                return "Invalid date";
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
            return "<div class=\"no-image\">🎁</div>";
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

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadRedeemedRewards();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadRedeemedRewards();
        }

        protected string GetUseNowConfirmScript(object redemptionId, object rewardName)
        {
            string name = rewardName?.ToString() ?? "";
            name = name.Replace("'", "\\'").Replace("\"", "&quot;");
            return $"return confirmUseNow({redemptionId}, '{name}');";
        }

        private void ShowStatus(string message, bool isError)
        {
            string safe = HttpUtility.HtmlEncode(message);
            lblStatus.Text = $"<div class='msg-status {(isError ? "msg-error" : "msg-success")}'>{safe}</div>";
        }
    }
}
