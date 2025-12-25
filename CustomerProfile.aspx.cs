using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace CulinaryPursuit
{
    public partial class CustomerProfile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                // Check if user is logged in
                if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
                {
                    Response.Redirect("Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                // Check if CustomerID exists
                if (Session["CustomerID"] == null)
                {
                    Response.Redirect("Login.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                if (!IsPostBack)
                {
                    LoadProfile();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"CustomerProfile Page_Load Error: {ex.Message}");

                Response.Write("<div style='padding:50px;text-align:center;'>");
                Response.Write("<h2>⚠️ Error Loading Profile</h2>");
                Response.Write($"<p>{HttpUtility.HtmlEncode(ex.Message)}</p>");
                Response.Write("<a href='CustomerHome.aspx'>← Back to Home</a>");
                Response.Write("</div>");
            }
        }

        private void LoadProfile()
        {
            int customerId = Convert.ToInt32(Session["CustomerID"]);
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Customer details
                string query = @"
SELECT c.Name, c.Phone, c.Address, c.RewardPoints, c.TotalOrders,
       c.PreferredCuisines, c.DietaryRestrictions, u.Email
FROM dbo.Customers c
INNER JOIN dbo.Users u ON c.UserID = u.UserID
WHERE c.CustomerID = @CustomerID;";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Header info
                            lblProfileName.Text = reader["Name"] as string ?? "Guest";
                            lblProfileEmail.Text = reader["Email"] as string ?? "";

                            // Stats
                            lblTotalOrders.Text = reader["TotalOrders"] == DBNull.Value ? "0" : reader["TotalOrders"].ToString();
                            lblRewardPoints.Text = reader["RewardPoints"] == DBNull.Value ? "0" : reader["RewardPoints"].ToString();

                            // Form fields
                            txtName.Text = reader["Name"] as string ?? "";
                            txtPhone.Text = reader["Phone"] as string ?? "";
                            txtAddress.Text = reader["Address"] as string ?? "";

                            txtPreferredCuisine.Text = reader["PreferredCuisines"] as string ?? "";
                            txtDietaryRestrictions.Text = reader["DietaryRestrictions"] as string ?? "";
                        }
                    }
                }

                // Favorites placeholder
                lblFavorites.Text = "0";
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            try
            {
                int customerId = Convert.ToInt32(Session["CustomerID"]);
                string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    string query = @"
UPDATE dbo.Customers
SET Name = @Name,
    Phone = @Phone,
    Address = @Address,
    PreferredCuisines = @PreferredCuisines,
    DietaryRestrictions = @DietaryRestrictions
WHERE CustomerID = @CustomerID;";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;

                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = txtName.Text.Trim();
                        cmd.Parameters.Add("@Phone", SqlDbType.NVarChar, 20).Value = txtPhone.Text.Trim();

                        string address = txtAddress.Text.Trim();
                        cmd.Parameters.Add("@Address", SqlDbType.NVarChar, 500).Value =
                            string.IsNullOrWhiteSpace(address) ? (object)DBNull.Value : address;

                        string preferred = txtPreferredCuisine.Text.Trim();
                        cmd.Parameters.Add("@PreferredCuisines", SqlDbType.NVarChar, 500).Value =
                            string.IsNullOrWhiteSpace(preferred) ? (object)DBNull.Value : preferred;

                        string dietary = txtDietaryRestrictions.Text.Trim();
                        cmd.Parameters.Add("@DietaryRestrictions", SqlDbType.NVarChar, 500).Value =
                            string.IsNullOrWhiteSpace(dietary) ? (object)DBNull.Value : dietary;

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // Update session
                            Session["CustomerName"] = txtName.Text.Trim();

                            // Show success message
                            string script = @"
document.getElementById('successMessage').classList.add('show');
setTimeout(() => {
    document.getElementById('successMessage').classList.remove('show');
}, 5000);";
                            ClientScript.RegisterStartupScript(this.GetType(), "ShowSuccess", script, true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Save Profile Error: {ex.Message}");

                string safe = HttpUtility.JavaScriptStringEncode(ex.Message);
                string script = $"alert('Error saving profile: {safe}');";
                ClientScript.RegisterStartupScript(this.GetType(), "ShowError", script, true);
            }
        }
    }
}
