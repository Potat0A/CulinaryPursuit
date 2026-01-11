using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CulinaryPursuit
{
    public partial class AdminLogin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminID"] != null)
                Response.Redirect("AdminDashboard.aspx");
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            {
                ShowError("Please fill in all fields.");
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = @"
SELECT UserID, Email
FROM dbo.Users
WHERE Email = @Email
  AND PasswordHash = @PasswordHash
  AND UserType = N'Admin'
  AND IsActive = 1;";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 255).Value = email;
                    cmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 500).Value = HashPassword(password);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            Session["AdminID"] = Convert.ToInt32(reader["UserID"]);
                            Session["AdminEmail"] = reader["Email"].ToString();

                            Response.Redirect("AdminDashboard.aspx");
                        }
                        else
                        {
                            ShowError("Invalid credentials. Try again.");
                        }
                    }
                }
            }
        }

        private string HashPassword(string password)
        {
            using (var sha256 = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(bytes);
            }
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            lblError.Visible = true;
        }
    }
}
