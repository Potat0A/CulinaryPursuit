using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class AdminViewRedemptions : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check admin authentication
            if (Session["AdminID"] == null)
            {
                Response.Redirect("AdminLogin.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadFilterOptions();
                
                string rewardIdParam = Request.QueryString["rewardId"];
                if (!string.IsNullOrEmpty(rewardIdParam))
                {
                    // Set the reward name filter and filter redemptions by specific reward
                    int rewardId = Convert.ToInt32(rewardIdParam);
                    SetRewardNameFilter(rewardId);
                    BindRedemptionsByReward(rewardId);
                }
                else
                {
                    // Show all redemptions with filters
                    BindAllRedemptions();
                }
            }
        }

        // --------------------
        // SET REWARD NAME FILTER
        // --------------------
        private void SetRewardNameFilter(int rewardId)
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT Name FROM dbo.Rewards WHERE RewardID = @RewardID", conn))
            {
                cmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    string rewardName = result.ToString();
                    // Set the dropdown to this reward name
                    if (ddlRewardName.Items.FindByValue(rewardName) != null)
                    {
                        ddlRewardName.SelectedValue = rewardName;
                    }
                }
            }
        }

        // --------------------
        // LOAD FILTER OPTIONS
        // --------------------
        private void LoadFilterOptions()
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            // Load reward names
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT DISTINCT r.Name 
FROM dbo.Rewards r
INNER JOIN dbo.RewardRedemptions rr ON r.RewardID = rr.RewardID
ORDER BY r.Name", conn))
            {
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlRewardName.Items.Clear();
                    ddlRewardName.Items.Add(new ListItem("All Rewards", ""));
                    foreach (DataRow row in dt.Rows)
                    {
                        ddlRewardName.Items.Add(new ListItem(row["Name"].ToString(), row["Name"].ToString()));
                    }
                }
            }

            // Load categories
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT DISTINCT r.Category 
FROM dbo.Rewards r
INNER JOIN dbo.RewardRedemptions rr ON r.RewardID = rr.RewardID
WHERE r.Category IS NOT NULL AND r.Category != ''
ORDER BY r.Category", conn))
            {
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlCategory.Items.Clear();
                    ddlCategory.Items.Add(new ListItem("All Categories", ""));
                    foreach (DataRow row in dt.Rows)
                    {
                        ddlCategory.Items.Add(new ListItem(row["Category"].ToString(), row["Category"].ToString()));
                    }
                }
            }
        }

        // --------------------
        // VIEW ALL REDEMPTIONS
        // --------------------
        private void BindAllRedemptions()
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            string rewardNameFilter = ddlRewardName.SelectedValue;
            string categoryFilter = ddlCategory.SelectedValue;

            string query = @"
SELECT rr.RedemptionID, rr.RewardID, rr.CustomerID, rr.PointsUsed, rr.RedemptionDate, 
       rr.Status, rr.ExpiryDate, r.Name AS RewardName, r.Category,
       (SELECT TOP 1 pt.TransactionDate 
        FROM dbo.PointsTransactions pt 
        WHERE pt.RelatedID = rr.RewardID 
          AND pt.CustomerID = rr.CustomerID 
          AND pt.TransactionType = 'Used'
          AND pt.TransactionDate >= rr.RedemptionDate
        ORDER BY pt.TransactionDate DESC) AS UsedDate
FROM dbo.RewardRedemptions rr
INNER JOIN dbo.Rewards r ON rr.RewardID = r.RewardID
WHERE 1=1";

            if (!string.IsNullOrWhiteSpace(rewardNameFilter))
            {
                query += " AND r.Name = @RewardName";
            }

            if (!string.IsNullOrWhiteSpace(categoryFilter))
            {
                query += " AND r.Category = @Category";
            }

            query += " ORDER BY rr.RedemptionDate DESC";

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                if (!string.IsNullOrWhiteSpace(rewardNameFilter))
                {
                    cmd.Parameters.Add("@RewardName", SqlDbType.NVarChar, 200).Value = rewardNameFilter;
                }

                if (!string.IsNullOrWhiteSpace(categoryFilter))
                {
                    cmd.Parameters.Add("@Category", SqlDbType.NVarChar, 100).Value = categoryFilter;
                }

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvAllRedemptions.DataSource = dt;
                    gvAllRedemptions.DataBind();
                }
            }
        }

        private void BindRedemptionsByReward(int rewardId)
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            string rewardName = "";
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT Name FROM dbo.Rewards WHERE RewardID = @RewardID", conn))
            {
                cmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    rewardName = result.ToString();
                }
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT rr.RedemptionID, rr.RewardID, rr.CustomerID, rr.PointsUsed, rr.RedemptionDate, 
       rr.Status, rr.ExpiryDate, r.Name AS RewardName, r.Category,
       (SELECT TOP 1 pt.TransactionDate 
        FROM dbo.PointsTransactions pt 
        WHERE pt.RelatedID = rr.RewardID 
          AND pt.CustomerID = rr.CustomerID 
          AND pt.TransactionType = 'Used'
          AND pt.TransactionDate >= rr.RedemptionDate
        ORDER BY pt.TransactionDate DESC) AS UsedDate
FROM dbo.RewardRedemptions rr
INNER JOIN dbo.Rewards r ON rr.RewardID = r.RewardID
WHERE rr.RewardID = @RewardID
ORDER BY rr.RedemptionDate DESC;", conn))
            {
                cmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvAllRedemptions.DataSource = dt;
                    gvAllRedemptions.DataBind();
                }
            }

            if (!string.IsNullOrEmpty(rewardName))
            {
                lblStatus.Text = $"<div class='alert alert-info'><strong>Filtered by Reward:</strong> {HttpUtility.HtmlEncode(rewardName)} | <a href='AdminViewRedemptions.aspx' class='alert-link'>Show All Redemptions</a></div>";
            }
        }

        protected void gvAllRedemptions_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int redemptionId = Convert.ToInt32(gvAllRedemptions.DataKeys[e.RowIndex].Value);
            DeleteRedemption(redemptionId);
        }

        private void DeleteRedemption(int redemptionId)
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(@"DELETE FROM dbo.RewardRedemptions WHERE RedemptionID = @RedemptionID;", conn))
                {
                    cmd.Parameters.Add("@RedemptionID", SqlDbType.Int).Value = redemptionId;
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();
                    
                    if (rowsAffected > 0)
                    {
                        ShowStatus("✅ Redemption deleted successfully.", false);
                        
                        // Rebind based on current filter
                        string rewardIdParam = Request.QueryString["rewardId"];
                        if (!string.IsNullOrEmpty(rewardIdParam))
                        {
                            BindRedemptionsByReward(Convert.ToInt32(rewardIdParam));
                        }
                        else
                        {
                            BindAllRedemptions();
                        }
                    }
                    else
                    {
                        ShowStatus("❌ Redemption not found or could not be deleted.", true);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowStatus($"❌ Error deleting redemption: {ex.Message}", true);
            }
        }

        protected void ddlRewardName_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindAllRedemptions();
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindAllRedemptions();
        }

        private void ShowStatus(string message, bool isError)
        {
            string safe = HttpUtility.HtmlEncode(message);
            lblStatus.Text = $"<div class='{(isError ? "msg-err" : "msg-ok")}'>{safe}</div>";
        }
    }
}
