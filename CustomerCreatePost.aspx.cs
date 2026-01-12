using System;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;

namespace CulinaryPursuit
{
    public partial class CustomerCreatePost : System.Web.UI.Page
    {
        string connStr = ConfigurationManager
            .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null)
            {
                Response.Redirect("Login.aspx");
            }
        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            if (!fuPhoto.HasFile)
            {
                lblMessage.Text = "Please upload a photo.";
                return;
            }

            string folder = "~/Upload/Community/";
            Directory.CreateDirectory(Server.MapPath(folder));

            string fileName = Guid.NewGuid() + Path.GetExtension(fuPhoto.FileName);
            string path = folder + fileName;
            fuPhoto.SaveAs(Server.MapPath(path));

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"INSERT INTO CommunityPosts
                               (CustomerID, ImagePath, Caption)
                               VALUES (@CustomerID, @ImagePath, @Caption)";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@CustomerID", Session["CustomerID"]);
                cmd.Parameters.AddWithValue("@ImagePath", path);
                cmd.Parameters.AddWithValue("@Caption", txtCaption.Text.Trim());

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            Response.Redirect("CommunityFeed.aspx");
        }
    }
}