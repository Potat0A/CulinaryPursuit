using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace CulinaryPursuit
{
    public partial class Signup : Page
    {
        protected void btnCustomerSignup_Click(object sender, EventArgs e)
        {
            // Validation
            if (txtPassword.Text != txtConfirm.Text)
            {
                ShowAlert("❌ Passwords do not match!");
                return;
            }

            if (txtPassword.Text.Trim().Length < 8)
            {
                ShowAlert("❌ Password must be at least 8 characters!");
                return;
            }

            string email = txtEmail.Text.Trim();
            string passwordHash = HashPassword(txtPassword.Text.Trim());
            string name = txtName.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();

            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        // 1) Check if email already exists
                        using (SqlCommand cmdCheck = new SqlCommand(
                            "SELECT COUNT(1) FROM dbo.Users WHERE Email = @Email;", conn, tx))
                        {
                            cmdCheck.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email;

                            int count = Convert.ToInt32(cmdCheck.ExecuteScalar());
                            if (count > 0)
                            {
                                tx.Rollback();
                                ShowAlert("❌ Email already registered! Please login or use a different email.");
                                return;
                            }
                        }

                        // 2) Insert into Users and get UserID
                        int newUserId;
                        using (SqlCommand cmdUser = new SqlCommand(@"
INSERT INTO dbo.Users (Email, PasswordHash, UserType, IsActive)
OUTPUT INSERTED.UserID
VALUES (@Email, @PasswordHash, N'Customer', 1);", conn, tx))
                        {
                            cmdUser.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email;
                            cmdUser.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 500).Value = passwordHash;

                            newUserId = Convert.ToInt32(cmdUser.ExecuteScalar());
                        }

                        // 3) Insert into Customers
                        using (SqlCommand cmdCust = new SqlCommand(@"
INSERT INTO dbo.Customers (UserID, Name, Phone, Address, RewardPoints, TotalOrders)
VALUES (@UserID, @Name, @Phone, @Address, 0, 0);", conn, tx))
                        {
                            cmdCust.Parameters.Add("@UserID", SqlDbType.Int).Value = newUserId;
                            cmdCust.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = name;
                            cmdCust.Parameters.Add("@Phone", SqlDbType.NVarChar, 20).Value = phone;
                            cmdCust.Parameters.Add("@Address", SqlDbType.NVarChar, 500).Value =
                                string.IsNullOrWhiteSpace(address) ? (object)DBNull.Value : address;

                            cmdCust.ExecuteNonQuery();
                        }

                        tx.Commit();

                        ShowAlert("🎉 Account created successfully! Redirecting to login...");
                        Response.AddHeader("REFRESH", "2;URL=Login.aspx");
                    }
                    catch (Exception ex)
                    {
                        try { tx.Rollback(); } catch { /* ignore */ }
                        ShowAlert($"❌ Error: {ex.Message}");
                    }
                }
            }
        }

        protected void btnChefSignup_Click(object sender, EventArgs e)
        {
            // Validation
            if (txtChefPassword.Text != txtChefConfirm.Text)
            {
                ShowAlert("❌ Passwords do not match!");
                return;
            }

            if (txtChefPassword.Text.Trim().Length < 8)
            {
                ShowAlert("❌ Password must be at least 8 characters!");
                return;
            }

            if (string.IsNullOrWhiteSpace(txtChefStory.Text) || txtChefStory.Text.Trim().Length < 50)
            {
                ShowAlert("❌ Please share your story (minimum 50 characters)!");
                return;
            }

            string email = txtChefEmail.Text.Trim();
            string passwordHash = HashPassword(txtChefPassword.Text.Trim());
            string restaurantName = txtRestaurantName.Text.Trim();
            string chefName = txtChefName.Text.Trim();
            string phone = txtChefPhone.Text.Trim();
            string address = txtChefAddress.Text.Trim();
            string cuisineType = txtCuisine.Text.Trim();
            string chefStory = txtChefStory.Text.Trim();

            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        // 1) Check email exists
                        using (SqlCommand cmdCheck = new SqlCommand(
                            "SELECT COUNT(1) FROM dbo.Users WHERE Email = @Email;", conn, tx))
                        {
                            cmdCheck.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email;

                            int count = Convert.ToInt32(cmdCheck.ExecuteScalar());
                            if (count > 0)
                            {
                                tx.Rollback();
                                ShowAlert("❌ Email already registered! Please login or use a different email.");
                                return;
                            }
                        }

                        // 2) Insert user and get UserID
                        int newUserId;
                        using (SqlCommand cmdUser = new SqlCommand(@"
INSERT INTO dbo.Users (Email, PasswordHash, UserType, IsActive)
OUTPUT INSERTED.UserID
VALUES (@Email, @PasswordHash, N'Restaurant', 1);", conn, tx))
                        {
                            cmdUser.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email;
                            cmdUser.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 500).Value = passwordHash;

                            newUserId = Convert.ToInt32(cmdUser.ExecuteScalar());
                        }

                        // 3) Insert restaurant
                        // NOTE: Your SQL Server schema doesn't have ChefStory, so we store it in Description.
                        using (SqlCommand cmdRest = new SqlCommand(@"
INSERT INTO dbo.Restaurants
(UserID, Name, Description, ChefName, Phone, Address, CuisineType, ApprovalStatus, Rating, TotalReviews, IsActive)
VALUES
(@UserID, @Name, @Description, @ChefName, @Phone, @Address, @CuisineType, N'Pending', 0.00, 0, 1);", conn, tx))
                        {
                            cmdRest.Parameters.Add("@UserID", SqlDbType.Int).Value = newUserId;
                            cmdRest.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = restaurantName;
                            cmdRest.Parameters.Add("@Description", SqlDbType.NVarChar, 1000).Value = chefStory; // ← story saved here
                            cmdRest.Parameters.Add("@ChefName", SqlDbType.NVarChar, 200).Value = chefName;
                            cmdRest.Parameters.Add("@Phone", SqlDbType.NVarChar, 20).Value = phone;
                            cmdRest.Parameters.Add("@Address", SqlDbType.NVarChar, 500).Value = address;
                            cmdRest.Parameters.Add("@CuisineType", SqlDbType.NVarChar, 100).Value = cuisineType;

                            cmdRest.ExecuteNonQuery();
                        }

                        tx.Commit();

                        ShowAlert("🍳 Chef account created! Your application is pending admin approval. Redirecting to login...");
                        Response.AddHeader("REFRESH", "4;URL=Login.aspx");
                    }
                    catch (Exception ex)
                    {
                        try { tx.Rollback(); } catch { /* ignore */ }
                        ShowAlert($"❌ Error: {ex.Message}");
                    }
                }
            }
        }

        /// <summary>
        /// Hash password using SHA256 (Base64). Consider BCrypt in production.
        /// </summary>
        private string HashPassword(string password)
        {
            using (var sha256 = System.Security.Cryptography.SHA256.Create())
            {
                var bytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(bytes);
            }
        }

        private void ShowAlert(string msg)
        {
            msg = msg.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", "").Replace("\n", "");
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('{msg}');", true);
        }
    }
}
