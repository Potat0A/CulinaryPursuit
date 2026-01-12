using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class RecommendedRestaurants : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

        int CustomerID => Session["CustomerID"] != null ? Convert.ToInt32(Session["CustomerID"]) : 0;

        protected string WeatherDescription { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadRecommendedRestaurants();
            }
        }


        #region Weather API
        public class WeatherData
        {
            public double Temperature { get; set; }
            public string Description { get; set; }
        }

        private WeatherData GetWeather(string city)
        {
            string apiKey = "4d1428044be8fcf348c27a5c803f32e7"; // Replace with your OpenWeatherMap API key
            try
            {
                string url = $"https://api.openweathermap.org/data/2.5/weather?q={city}&units=metric&appid={apiKey}";
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
                request.Method = "GET";

                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                {
                    string json = reader.ReadToEnd();
                    JavaScriptSerializer js = new JavaScriptSerializer();
                    dynamic data = js.Deserialize<dynamic>(json);

                    WeatherData wd = new WeatherData
                    {
                        Temperature = Convert.ToDouble(data["main"]["temp"]),
                        Description = data["weather"][0]["description"].ToString().ToLower()
                    };
                    return wd;
                }
            }
            catch
            {
                return null;
            }
        }
        #endregion

        private void LoadRecommendedRestaurants()
        {
            if (CustomerID == 0)
            {
                // Customer not logged in
                return;
            }

            string preferredCuisines = "";
            string dietaryRestrictions = "";

            // Get customer preferences
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "SELECT PreferredCuisines, DietaryRestrictions FROM Customers WHERE CustomerID=@CustomerID";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CustomerID", CustomerID);
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    preferredCuisines = dr["PreferredCuisines"].ToString();
                    dietaryRestrictions = dr["DietaryRestrictions"].ToString();
                }
                conn.Close();
            }

            // Get live weather
            WeatherData weather = GetWeather("Singapore");
            if (weather != null)
            {
                litWeather.Text = $@"
<div class='alert alert-info mb-4'>
    🌤️ <strong>Singapore Weather:</strong> {weather.Description}, {weather.Temperature}°C  
    <br />
    <small>Recommendations adjusted for today</small>
</div>";
            }


            // Fetch restaurants
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Decide filters first
                int? maxSpicy = null;
                bool needVeg = false;
                bool needVegan = false;
                bool needHalal = false;

                // Weather → spicy filtering
                if (weather != null)
                {
                    if (weather.Description.Contains("rain"))
                    {
                        maxSpicy = 3;
                        litWeather.Text += "<br/><small>🌧️ Reduced spicy food due to rain</small>";
                    }

                    if (weather.Temperature >= 32)
                    {
                        // If already set by rain, keep the stricter one
                        maxSpicy = maxSpicy.HasValue ? Math.Min(maxSpicy.Value, 2) : 2;
                        litWeather.Text += "<br/><small>🔥 Lighter dishes recommended for hot weather</small>";
                    }
                }

                // Dietary restrictions → strict filtering
                if (!string.IsNullOrWhiteSpace(dietaryRestrictions))
                {
                    string dr = dietaryRestrictions.ToLower();

                    if (dr.Contains("vegetarian"))
                    {
                        needVeg = true;
                        litWeather.Text += "<br/><small>🥬 Vegetarian dishes only</small>";
                    }
                    if (dr.Contains("vegan"))
                    {
                        needVegan = true;
                        litWeather.Text += "<br/><small>🌱 Vegan dishes only</small>";
                    }
                    if (dr.Contains("halal"))
                    {
                        needHalal = true;
                        litWeather.Text += "<br/><small>🕌 Halal-certified dishes only</small>";
                    }
                }

                string sql = @"
SELECT
    r.RestaurantID,
    r.Name,
    r.ChefName,
    r.Description,
    r.Banner,
    mi.MenuItemID,
    mi.IsAvailable,
    COALESCE(AVG(CAST(rv.Rating AS decimal(10,2))), 0) AS Rating
FROM Restaurants r
LEFT JOIN Reviews rv
    ON r.RestaurantID = rv.RestaurantID
    AND rv.IsActive = 1
OUTER APPLY (
    SELECT TOP 1
        m.MenuItemID,
        m.IsAvailable
    FROM MenuItems m
    WHERE m.RestaurantID = r.RestaurantID
      AND m.IsAvailable = 1
      AND (@MaxSpicy IS NULL OR m.SpicyLevel <= @MaxSpicy)
      AND (@NeedVeg = 0 OR m.IsVegetarian = 1)
      AND (@NeedVegan = 0 OR m.IsVegan = 1)
      AND (@NeedHalal = 0 OR m.IsHalal = 1)
    ORDER BY m.CreatedDate DESC
) mi
WHERE r.IsActive = 1
  AND mi.MenuItemID IS NOT NULL
GROUP BY
    r.RestaurantID,
    r.Name,
    r.ChefName,
    r.Description,
    r.Banner,
    mi.MenuItemID,
    mi.IsAvailable
ORDER BY Rating DESC;
";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.Add("@MaxSpicy", SqlDbType.Int).Value =
                        (object)maxSpicy ?? DBNull.Value;

                    cmd.Parameters.Add("@NeedVeg", SqlDbType.Bit).Value = needVeg;
                    cmd.Parameters.Add("@NeedVegan", SqlDbType.Bit).Value = needVegan;
                    cmd.Parameters.Add("@NeedHalal", SqlDbType.Bit).Value = needHalal;

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        rptRestaurants.DataSource = dt;
                        rptRestaurants.DataBind();
                    }
                }

            }
        }
        public string GetBannerImage(object bannerObj)
        {
            if (bannerObj != DBNull.Value && bannerObj != null)
            {
                byte[] bytes = (byte[])bannerObj;
                return "data:image/png;base64," + Convert.ToBase64String(bytes);
            }

            return ResolveUrl("~/content/default-banner.jpg");
        }

        protected void rptRestaurants_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "AddToCart")
            {
                int menuItemID = Convert.ToInt32(e.CommandArgument);
                AddToCart(menuItemID);
            }
        }

        private void AddToCart(int menuItemID)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmdCheck = new SqlCommand(@"
            SELECT CartID, Quantity
            FROM dbo.Cart
            WHERE CustomerID = @CustomerID AND MenuItemID = @MenuItemID", conn))
                {
                    cmdCheck.Parameters.AddWithValue("@CustomerID", CustomerID);
                    cmdCheck.Parameters.AddWithValue("@MenuItemID", menuItemID);

                    using (SqlDataReader reader = cmdCheck.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int cartID = Convert.ToInt32(reader["CartID"]);
                            int quantity = Convert.ToInt32(reader["Quantity"]);
                            reader.Close();

                            using (SqlCommand cmdUpdate = new SqlCommand(@"
                        UPDATE dbo.Cart
                        SET Quantity = @Quantity
                        WHERE CartID = @CartID", conn))
                            {
                                cmdUpdate.Parameters.AddWithValue("@Quantity", quantity + 1);
                                cmdUpdate.Parameters.AddWithValue("@CartID", cartID);
                                cmdUpdate.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            reader.Close();

                            using (SqlCommand cmdInsert = new SqlCommand(@"
                        INSERT INTO dbo.Cart (CustomerID, MenuItemID, Quantity)
                        VALUES (@CustomerID, @MenuItemID, 1)", conn))
                            {
                                cmdInsert.Parameters.AddWithValue("@CustomerID", CustomerID);
                                cmdInsert.Parameters.AddWithValue("@MenuItemID", menuItemID);
                                cmdInsert.ExecuteNonQuery();
                            }
                        }
                    }
                }
            }

            ShowAlert("✅ Item added to cart!");
        }

        private void ShowAlert(string message)
        {
            string script = $"alert('{message.Replace("'", "\\'")}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", script, true);
        }

    }
}
