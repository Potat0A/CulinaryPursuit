using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CulinaryPursuit
{
    public partial class Landing : System.Web.UI.Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadFeaturedRestaurants();
            }
        }

        private void LoadFeaturedRestaurants()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT TOP 6
                        RestaurantID,
                        Name,
                        Description,
                        Rating,
                        CASE
                            WHEN Banner IS NOT NULL THEN
                                'data:image/png;base64,' + 
                                CAST('' AS XML).value(
                                    'xs:base64Binary(sql:column(""Banner""))',
                                    'varchar(max)'
                                )
                            ELSE
                                '~/content/default-banner.jpg'
                        END AS ImageUrl
                    FROM Restaurants
                    WHERE IsActive = 1
                      AND ApprovalStatus = 'Approved'
                    ORDER BY Rating DESC";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptFeaturedRestaurants.DataSource = dt;
                    rptFeaturedRestaurants.DataBind();
                }
            }
        }
    }
}