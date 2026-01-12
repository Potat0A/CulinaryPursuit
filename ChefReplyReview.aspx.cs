using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace CulinaryPursuit
{
    public partial class ChefReplyReview : System.Web.UI.Page
    {
        protected int RestaurantID;
        protected int reviewId;

        protected void Page_Load(object sender, EventArgs e)
        {
            ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None;

            // --- AUTH GUARDS ---
            if (Session["UserID"] == null ||
                Session["UserType"]?.ToString() != "Restaurant" ||
                Session["RestaurantID"] == null)
            {
                Session.Clear();
                Response.Redirect("Login.aspx?expired=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // ✅ FIX: Read ReviewID safely
            if (!int.TryParse(Request.QueryString["ReviewID"], out reviewId))
            {
                Response.Redirect("ChefViewReviews.aspx");
                return;
            }

            RestaurantID = Convert.ToInt32(Session["RestaurantID"]);

            if (!IsPostBack)
            {
                LoadReviewDetails();
            }
        }


        private void LoadReviewDetails()
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"]
                .ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
            SELECT 
                c.Name AS CustomerName,
                c.Phone,
                r.Rating,
                r.TasteRating,
                r.AffordabilityRating,
                r.Comment
            FROM Reviews r
            INNER JOIN Customers c 
                ON r.CustomerID = c.CustomerID
            WHERE r.ReviewID = @ReviewID
              AND r.RestaurantID = @RestaurantID";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@ReviewID", reviewId);
                cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);

                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    lblCustomerName.Text = dr["CustomerName"].ToString();
                    lblPhone.Text = dr["Phone"].ToString();
                    lblOverall.Text = dr["Rating"].ToString();
                    lblTaste.Text = dr["TasteRating"].ToString();
                    lblAffordability.Text = dr["AffordabilityRating"].ToString();
                    lblComment.Text = dr["Comment"].ToString();
                }
                else
                {
                    // Extra safety
                    Response.Redirect("ChefViewReviews.aspx");
                }
            }
        }


        protected void btnSubmitReply_Click(object sender, EventArgs e)
        {
            string reply = txtReply.Text.Trim();

            if (reply == "")
            {
                lblMessage.Text = "Reply cannot be empty.";
                lblMessage.CssClass = "text-danger";
                return;
            }

            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"]
                .ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    UPDATE Reviews
                    SET Reply = @Reply
                    WHERE ReviewID = @ReviewID";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Reply", reply);
                cmd.Parameters.AddWithValue("@ReviewID", reviewId);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            Response.Redirect("ChefViewReviews.aspx");

        }
    }
}
