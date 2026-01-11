using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class PointsTransactions : System.Web.UI.Page
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
                LoadTransactions();
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

        private void LoadTransactions()
        {
            if (Session["CustomerID"] == null)
            {
                rptTransactions.Visible = false;
                lblEmpty.Visible = true;
                return;
            }

            int customerId = Convert.ToInt32(Session["CustomerID"]);
            string typeFilter = ddlTransactionType.SelectedValue;
            string sortBy = ddlSort.SelectedValue;
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            // Whitelist sort options
            string[] allowedSorts = { "TransactionDate DESC", "TransactionDate ASC", "Points DESC", "Points ASC" };
            if (Array.IndexOf(allowedSorts, sortBy) == -1)
            {
                sortBy = "TransactionDate DESC";
            }

            string query = @"
SELECT TransactionID, TransactionType, Points, Description, TransactionDate, ExpiryDate
FROM dbo.PointsTransactions
WHERE CustomerID = @CustomerID";

            if (!string.IsNullOrWhiteSpace(typeFilter))
            {
                query += " AND TransactionType = @TransactionType";
            }

            query += " ORDER BY " + sortBy;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                if (!string.IsNullOrWhiteSpace(typeFilter))
                {
                    cmd.Parameters.Add("@TransactionType", SqlDbType.NVarChar, 50).Value = typeFilter;
                }

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptTransactions.DataSource = dt;
                        rptTransactions.DataBind();
                        lblEmpty.Visible = false;
                        rptTransactions.Visible = true;
                    }
                    else
                    {
                        rptTransactions.Visible = false;
                        lblEmpty.Visible = true;
                    }
                }
            }
        }

        protected void ddlTransactionType_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTransactions();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTransactions();
        }

        protected string GetTransactionTypeClass(object transactionType)
        {
            if (transactionType == null || transactionType == DBNull.Value)
                return "";

            string type = transactionType.ToString().ToLower();
            if (type == "earned" || type == "spinwheel")
                return "earned";
            if (type == "spent" || type == "redeemed")
                return "spent";
            if (type == "used")
                return "spent"; // Used rewards are displayed as spent type
            if (type == "expired")
                return "expired";
            return "";
        }

        protected string GetTransactionTypeDisplay(object transactionType)
        {
            if (transactionType == null || transactionType == DBNull.Value)
                return "Unknown";

            string type = transactionType.ToString();
            switch (type)
            {
                case "Earned":
                    return "Earned";
                case "Spent":
                    return "Spent";
                case "SpinWheel":
                    return "Spin Wheel";
                case "Redeemed":
                    return "Redeemed";
                case "Used":
                    return "Used";
                case "Expired":
                    return "Expired";
                default:
                    return type;
            }
        }

        protected string GetExpiryBadge(object expiryDate)
        {
            if (expiryDate == null || expiryDate == DBNull.Value)
                return "";

            try
            {
                DateTime expiry = Convert.ToDateTime(expiryDate);
                DateTime now = DateTime.Now;
                
                if (expiry > now)
                {
                    TimeSpan remaining = expiry - now;
                    int daysRemaining = (int)remaining.TotalDays;
                    
                    if (daysRemaining <= 30)
                    {
                        return $"<span class='expiry-badge'>⚠️ Expires in {daysRemaining} days</span>";
                    }
                    else if (daysRemaining <= 90)
                    {
                        return $"<span class='expiry-badge'>Expires: {expiry.ToString("dd MMM yyyy")}</span>";
                    }
                }
                else
                {
                    return "<span class='expiry-badge' style='background:#dc3545;color:white;'>Expired</span>";
                }
            }
            catch
            {
                return "";
            }

            return "";
        }
    }
}
