using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net;
using System.Web;
using Newtonsoft.Json.Linq;

namespace CulinaryPursuit
{
    public partial class GoogleCallBack : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string code = Request.QueryString["code"];
            if (string.IsNullOrEmpty(code))
            {
                Response.Redirect("Login.aspx");
                return;
            }

            try
            {
                // 1️⃣ Exchange code for token
                using (WebClient client = new WebClient())
                {
                    var values = new System.Collections.Specialized.NameValueCollection();
                    values["code"] = code;
                    values["client_id"] = ConfigurationManager.AppSettings["GoogleClientId"];
                    values["client_secret"] = ConfigurationManager.AppSettings["GoogleClientSecret"];
                    // Ensure this port matches your project settings (44321 vs 63372)
                    values["redirect_uri"] = "https://localhost:44321/GoogleCallback.aspx";
                    values["grant_type"] = "authorization_code";

                    // UploadValues automatically sets Content-Type to application/x-www-form-urlencoded
                    byte[] responseBytes = client.UploadValues("https://oauth2.googleapis.com/token", values);
                    string tokenResponse = System.Text.Encoding.UTF8.GetString(responseBytes);

                    JObject tokenJson = JObject.Parse(tokenResponse);
                    string accessToken = tokenJson["access_token"].ToString();

                    // 2️⃣ Get user info
                    client.Headers.Clear(); // Clear previous headers
                    client.Headers.Add("Authorization", "Bearer " + accessToken);
                    string userInfoResponse = client.DownloadString("https://www.googleapis.com/oauth2/v3/userinfo");

                    JObject userInfo = JObject.Parse(userInfoResponse);

                    string email = userInfo["email"].ToString();
                    string googleId = userInfo["sub"].ToString();
                    string name = userInfo["name"].ToString();

                    HandleGoogleUser(email, googleId, name);
                }
            }
            catch (WebException ex)
            {
                // Debugging: This allows you to see the actual error message from Google's server
                using (var stream = ex.Response.GetResponseStream())
                using (var reader = new System.IO.StreamReader(stream))
                {
                    Response.Write("Google API Error: " + reader.ReadToEnd());
                }
                Response.End();
            }
        }

        private void HandleGoogleUser(string email, string googleId, string name)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                int userId;

                // 1️⃣ Find Google user by ExternalProviderID (NOT email)
                SqlCommand cmd = new SqlCommand(@"
            SELECT UserID 
            FROM Users
            WHERE AuthProvider = 'Google'
              AND ExternalProviderID = @GoogleID
              AND IsActive = 1", conn);

                cmd.Parameters.AddWithValue("@GoogleID", googleId);

                object existingUserId = cmd.ExecuteScalar();

                if (existingUserId == null)
                {
                    // 2️⃣ Create Users record
                    cmd = new SqlCommand(@"
                INSERT INTO Users
                    (Email, PasswordHash, UserType, IsActive, AuthProvider, ExternalProviderID)
                OUTPUT INSERTED.UserID
                VALUES
                    (@Email, 'OAUTH_EXTERNAL_USER', 'Customer', 1, 'Google', @GoogleID)", conn);

                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@GoogleID", googleId);

                    userId = Convert.ToInt32(cmd.ExecuteScalar());

                    // 3️⃣ Create Customer profile
                    cmd = new SqlCommand(@"
                INSERT INTO Customers (UserID, Name, Phone)
                VALUES (@UserID, @Name, 'N/A')", conn);

                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@Name", name);

                    cmd.ExecuteNonQuery();
                }
                else
                {
                    userId = Convert.ToInt32(existingUserId);
                }

                // 4️⃣ Fetch CustomerID
                int customerId;

                // 1️⃣ Try get CustomerID
                cmd = new SqlCommand(@"
    SELECT CustomerID 
    FROM Customers 
    WHERE UserID = @UserID", conn);

                cmd.Parameters.AddWithValue("@UserID", userId);

                object result = cmd.ExecuteScalar();

                if (result == null || result == DBNull.Value)
                {
                    // 2️⃣ Create customer if missing (THIS FIXES YOUR BUG)
                    cmd = new SqlCommand(@"
        INSERT INTO Customers (UserID, Name, Phone)
        OUTPUT INSERTED.CustomerID
        VALUES (@UserID, @Name, 'N/A')", conn);

                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@Name", name);

                    customerId = Convert.ToInt32(cmd.ExecuteScalar());
                }
                else
                {
                    customerId = Convert.ToInt32(result);
                }


                // 5️⃣ Set session (MATCHES normal login)
                Session["UserID"] = userId;
                Session["CustomerID"] = customerId;
                Session["UserType"] = "Customer";
                Session["CustomerName"] = name;
                Session["Email"] = email;

                // 6️⃣ Redirect
                Response.Redirect("CustomerHome.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

    }
}
