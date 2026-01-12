using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace CulinaryPursuit
{
    public partial class AdminReviews : System.Web.UI.Page
    {
        private string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

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
                LoadReviews();
            }
        }

        private void LoadReviews()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT r.ReviewID, rest.Name AS RestaurantName,
                           c.Name AS CustomerName, c.Phone,
                           r.Rating, r.TasteRating, r.AffordabilityRating, r.Comment, r.CreatedAt
                    FROM Reviews r
                    INNER JOIN Customers c ON r.CustomerID = c.CustomerID
                    INNER JOIN Restaurants rest ON r.RestaurantID = rest.RestaurantID
                    ORDER BY r.CreatedAt DESC";

                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvReviews.DataSource = dt;
                gvReviews.DataBind();
            }
        }

        protected void gvReviews_RowDeleting(object sender, System.Web.UI.WebControls.GridViewDeleteEventArgs e)
        {
            int reviewId = Convert.ToInt32(gvReviews.DataKeys[e.RowIndex].Value);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string deleteQuery = "DELETE FROM Reviews WHERE ReviewID=@ReviewID";
                SqlCommand cmd = new SqlCommand(deleteQuery, conn);
                cmd.Parameters.AddWithValue("@ReviewID", reviewId);
                conn.Open();
                cmd.ExecuteNonQuery();
                conn.Close();
            }

            lblMessage.Text = "Review deleted successfully!";
            LoadReviews();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("AdminDashboard.aspx");
        }

    }
}
