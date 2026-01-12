using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;

namespace CulinaryPursuit
{
    public partial class CustomerHome : System.Web.UI.Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check for general login first
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Optional: If you specifically need the CustomerID for queries on this page
            if (Session["CustomerID"] != null)
            {
                int customerId = (int)Session["CustomerID"];
                LoadFeaturedRestaurants();
                // Load data for this customer...
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