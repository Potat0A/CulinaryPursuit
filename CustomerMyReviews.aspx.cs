using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CulinaryPursuit
{
    public partial class CustomerMyReviews : System.Web.UI.Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadMyReviews();
            }
        }

        private void LoadMyReviews()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT
                        r.ReviewID,
                        r.Rating,
                        r.TasteRating,
                        r.AffordabilityRating,
                        r.Comment,
                        r.Reply,
                        r.CreatedAt,
                        res.Name AS RestaurantName
                    FROM Reviews r
                    INNER JOIN Restaurants res
                        ON r.RestaurantID = res.RestaurantID
                    WHERE r.CustomerID = @CustomerID
                      AND r.IsActive = 1
                    ORDER BY r.CreatedAt DESC";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CustomerID", Session["CustomerID"]);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count == 0)
                {
                    lblMessage.Text = "You have not written any reviews yet.";
                }

                rptReviews.DataSource = dt;
                rptReviews.DataBind();
            }
        }

        protected void rptReviews_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Edit")
            {
                int reviewId = Convert.ToInt32(e.CommandArgument);
                Response.Redirect($"EditReview.aspx?reviewId={reviewId}");
            }
        }
    }
}
