using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;

namespace CulinaryPursuit
{
    public partial class AddMenuItem : System.Web.UI.Page
    {
        protected int RestaurantID;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Guard (same style as your dashboard)
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Restaurant" || Session["RestaurantID"] == null)
            {
                Session.Clear();
                Response.Redirect("Login.aspx?expired=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            RestaurantID = Convert.ToInt32(Session["RestaurantID"]);
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("ChefMenu.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            // Extra server-side validations (realistic)
            string name = (txtName.Text ?? "").Trim();
            string category = ddlCategory.SelectedValue;
            string description = (txtDescription.Text ?? "").Trim();
            string imageUrl = (txtImageUrl.Text ?? "").Trim();

            if (name.Length < 2 || name.Length > 200)
            {
                ShowStatus("Name must be 2–200 characters.", true);
                return;
            }

            if (!TryParseMoney(txtPrice.Text, out decimal price) || price < 0.50m || price > 9999m)
            {
                ShowStatus("Price must be valid and between 0.50 and 9999.", true);
                return;
            }

            if (!int.TryParse((txtSpicy.Text ?? "0").Trim(), out int spicy) || spicy < 0 || spicy > 5)
            {
                ShowStatus("Spicy level must be 0–5.", true);
                return;
            }

            int? prepTime = null;
            string prepRaw = (txtPrepTime.Text ?? "").Trim();
            if (!string.IsNullOrWhiteSpace(prepRaw))
            {
                if (!int.TryParse(prepRaw, out int p) || p < 1 || p > 240)
                {
                    ShowStatus("Prep time must be 1–240 (or leave empty).", true);
                    return;
                }
                prepTime = p;
            }

            if (!string.IsNullOrEmpty(imageUrl) &&
                !(imageUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                  imageUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase)))
            {
                ShowStatus("Image URL must start with http:// or https://", true);
                return;
            }

            bool isAvailable = chkAvailable.Checked;
            bool isVeg = chkVegetarian.Checked;
            bool isVegan = chkVegan.Checked;
            bool isHalal = chkHalal.Checked;

            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
INSERT INTO dbo.MenuItems
(RestaurantID, Name, Description, Price, ImageURL, Category, IsAvailable, IsVegetarian, IsVegan, IsHalal, SpicyLevel, PrepTime, CreatedDate)
VALUES
(@RestaurantID, @Name, @Description, @Price, @ImageURL, @Category, @IsAvailable, @IsVegetarian, @IsVegan, @IsHalal, @SpicyLevel, @PrepTime, GETDATE());", conn))
            {
                cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;
                cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = name;
                cmd.Parameters.Add("@Description", SqlDbType.NVarChar, 1000).Value =
                    string.IsNullOrWhiteSpace(description) ? (object)DBNull.Value : description;
                cmd.Parameters.Add("@Price", SqlDbType.Decimal).Value = price;
                cmd.Parameters.Add("@ImageURL", SqlDbType.NVarChar, 500).Value =
                    string.IsNullOrWhiteSpace(imageUrl) ? (object)DBNull.Value : imageUrl;
                cmd.Parameters.Add("@Category", SqlDbType.NVarChar, 100).Value = category;

                cmd.Parameters.Add("@IsAvailable", SqlDbType.Bit).Value = isAvailable;
                cmd.Parameters.Add("@IsVegetarian", SqlDbType.Bit).Value = isVeg;
                cmd.Parameters.Add("@IsVegan", SqlDbType.Bit).Value = isVegan;
                cmd.Parameters.Add("@IsHalal", SqlDbType.Bit).Value = isHalal;

                cmd.Parameters.Add("@SpicyLevel", SqlDbType.Int).Value = spicy;
                cmd.Parameters.Add("@PrepTime", SqlDbType.Int).Value =
                    prepTime.HasValue ? (object)prepTime.Value : DBNull.Value;

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            // After save: go back to menu list
            Response.Redirect("ChefMenu.aspx?added=1", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowStatus(string message, bool isError)
        {
            string safe = HttpUtility.HtmlEncode(message);
            lblStatus.Text = $"<div class='{(isError ? "msg-err" : "msg-ok")}'>{safe}</div>";
        }

        private bool TryParseMoney(string input, out decimal value)
        {
            return decimal.TryParse(
                input,
                NumberStyles.AllowDecimalPoint | NumberStyles.AllowLeadingWhite | NumberStyles.AllowTrailingWhite,
                CultureInfo.InvariantCulture,
                out value
            );
        }
    }
}
