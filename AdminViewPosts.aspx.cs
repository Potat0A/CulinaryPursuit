using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class AdminViewPosts : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

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
                LoadPosts();
            }
        }

        private void LoadPosts()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
SELECT P.PostID, P.Caption, P.ImagePath, P.CreatedAt, C.Name AS CustomerName
FROM CommunityPosts P
INNER JOIN Customers C ON P.CustomerID = C.CustomerID
ORDER BY P.CreatedAt DESC";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvPosts.DataSource = dt;
                gvPosts.DataBind();
            }
        }

        protected void gvPosts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeletePost")
            {
                int postID = Convert.ToInt32(e.CommandArgument);
                DeletePost(postID);
                LoadPosts();
            }
        }

        private void DeletePost(int postID)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Delete related likes and comments first
                string deleteLikes = "DELETE FROM PostLikes WHERE PostID=@PostID";
                string deleteComments = "DELETE FROM PostComments WHERE PostID=@PostID";
                string deletePost = "DELETE FROM CommunityPosts WHERE PostID=@PostID";

                SqlCommand cmd = new SqlCommand(deleteLikes, conn);
                cmd.Parameters.AddWithValue("@PostID", postID);
                cmd.ExecuteNonQuery();

                cmd.CommandText = deleteComments;
                cmd.ExecuteNonQuery();

                cmd.CommandText = deletePost;
                cmd.ExecuteNonQuery();
            }

            lblMessage.Text = "Post deleted successfully!";
        }

        protected void btnBack_Click1(object sender, EventArgs e)
        {
            Response.Redirect("AdminDashboard.aspx");
        }
    }
}
