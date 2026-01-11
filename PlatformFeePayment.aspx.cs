// Author: Henry
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class PlatformFeePayment : Page
    {
        private int RestaurantID
        {
            get { return Session["RestaurantID"] != null ? Convert.ToInt32(Session["RestaurantID"]) : 0; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check authentication
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Restaurant")
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadStatistics();
                LoadUnpaidFees();
                LoadPaidFees();
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
                    WHERE RestaurantID = @RestaurantID
                        AND FeeStatus = N'Pending'
                        AND DueDate >= CAST(GETDATE() AS DATE)", conn))
                {
                    cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblPendingCount.Text = reader["Count"].ToString();
                            lblPendingTotal.Text = Convert.ToDecimal(reader["Total"]).ToString("F2");
                        }
                    }
                }

                // Overdue fees
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) AS Count, ISNULL(SUM(FeeAmount), 0) AS Total
                    FROM dbo.PlatformFees
                    WHERE RestaurantID = @RestaurantID
                        AND FeeStatus IN (N'Pending', N'Overdue')
                        AND DueDate < CAST(GETDATE() AS DATE)", conn))
                {
                    cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblOverdueCount.Text = reader["Count"].ToString();
                            lblOverdueTotal.Text = Convert.ToDecimal(reader["Total"]).ToString("F2");
                        }
                    }
                }

                // Paid this month
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) AS Count, ISNULL(SUM(FeeAmount), 0) AS Total
                    FROM dbo.PlatformFees
                    WHERE RestaurantID = @RestaurantID
                        AND FeeStatus = N'Paid'
                        AND MONTH(PaidDate) = MONTH(GETDATE())
                        AND YEAR(PaidDate) = YEAR(GETDATE())", conn))
                {
                    cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblPaidCount.Text = reader["Count"].ToString();
                            lblPaidTotal.Text = Convert.ToDecimal(reader["Total"]).ToString("F2");
                        }
                    }
                }

                // Update overdue status
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.PlatformFees
                    SET FeeStatus = N'Overdue'
                    WHERE RestaurantID = @RestaurantID
                        AND FeeStatus = N'Pending'
                        AND DueDate < CAST(GETDATE() AS DATE)", conn))
                {
                    cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void LoadUnpaidFees()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT
                        PlatformFeeID,
                        OrderID,
                        FeeAmount,
                        FeePercentage,
                        FeeStatus,
                        DueDate,
                        Notes
                    FROM dbo.PlatformFees
                    WHERE RestaurantID = @RestaurantID
                        AND FeeStatus IN (N'Pending', N'Overdue')
                    ORDER BY
                        CASE WHEN FeeStatus = N'Overdue' THEN 0 ELSE 1 END,
                        DueDate ASC", conn))
                {
                    cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptUnpaidFees.DataSource = dt;
                            rptUnpaidFees.DataBind();
                            pnlUnpaidFees.Visible = true;
                            pnlNoUnpaid.Visible = false;
                        }
                        else
                        {
                            pnlUnpaidFees.Visible = false;
                            pnlNoUnpaid.Visible = true;
                        }
                    }
                }
            }
        }

        private void LoadPaidFees()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 20
                        PlatformFeeID,
                        OrderID,
                        FeeAmount,
                        FeeStatus,
                        PaidDate,
                        PaymentMethod
                    FROM dbo.PlatformFees
                    WHERE RestaurantID = @RestaurantID
                        AND FeeStatus = N'Paid'
                    ORDER BY PaidDate DESC", conn))
                {
                    cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptPaidFees.DataSource = dt;
                            rptPaidFees.DataBind();
                            pnlPaidFees.Visible = true;
                            pnlNoPaid.Visible = false;
                        }
                        else
                        {
                            pnlPaidFees.Visible = false;
                            pnlNoPaid.Visible = true;
                        }
                    }
                }
            }
        }

        protected void rptUnpaidFees_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int feeID = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "PayNow")
            {
                // Open payment modal via JavaScript
                hfSelectedFeeID.Value = feeID.ToString();
                string script = $"showPaymentModal({feeID});";
                ScriptManager.RegisterStartupScript(this, GetType(), "showModal", script, true);
            }
            else if (e.CommandName == "RequestExtension")
            {
                RequestPaymentExtension(feeID);
            }
        }

        protected void btnConfirmPayment_Click(object sender, EventArgs e)
        {
            int feeID = Convert.ToInt32(hfSelectedFeeID.Value);
            ProcessPayment(feeID);
        }

        private void ProcessPayment(int feeID)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.PlatformFees
                    SET FeeStatus = N'Paid',
                        PaidDate = GETDATE(),
                        PaymentMethod = @PaymentMethod,
                        Notes = ISNULL(Notes, '') + ' | Transaction: ' + @TransactionRef
                    WHERE PlatformFeeID = @FeeID
                        AND RestaurantID = @RestaurantID", conn))
                {
                    cmd.Parameters.Add("@FeeID", SqlDbType.Int).Value = feeID;
                    cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;
                    cmd.Parameters.Add("@PaymentMethod", SqlDbType.NVarChar, 50).Value = ddlPaymentMethod.SelectedValue;
                    cmd.Parameters.Add("@TransactionRef", SqlDbType.NVarChar, 100).Value =
                        string.IsNullOrWhiteSpace(txtTransactionRef.Text) ? "N/A" : txtTransactionRef.Text;

                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowAlert("✅ Payment processed successfully!");
                        LoadStatistics();
                        LoadUnpaidFees();
                        LoadPaidFees();
                    }
                    else
                    {
                        ShowAlert("❌ Payment failed. Please try again.");
                    }
                }
            }

            // Clear form
            txtTransactionRef.Text = string.Empty;
            string closeScript = "closePaymentModal();";
            ScriptManager.RegisterStartupScript(this, GetType(), "closeModal", closeScript, true);
        }

        private void RequestPaymentExtension(int feeID)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Extend due date by 15 days
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE dbo.PlatformFees
                    SET DueDate = DATEADD(DAY, 15, DueDate),
                        FeeStatus = N'Pending',
                        Notes = ISNULL(Notes, '') + ' | Extension requested on ' + CONVERT(NVARCHAR, GETDATE(), 120)
                    WHERE PlatformFeeID = @FeeID
                        AND RestaurantID = @RestaurantID", conn))
                {
                    cmd.Parameters.Add("@FeeID", SqlDbType.Int).Value = feeID;
                    cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;

                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowAlert("✅ Payment extension granted! Due date extended by 15 days.");
                        LoadStatistics();
                        LoadUnpaidFees();
                    }
                    else
                    {
                        ShowAlert("❌ Extension request failed.");
                    }
                }
            }
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
