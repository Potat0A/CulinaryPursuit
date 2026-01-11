using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CulinaryPursuit
{
    public partial class RestaurantDashboard : System.Web.UI.Page
    {
        protected int RestaurantID;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Session.Clear();
                Response.Redirect("Login.aspx?expired=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (Session["UserType"] == null || Session["UserType"].ToString() != "Restaurant")
            {
                Session.Clear();
                Response.Redirect("Login.aspx?forbidden=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (Session["RestaurantID"] == null)
            {
                Session.Clear();
                Response.Redirect("Login.aspx?noRestaurantID=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            RestaurantID = Convert.ToInt32(Session["RestaurantID"]);

            if (!IsPostBack)
            {
                LoadDashboard();
            }
        }

        private void LoadDashboard()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Restaurant name
                lblRestaurantName.Text = ExecuteScalar(conn,
                    "SELECT Name FROM dbo.Restaurants WHERE RestaurantID = @RestaurantID");

                // Today orders (SQL Server)
                lblTodayOrders.Text = ExecuteScalar(conn, @"
SELECT COUNT(*)
FROM dbo.Orders
WHERE RestaurantID = @RestaurantID
  AND OrderDate >= CAST(GETDATE() AS date)
  AND OrderDate <  DATEADD(day, 1, CAST(GETDATE() AS date));");

                // Monthly earnings (current month + year)
                lblMonthlyEarnings.Text = ExecuteScalar(conn, @"
SELECT COALESCE(SUM(FinalAmount), 0)
FROM dbo.Orders
WHERE RestaurantID = @RestaurantID
  AND YEAR(OrderDate) = YEAR(GETDATE())
  AND MONTH(OrderDate) = MONTH(GETDATE());");

                // Rating
                lblRating.Text = ExecuteScalar(conn, @"SELECT COALESCE(AVG(CAST(Rating AS decimal(10,2))), 0)
FROM dbo.Reviews
WHERE RestaurantID = @RestaurantID
  AND IsActive = 1;");

                // Menu count
                lblTotalMenuItems.Text = ExecuteScalar(conn,
                    "SELECT COUNT(*) FROM dbo.MenuItems WHERE RestaurantID = @RestaurantID");
            }
        }

        private string ExecuteScalar(SqlConnection conn, string query)
        {
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = RestaurantID;

                object result = cmd.ExecuteScalar();
                return result == null || result == DBNull.Value ? "0" : result.ToString();
            }
        }
    }
}
