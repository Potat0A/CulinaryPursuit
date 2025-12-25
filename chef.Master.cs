using System;
using System.Configuration;
using System.Data.SqlClient;


namespace CulinaryPursuit
{
    public partial class Chef : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null ||
                Session["UserType"]?.ToString() != "Restaurant" ||
                Session["RestaurantID"] == null)
            {
                Session.Clear();
                Response.Redirect("Login.aspx?expired=1");
                return;
            }

            if (!IsPostBack)
            {
                lblRestaurantName.Text =
                    Session["RestaurantName"]?.ToString() ?? "My Restaurant";

                lblChefTopName.Text = lblRestaurantName.Text;

                LoadProfileImage();
            }
        }

        private void LoadProfileImage()
        {
            int restaurantId = Convert.ToInt32(Session["RestaurantID"]);

            string connStr =
                ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            string sql = "SELECT Logo FROM Restaurants WHERE RestaurantID = @RestaurantID";

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@RestaurantID", restaurantId);

                conn.Open();
                object result = cmd.ExecuteScalar();

                if (result != DBNull.Value && result != null)
                {
                    byte[] imageBytes = (byte[])result;

                    imgProfile.ImageUrl =
                        "data:image/png;base64," +
                        Convert.ToBase64String(imageBytes);
                }
            }
        }



        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Login.aspx");
        }
    }
}