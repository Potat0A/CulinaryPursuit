using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace CulinaryPursuit
{
    public partial class ChefViewReviews : System.Web.UI.Page
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
                LoadReviews();
            }
        }

        private void LoadReviews()
        {
            if (Session["RestaurantID"] == null)
            {
                Response.Redirect("ChefLogin.aspx");
                return;
            }

            int restaurantID = Convert.ToInt32(Session["RestaurantID"]);

            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"]
                .ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
            SELECT 
                ReviewID,
                Rating,
                TasteRating,
                AffordabilityRating,
                Comment,
                Reply
            FROM Reviews
            WHERE RestaurantID = @RestaurantID
            ORDER BY CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", restaurantID);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvReviews.DataSource = dt;
                        gvReviews.DataBind();
                    }
                }
            }
        }

    }
}