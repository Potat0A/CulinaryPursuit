using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class PaymentVoucherSimulator : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check customer authentication
            if (Session["CustomerID"] == null)
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                string redemptionIdParam = Request.QueryString["redemptionId"];
                if (string.IsNullOrEmpty(redemptionIdParam))
                {
                    ShowStatus("Error: No redemption ID provided.", true);
                    return;
                }

                int redemptionId = Convert.ToInt32(redemptionIdParam);
                hdnRedemptionID.Value = redemptionIdParam;

                LoadRedemptionDetails(redemptionId);
                CalculateTotals();
            }
        }

        private void LoadRedemptionDetails(int redemptionId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT rr.RedemptionID, rr.CustomerID, rr.PointsUsed, rr.RedemptionDate, rr.Status,
       r.RewardID, r.Name, r.Description, r.Category, r.DiscountPercentage, r.VoucherAmount
FROM dbo.RewardRedemptions rr
INNER JOIN dbo.Rewards r ON rr.RewardID = r.RewardID
WHERE rr.RedemptionID = @RedemptionID AND rr.CustomerID = @CustomerID", conn))
            {
                cmd.Parameters.Add("@RedemptionID", SqlDbType.Int).Value = redemptionId;
                cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = Session["CustomerID"];

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string category = reader["Category"].ToString();
                        string rewardName = reader["Name"].ToString();
                        string description = reader["Description"] == DBNull.Value ? "" : reader["Description"].ToString();

                        lblRewardName.Text = rewardName;
                        lblRewardDescription.Text = string.IsNullOrWhiteSpace(description) ? "No description available." : description;
                        pnlRewardApplied.Visible = true;

                        // Show appropriate fields based on category
                        if (category == "Discounts")
                        {
                            pnlDiscount.Visible = true;
                            decimal discountPct = reader["DiscountPercentage"] == DBNull.Value ? 0 : Convert.ToDecimal(reader["DiscountPercentage"]);
                            lblDiscountPercentage.Text = discountPct.ToString("0.00");
                        }
                        else if (category == "Vouchers")
                        {
                            pnlVoucher.Visible = true;
                            decimal voucherAmt = reader["VoucherAmount"] == DBNull.Value ? 0 : Convert.ToDecimal(reader["VoucherAmount"]);
                            lblVoucherAmount.Text = voucherAmt.ToString("0.00");
                        }
                        else if (category == "Free Items")
                        {
                            pnlFreeItem.Visible = true;
                        }
                    }
                    else
                    {
                        ShowStatus("Error: Redemption not found or you don't have access to it.", true);
                    }
                }
            }
        }

        private void CalculateTotals()
        {
            decimal subtotal = 100.00m; // Default order subtotal
            decimal discountAmount = 0.00m;
            decimal tax = 0.00m;
            decimal finalTotal = 0.00m;

            // Calculate discount based on reward type
            if (pnlDiscount.Visible)
            {
                decimal discountPct = Convert.ToDecimal(lblDiscountPercentage.Text);
                discountAmount = subtotal * (discountPct / 100);
            }
            else if (pnlVoucher.Visible)
            {
                decimal voucherAmt = Convert.ToDecimal(lblVoucherAmount.Text);
                discountAmount = voucherAmt; // Voucher amount is deducted directly
            }
            else if (pnlFreeItem.Visible)
            {
                discountAmount = subtotal; // Free item means full discount
            }

            decimal discountedSubtotal = subtotal - discountAmount;
            tax = discountedSubtotal * 0.10m; // 10% tax
            finalTotal = discountedSubtotal + tax;

            // Update labels
            lblSubtotal.Text = subtotal.ToString("0.00");
            lblDiscountAmount.Text = discountAmount.ToString("0.00");
            lblTax.Text = tax.ToString("0.00");
            lblTotalSubtotal.Text = subtotal.ToString("0.00");
            lblTotalDiscount.Text = discountAmount.ToString("0.00");
            lblTotalTax.Text = tax.ToString("0.00");
            lblFinalTotal.Text = finalTotal.ToString("0.00");
        }

        protected void btnCompletePayment_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hdnPaymentMethod.Value))
            {
                ShowStatus("Please select a payment method.", true);
                return;
            }

            int redemptionId = Convert.ToInt32(hdnRedemptionID.Value);
            int customerId = Convert.ToInt32(Session["CustomerID"]);

            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (SqlTransaction trans = conn.BeginTransaction())
                {
                    try
                    {
                        // Get reward details for transaction record
                        string rewardName = "";
                        int rewardId = 0;
                        using (SqlCommand getRewardCmd = new SqlCommand(@"
SELECT r.RewardID, r.Name
FROM dbo.RewardRedemptions rr
INNER JOIN dbo.Rewards r ON rr.RewardID = r.RewardID
WHERE rr.RedemptionID = @RedemptionID", conn, trans))
                        {
                            getRewardCmd.Parameters.Add("@RedemptionID", SqlDbType.Int).Value = redemptionId;
                            using (SqlDataReader reader = getRewardCmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    rewardId = Convert.ToInt32(reader["RewardID"]);
                                    rewardName = reader["Name"].ToString();
                                }
                            }
                        }

                        // Update redemption status to "Used"
                        using (SqlCommand updateCmd = new SqlCommand(@" 
UPDATE dbo.RewardRedemptions 
SET Status = 'Used'
WHERE RedemptionID = @RedemptionID AND CustomerID = @CustomerID", conn, trans))
                        {
                            updateCmd.Parameters.Add("@RedemptionID", SqlDbType.Int).Value = redemptionId;
                            updateCmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                            updateCmd.ExecuteNonQuery();
                        }

                        // Record transaction when reward is used
                        using (SqlCommand transCmd = new SqlCommand(@"
INSERT INTO dbo.PointsTransactions (CustomerID, TransactionType, Points, Description, RelatedID, TransactionDate)
VALUES (@CustomerID, 'Used', @Points, @Description, @RewardID, GETDATE())", conn, trans))
                        {
                            transCmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                            transCmd.Parameters.Add("@Points", SqlDbType.Int).Value = 0; // No points change when using
                            transCmd.Parameters.Add("@Description", SqlDbType.NVarChar, 500).Value = 
                                $"Used reward: {rewardName}";
                            transCmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                            transCmd.ExecuteNonQuery();
                        }

                        trans.Commit();

                        ShowStatus("Payment completed successfully! Your reward has been used.", false);
                        btnCompletePayment.Enabled = false;
                        btnCompletePayment.Text = "Payment Completed";

                        // Redirect after 3 seconds
                        string script = "setTimeout(function() { window.location.href = 'redeemrewards.aspx'; }, 3000);";
                        ClientScript.RegisterStartupScript(this.GetType(), "RedirectScript", script, true);
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        ShowStatus($"Error processing payment: {ex.Message}", true);
                    }
                }
            }
        }

        private void ShowStatus(string message, bool isError)
        {
            string safe = HttpUtility.HtmlEncode(message);
            lblStatus.Text = $"<div class='msg-status {(isError ? "msg-error" : "msg-success")}'>{safe}</div>";
        }
    }
}
