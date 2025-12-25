using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CulinaryPursuit
{
    public partial class AdminApproval : System.Web.UI.Page
    {
        protected int PendingChefs = 0;
        protected int ApprovedChefs = 0;
        protected int TotalCustomers = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminID"] == null)
            {
                Response.Redirect("AdminLogin.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadStats();
                LoadApplications();
            }
        }

        private void LoadStats()
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                PendingChefs = ExecuteCount(conn,
                    "SELECT COUNT(*) FROM dbo.Restaurants WHERE ApprovalStatus = N'Pending'");

                ApprovedChefs = ExecuteCount(conn,
                    "SELECT COUNT(*) FROM dbo.Restaurants WHERE ApprovalStatus = N'Approved'");

                TotalCustomers = ExecuteCount(conn,
                    "SELECT COUNT(*) FROM dbo.Customers");
            }
        }

        private int ExecuteCount(SqlConnection conn, string query)
        {
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private void LoadApplications()
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = @"
SELECT 
    RestaurantID,
    ChefName,
    Name,
    Phone,
    CuisineType,
    Address,
    Description AS ChefStory,
    CreatedDate
FROM dbo.Restaurants
WHERE ApprovalStatus = N'Pending'
ORDER BY CreatedDate DESC;";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataReader rdr = cmd.ExecuteReader())
                {
                    rptApplications.DataSource = rdr;
                    rptApplications.DataBind();
                }
            }

            pnlEmpty.Visible = (rptApplications.Items.Count == 0);
        }

        protected void rptApplications_ItemCommand(
            object source,
            System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            int restaurantID = Convert.ToInt32(e.CommandArgument);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                if (e.CommandName == "Approve")
                {
                    using (SqlCommand cmd = new SqlCommand(@"
UPDATE dbo.Restaurants
SET ApprovalStatus = N'Approved',
    ApprovedDate = GETDATE()
WHERE RestaurantID = @ID;", conn))
                    {
                        cmd.Parameters.Add("@ID", SqlDbType.Int).Value = restaurantID;
                        cmd.ExecuteNonQuery();
                    }
                }
                else if (e.CommandName == "Reject")
                {
                    using (SqlCommand cmd = new SqlCommand(@"
UPDATE dbo.Restaurants
SET ApprovalStatus = N'Rejected'
WHERE RestaurantID = @ID;", conn))
                    {
                        cmd.Parameters.Add("@ID", SqlDbType.Int).Value = restaurantID;
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            // Refresh after update
            LoadStats();
            LoadApplications();
        }
    }
}
