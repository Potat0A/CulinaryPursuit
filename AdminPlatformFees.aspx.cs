// Author: Henry
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class AdminPlatformFees : Page
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
                LoadRestaurants();
                LoadStatistics();
                LoadFees();
            }
        }

        private void LoadRestaurants()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT RestaurantID, Name
                    FROM dbo.Restaurants
                    WHERE ApprovalStatus = N'Approved'
                    ORDER BY Name", conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    ddlRestaurant.DataSource = reader;
                    ddlRestaurant.DataTextField = "Name";
                    ddlRestaurant.DataValueField = "RestaurantID";
                    ddlRestaurant.DataBind();
                    ddlRestaurant.Items.Insert(0, new ListItem("All Restaurants", ""));
                }
            }
        }

        private void LoadStatistics()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Pending fees
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) AS Count, ISNULL(SUM(FeeAmount), 0) AS Total
                    FROM dbo.PlatformFees
                    WHERE FeeStatus = N'Pending'
                        AND DueDate >= CAST(GETDATE() AS DATE)", conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblPendingCount.Text = reader["Count"].ToString();
                        lblPendingTotal.Text = Convert.ToDecimal(reader["Total"]).ToString("F2");
                    }
                }

                // Overdue fees
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) AS Count, ISNULL(SUM(FeeAmount), 0) AS Total
                    FROM dbo.PlatformFees
                    WHERE FeeStatus IN (N'Pending', N'Overdue')
                        AND DueDate < CAST(GETDATE() AS DATE)", conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblOverdueCount.Text = reader["Count"].ToString();
                        lblOverdueTotal.Text = Convert.ToDecimal(reader["Total"]).ToString("F2");
                    }
                }

                // Paid this month
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) AS Count, ISNULL(SUM(FeeAmount), 0) AS Total
                    FROM dbo.PlatformFees
                    WHERE FeeStatus = N'Paid'
                        AND MONTH(PaidDate) = MONTH(GETDATE())
                        AND YEAR(PaidDate) = YEAR(GETDATE())", conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        lblPaidCount.Text = reader["Count"].ToString();
                        lblPaidTotal.Text = Convert.ToDecimal(reader["Total"]).ToString("F2");
                    }
                }

                // Total revenue (all time)
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(FeeAmount), 0) AS Total
                    FROM dbo.PlatformFees
                    WHERE FeeStatus = N'Paid'", conn))
                {
                    object result = cmd.ExecuteScalar();
                    lblTotalRevenue.Text = Convert.ToDecimal(result).ToString("F2");
                }

                // Auto-update overdue status
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.PlatformFees
                    SET FeeStatus = N'Overdue'
                    WHERE FeeStatus = N'Pending'
                        AND DueDate < CAST(GETDATE() AS DATE)", conn))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void LoadFees()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = @"
                    SELECT
                        pf.PlatformFeeID,
                        pf.OrderID,
                        pf.FeeAmount,
                        pf.FeePercentage,
                        pf.FeeStatus,
                        pf.DueDate,
                        pf.PaidDate,
                        pf.PaymentMethod,
                        r.Name AS RestaurantName,
                        r.RestaurantID
                    FROM dbo.PlatformFees pf
                    INNER JOIN dbo.Restaurants r ON pf.RestaurantID = r.RestaurantID
                    WHERE 1=1";

                // Apply filters
                if (!string.IsNullOrWhiteSpace(ddlStatus.SelectedValue))
                {
                    query += " AND pf.FeeStatus = @Status";
                }

                if (!string.IsNullOrWhiteSpace(ddlRestaurant.SelectedValue))
                {
                    query += " AND r.RestaurantID = @RestaurantID";
                }

                query += @" ORDER BY
                    CASE
                        WHEN pf.FeeStatus = N'Overdue' THEN 1
                        WHEN pf.FeeStatus = N'Pending' THEN 2
                        WHEN pf.FeeStatus = N'Paid' THEN 3
                        ELSE 4
                    END,
                    pf.DueDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrWhiteSpace(ddlStatus.SelectedValue))
                    {
                        cmd.Parameters.Add("@Status", SqlDbType.NVarChar, 20).Value = ddlStatus.SelectedValue;
                    }

                    if (!string.IsNullOrWhiteSpace(ddlRestaurant.SelectedValue))
                    {
                        cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = Convert.ToInt32(ddlRestaurant.SelectedValue);
                    }

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptFees.DataSource = dt;
                            rptFees.DataBind();
                            pnlFees.Visible = true;
                            pnlNoFees.Visible = false;
                        }
                        else
                        {
                            pnlFees.Visible = false;
                            pnlNoFees.Visible = true;
                        }
                    }
                }
            }
        }

        protected void btnApplyFilter_Click(object sender, EventArgs e)
        {
            LoadFees();
        }

        protected void rptFees_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int feeID = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Waive")
            {
                WaiveFee(feeID);
            }
            else if (e.CommandName == "Extend")
            {
                ExtendDueDate(feeID);
            }

            LoadStatistics();
            LoadFees();
        }

        private void WaiveFee(int feeID)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.PlatformFees
                    SET FeeStatus = N'Waived',
                        Notes = ISNULL(Notes, '') + ' | Waived by admin on ' + CONVERT(NVARCHAR, GETDATE(), 120)
                    WHERE PlatformFeeID = @FeeID", conn))
                {
                    cmd.Parameters.Add("@FeeID", SqlDbType.Int).Value = feeID;
                    cmd.ExecuteNonQuery();
                }
            }

            ShowAlert("✅ Fee has been waived successfully!");
        }

        private void ExtendDueDate(int feeID)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.PlatformFees
                    SET DueDate = DATEADD(DAY, 30, DueDate),
                        FeeStatus = N'Pending',
                        Notes = ISNULL(Notes, '') + ' | Extended by admin on ' + CONVERT(NVARCHAR, GETDATE(), 120)
                    WHERE PlatformFeeID = @FeeID", conn))
                {
                    cmd.Parameters.Add("@FeeID", SqlDbType.Int).Value = feeID;
                    cmd.ExecuteNonQuery();
                }
            }

            ShowAlert("✅ Due date extended by 30 days!");
        }

        protected string GetStatusClass(string status)
        {
            switch (status)
            {
                case "Pending":
                    return "status-pending";
                case "Overdue":
                    return "status-overdue";
                case "Paid":
                    return "status-paid";
                case "Waived":
                    return "status-waived";
                default:
                    return "";
            }
        }

        private void ShowAlert(string message)
        {
            string script = $"alert('{message.Replace("'", "\\'")}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", script, true);
        }
    }
}
