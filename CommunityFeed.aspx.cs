using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class CommunityFeed : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

        int CustomerID => Session["CustomerID"] == null ? 0 : Convert.ToInt32(Session["CustomerID"]);

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
            {
                Response.Redirect("Login.aspx", false);
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
SELECT 
    P.PostID, P.Caption, P.ImagePath, P.CreatedAt,
    C.Name AS CustomerName,
    (SELECT COUNT(*) FROM PostLikes L WHERE L.PostID = P.PostID) AS LikeCount,
    CASE WHEN EXISTS(
        SELECT 1 FROM PostLikes WHERE PostID = P.PostID AND CustomerID = @CustomerID
    ) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsLiked
FROM CommunityPosts P
INNER JOIN Customers C ON P.CustomerID = C.CustomerID
ORDER BY P.CreatedAt DESC";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@CustomerID", CustomerID);

                DataTable dt = new DataTable();
                da.Fill(dt);

                // Add comments for each post
                dt.Columns.Add("Comments", typeof(DataTable));
                foreach (DataRow row in dt.Rows)
                {
                    row["Comments"] = GetComments(Convert.ToInt32(row["PostID"]));
                }

                rptPosts.DataSource = dt;
                rptPosts.DataBind();
            }
        }

        private DataTable GetComments(int postID)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
SELECT pc.Comment, c.Name AS CustomerName
FROM PostComments pc
INNER JOIN Customers c ON pc.CustomerID = c.CustomerID
WHERE pc.PostID = @PostID
ORDER BY pc.CreatedAt";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                da.SelectCommand.Parameters.AddWithValue("@PostID", postID);

                DataTable dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        protected void rptPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (CustomerID == 0)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            int postID = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Like")
                ToggleLike(postID);
            else if (e.CommandName == "Comment")
            {
                TextBox txt = (TextBox)e.Item.FindControl("txtComment");
                if (!string.IsNullOrWhiteSpace(txt.Text))
                    AddComment(postID, txt.Text.Trim());
            }

            LoadPosts();
        }

        private void ToggleLike(int postID)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string sql = @"
IF EXISTS (SELECT 1 FROM PostLikes WHERE PostID=@PostID AND CustomerID=@CustomerID)
    DELETE FROM PostLikes WHERE PostID=@PostID AND CustomerID=@CustomerID
ELSE
    INSERT INTO PostLikes (PostID, CustomerID) VALUES (@PostID, @CustomerID)";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@PostID", postID);
                cmd.Parameters.AddWithValue("@CustomerID", CustomerID);
                cmd.ExecuteNonQuery();
            }
        }

        private void AddComment(int postID, string comment)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"INSERT INTO PostComments (PostID, CustomerID, Comment) 
                               VALUES (@PostID, @CustomerID, @Comment)";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@PostID", postID);
                cmd.Parameters.AddWithValue("@CustomerID", CustomerID);
                cmd.Parameters.AddWithValue("@Comment", comment);

                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // Helper for comment count in the collapse button
        protected int GetCommentCount(object comments)
        {
            if (comments == null) return 0;
            DataTable dt = comments as DataTable;
            if (dt == null) return 0;
            return dt.Rows.Count;
        }
        protected void btnAddPost_Click(object sender, EventArgs e)
        {
            Response.Redirect("CustomerCreatePost.aspx");
        }
    }

}
