using System;
using System.Configuration;
using System.Data.SqlClient;

namespace CulinaryPursuit
{
    public partial class EditReview : System.Web.UI.Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

        private int ReviewID;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!int.TryParse(Request.QueryString["reviewId"], out ReviewID))
            {
                Response.Redirect("CustomerMyReviews.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadReview();
            }
        }

        private void LoadReview()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT Rating, TasteRating, AffordabilityRating, Comment
                    FROM Reviews
                    WHERE ReviewID = @ReviewID
                      AND CustomerID = @CustomerID";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@ReviewID", ReviewID);
                cmd.Parameters.AddWithValue("@CustomerID", Session["CustomerID"]);

                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (!dr.Read())
                {
                    Response.Redirect("CustomerMyReviews.aspx");
                    return;
                }

                ddlOverall.SelectedValue = dr["Rating"].ToString();
                ddlTaste.SelectedValue = dr["TasteRating"].ToString();
                ddlAffordability.SelectedValue = dr["AffordabilityRating"].ToString();
                txtComment.Text = dr["Comment"].ToString();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    UPDATE Reviews
                    SET Rating = @Rating,
                        TasteRating = @Taste,
                        AffordabilityRating = @Affordability,
                        Comment = @Comment
                    WHERE ReviewID = @ReviewID
                      AND CustomerID = @CustomerID";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@Rating", ddlOverall.SelectedValue);
                cmd.Parameters.AddWithValue("@Taste", ddlTaste.SelectedValue);
                cmd.Parameters.AddWithValue("@Affordability", ddlAffordability.SelectedValue);
                cmd.Parameters.AddWithValue("@Comment", txtComment.Text.Trim());
                cmd.Parameters.AddWithValue("@ReviewID", ReviewID);
                cmd.Parameters.AddWithValue("@CustomerID", Session["CustomerID"]);

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            Response.Redirect("CustomerMyReviews.aspx");
        }
    }
}
