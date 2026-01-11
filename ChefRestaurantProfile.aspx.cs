using System;
using System.Configuration;
using System.Data.SqlClient;

namespace CulinaryPursuit
{
    public partial class ChefRestaurantProfile : System.Web.UI.Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadRestaurant();
            }
        }

        private void LoadRestaurant()
        {
            int restaurantId = Convert.ToInt32(Session["RestaurantID"]);

            string sql = @"SELECT *
                           FROM Restaurants
                           WHERE RestaurantID = @RestaurantID";

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@RestaurantID", restaurantId);

                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    txtName.Text = dr["Name"].ToString();
                    txtChefName.Text = dr["ChefName"].ToString();
                    txtCuisine.Text = dr["CuisineType"].ToString();
                    txtDescription.Text = dr["Description"].ToString();
                    txtPhone.Text = dr["Phone"].ToString();
                    txtAddress.Text = dr["Address"].ToString();
                    txtOpeningHours.Text = dr["OpeningHours"].ToString();
                    lblBannerName.Text = dr["Name"].ToString();
                    lblBannerCuisine.Text = dr["CuisineType"].ToString();

                    // LOGO (unchanged – works)
                    if (dr["Logo"] != DBNull.Value)
                    {
                        byte[] logo = (byte[])dr["Logo"];
                        imgLogo.ImageUrl = "data:image/png;base64," +
                                           Convert.ToBase64String(logo);
                    }
                    else
                    {
                        imgLogo.ImageUrl = ResolveUrl("~/content/default-avatar.png");
                    }

                    // BANNER (NOW IDENTICAL LOGIC)
                    if (dr["Banner"] != DBNull.Value)
                    {
                        byte[] banner = (byte[])dr["Banner"];
                        imgBanner.ImageUrl = "data:image/png;base64," +
                                             Convert.ToBase64String(banner);
                    }
                    else
                    {
                        imgBanner.ImageUrl = ResolveUrl("~/content/default-banner.jpg");
                    }




                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int restaurantId = Convert.ToInt32(Session["RestaurantID"]);

            byte[] logoBytes = GetUploadedFileBytes(fuLogo);
            byte[] bannerBytes = GetUploadedFileBytes(fuBanner);

            string sql = @"
        UPDATE Restaurants
        SET Name = @Name,
            ChefName = @ChefName,
            CuisineType = @CuisineType,
            Description = @Description,
            Phone = @Phone,
            Address = @Address,
            OpeningHours = @OpeningHours,
            Logo = COALESCE(@Logo, Logo),
            Banner = COALESCE(@Banner, Banner)
        WHERE RestaurantID = @RestaurantID";

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Name", txtName.Text);
                cmd.Parameters.AddWithValue("@ChefName", txtChefName.Text);
                cmd.Parameters.AddWithValue("@CuisineType", txtCuisine.Text);
                cmd.Parameters.AddWithValue("@Description", txtDescription.Text);
                cmd.Parameters.AddWithValue("@Phone", txtPhone.Text);
                cmd.Parameters.AddWithValue("@Address", txtAddress.Text);
                cmd.Parameters.AddWithValue("@OpeningHours", txtOpeningHours.Text);

                cmd.Parameters.Add("@Logo", System.Data.SqlDbType.VarBinary)
                    .Value = (object)logoBytes ?? DBNull.Value;

                cmd.Parameters.Add("@Banner", System.Data.SqlDbType.VarBinary)
                    .Value = (object)bannerBytes ?? DBNull.Value;

                cmd.Parameters.AddWithValue("@RestaurantID", restaurantId);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            lblMessage.Text = "✅ Restaurant profile updated successfully!";
            lblMessage.CssClass = "text-success";
        }

        private byte[] GetUploadedFileBytes(System.Web.UI.WebControls.FileUpload fu)
        {
            if (fu.HasFile)
            {
                return fu.FileBytes;
            }
            return null;
        }

    }
}
