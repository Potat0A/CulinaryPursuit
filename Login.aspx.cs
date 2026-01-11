using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;

namespace CulinaryPursuit
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is already logged in
            if (!IsPostBack && Session["UserID"] != null && Session["UserType"] != null)
            {
                string userType = Session["UserType"]?.ToString();

                if (userType == "Restaurant")
                {
                    if (Session["RestaurantID"] != null)
                    {
                        Response.Redirect("RestaurantDashboard.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                }
                else if (userType == "Customer")
                {
                    Response.Redirect("CustomerHome.aspx", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
            }
        }

        protected void btnCustomerLogin_Click(object sender, EventArgs e)
        {
            string email = txtCustomerEmail.Text.Trim();
            string password = txtCustomerPassword.Text.Trim();

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            {
                ShowError("customerError", "customerErrorText", "Please enter both email and password.");
                return;
            }

            var result = AuthenticateUser(email, password, "Customer");
            if (result == null)
            {
                ShowError("customerError", "customerErrorText", "Invalid email or password.");
                return;
            }

            // result: (UserID, DisplayName, RestaurantID, ApprovalStatus)
            Session["UserID"] = result.Value.UserID;
            Session["UserType"] = "Customer";
            Session["CustomerID"] = result.Value.ProfileID;          // CustomerID
            Session["CustomerName"] = result.Value.DisplayName;      // Customer Name
            Session["Email"] = email;

            Response.Redirect("CustomerHome.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnRestaurantLogin_Click(object sender, EventArgs e)
        {
            string email = txtRestaurantEmail.Text.Trim();
            string password = txtRestaurantPassword.Text.Trim();

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            {
                ShowError("restaurantError", "restaurantErrorText", "Please enter both email and password.");
                return;
            }

            var result = AuthenticateUser(email, password, "Restaurant");
            if (result == null)
            {
                ShowError("restaurantError", "restaurantErrorText", "Invalid email or password.");
                return;
            }

            // Optional: block unapproved restaurants
            // if (!string.Equals(result.Value.ApprovalStatus, "Approved", StringComparison.OrdinalIgnoreCase))
            // {
            //     ShowError("restaurantError", "restaurantErrorText", $"Your account is {result.Value.ApprovalStatus}.");
            //     return;
            // }

            Session["UserID"] = result.Value.UserID;
            Session["UserType"] = "Restaurant";
            Session["RestaurantID"] = result.Value.ProfileID;        // RestaurantID
            Session["RestaurantName"] = result.Value.DisplayName;    // Restaurant Name
            Session["Email"] = email;

            Response.Redirect("RestaurantDashboard.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        /// <summary>
        /// Authenticates a user against dbo.Users and joins the correct profile table.
        /// Returns null if invalid credentials / inactive user / missing profile.
        /// </summary>
        private AuthResult? AuthenticateUser(string email, string password, string userType)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;
            string passwordHash = HashPassword(password);

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = conn.CreateCommand())
            {
                conn.Open();

                if (userType == "Customer")
                {
                    // Matches your schema: Users + Customers
                    cmd.CommandText = @"
SELECT u.UserID, c.CustomerID AS ProfileID, c.Name AS DisplayName
FROM dbo.Users u
INNER JOIN dbo.Customers c ON u.UserID = c.UserID
WHERE u.Email = @Email
  AND u.PasswordHash = @PasswordHash
  AND u.UserType = N'Customer'
  AND u.IsActive = 1;
";
                }
                else if (userType == "Restaurant")
                {
                    // Matches your schema: Users + Restaurants (no ChefStory in your posted schema)
                    cmd.CommandText = @"
SELECT u.UserID, r.RestaurantID AS ProfileID, r.Name AS DisplayName, r.ApprovalStatus
FROM dbo.Users u
INNER JOIN dbo.Restaurants r ON u.UserID = r.UserID
WHERE u.Email = @Email
  AND u.PasswordHash = @PasswordHash
  AND u.UserType = N'Restaurant'
  AND u.IsActive = 1
  AND r.IsActive = 1;
";
                }
                else
                {
                    return null;
                }

                cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email;
                cmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 500).Value = passwordHash;

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                        return null;

                    int userId = Convert.ToInt32(reader["UserID"]);
                    int profileId = Convert.ToInt32(reader["ProfileID"]);
                    string displayName = reader["DisplayName"].ToString();

                    string approvalStatus = null;
                    if (userType == "Restaurant" && reader["ApprovalStatus"] != DBNull.Value)
                        approvalStatus = reader["ApprovalStatus"].ToString();

                    return new AuthResult
                    {
                        UserID = userId,
                        ProfileID = profileId,
                        DisplayName = displayName,
                        ApprovalStatus = approvalStatus
                    };
                }
            }
        }

        private struct AuthResult
        {
            public int UserID;
            public int ProfileID;          // CustomerID or RestaurantID
            public string DisplayName;     // Customer Name or Restaurant Name
            public string ApprovalStatus;  // Restaurant only (nullable)
        }

        private string HashPassword(string password)
        {
            using (var sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(bytes);
            }
        }

        // You can keep VerifyPassword, but now we compare hashes in SQL query.
        // Keeping it in case you use it elsewhere.
        private bool VerifyPassword(string inputPassword, string storedHash)
        {
            string inputHash = HashPassword(inputPassword);
            return inputHash == storedHash;
        }

        private void ShowError(string errorDivId, string errorTextId, string message)
        {
            // Basic escaping to avoid breaking JS if message contains quotes
            string safeMessage = message.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\r", "").Replace("\n", "");

            string script = $@"
document.getElementById('{errorDivId}').classList.add('show');
document.getElementById('{errorTextId}').textContent = '{safeMessage}';
";
            ClientScript.RegisterStartupScript(this.GetType(), "ShowError", script, true);
        }
    }
}
