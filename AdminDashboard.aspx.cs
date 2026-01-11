using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CulinaryPursuit
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
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
            }
        }

        private void LoadStats()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                lblPending.Text = ExecuteScalar(conn,
                    "SELECT COUNT(*) FROM dbo.Restaurants WHERE ApprovalStatus = N'Pending'");

                lblApproved.Text = ExecuteScalar(conn,
                    "SELECT COUNT(*) FROM dbo.Restaurants WHERE ApprovalStatus = N'Approved'");

                lblCustomers.Text = ExecuteScalar(conn,
                    "SELECT COUNT(*) FROM dbo.Customers");

                lblOrders.Text = ExecuteScalar(conn,
                    "SELECT COUNT(*) FROM dbo.Orders");
            }
        }

        private string ExecuteScalar(SqlConnection conn, string query)
        {
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                object result = cmd.ExecuteScalar();
                return result == null || result == DBNull.Value ? "0" : result.ToString();
            }
        }
    }
}