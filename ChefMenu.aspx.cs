using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class ChefMenu : System.Web.UI.Page
    {
        protected int RestaurantID;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Safety: this page has NO validators now, but keep this harmless line
            ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None;

            // --- AUTH GUARDS ---
            if (Session["UserID"] == null ||
                Session["UserType"]?.ToString() != "Restaurant" ||
                Session["RestaurantID"] == null)
            {
                Session.Clear();
                Response.Redirect("Login.aspx?expired=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            RestaurantID = Convert.ToInt32(Session["RestaurantID"]);

            if (!IsPostBack)
            {
                BindMenu();
            }
        }

        // --------------------
        // LOAD MENU
        // --------------------
        private void BindMenu()
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT MenuItemID, Name, Category, Price, IsAvailable
FROM dbo.MenuItems
WHERE RestaurantID = @RestaurantID
ORDER BY CreatedDate DESC;", conn))
            {
                cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvMenu.DataSource = dt;
                    gvMenu.DataBind();
                }
            }
        }

        // --------------------
        // GRIDVIEW EVENTS
        // --------------------
        protected void gvMenu_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvMenu.EditIndex = e.NewEditIndex;
            BindMenu();
        }

        protected void gvMenu_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvMenu.EditIndex = -1;
            BindMenu();
        }

        protected void gvMenu_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int menuItemId = Convert.ToInt32(gvMenu.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvMenu.Rows[e.RowIndex];

            string name = ((TextBox)row.FindControl("txtEditName"))?.Text.Trim() ?? "";
            string category = ((TextBox)row.FindControl("txtEditCategory"))?.Text.Trim() ?? "";
            string priceRaw = ((TextBox)row.FindControl("txtEditPrice"))?.Text.Trim() ?? "";
            bool available = ((CheckBox)row.FindControl("chkEditAvailable"))?.Checked ?? true;

            // --- VALIDATION ---
            if (name.Length < 2 || name.Length > 200)
            {
                ShowStatus("Update failed: Name must be 2–200 characters.", true);
                return;
            }

            if (string.IsNullOrWhiteSpace(category) || category.Length > 100)
            {
                ShowStatus("Update failed: Category is required.", true);
                return;
            }

            if (!decimal.TryParse(priceRaw, NumberStyles.AllowDecimalPoint,
                CultureInfo.InvariantCulture, out decimal price) ||
                price < 0.50m || price > 9999m)
            {
                ShowStatus("Update failed: Price must be between 0.50 and 9999.", true);
                return;
            }

            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
UPDATE dbo.MenuItems
SET Name = @Name,
    Category = @Category,
    Price = @Price,
    IsAvailable = @IsAvailable
WHERE MenuItemID = @MenuItemID
  AND RestaurantID = @RestaurantID;", conn))
            {
                cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = name;
                cmd.Parameters.Add("@Category", SqlDbType.NVarChar, 100).Value = category;
                cmd.Parameters.Add("@Price", SqlDbType.Decimal).Value = price;
                cmd.Parameters.Add("@IsAvailable", SqlDbType.Bit).Value = available;

                cmd.Parameters.Add("@MenuItemID", SqlDbType.Int).Value = menuItemId;
                cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            gvMenu.EditIndex = -1;
            ShowStatus("✅ Menu item updated.", false);
            BindMenu();
        }

        protected void gvMenu_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int menuItemId = Convert.ToInt32(gvMenu.DataKeys[e.RowIndex].Value);

            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
DELETE FROM dbo.MenuItems
WHERE MenuItemID = @MenuItemID
  AND RestaurantID = @RestaurantID;", conn))
            {
                cmd.Parameters.Add("@MenuItemID", SqlDbType.Int).Value = menuItemId;
                cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ShowStatus("🗑️ Menu item deleted.", false);
            BindMenu();
        }

        // --------------------
        // NAVIGATION
        // --------------------
        protected void btnGoAdd_Click(object sender, EventArgs e)
        {
            Response.Redirect("AddMenuItem.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // --------------------
        // UI HELPERS
        // --------------------
        private void ShowStatus(string message, bool isError)
        {
            string safe = HttpUtility.HtmlEncode(message);
            lblStatus.Text = $"<div class='{(isError ? "msg-err" : "msg-ok")}'>{safe}</div>";
        }
    }
}
