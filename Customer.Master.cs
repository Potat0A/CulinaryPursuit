using System;
using System.Web.UI;

namespace CulinaryPursuit
{
    public partial class CustomerMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                if (!IsPostBack)
                {
                    // Display customer name in navigation
                    if (Session["CustomerName"] != null)
                    {
                        lblNavName.Text = Session["CustomerName"].ToString();
                    }
                    else
                    {
                        lblNavName.Text = "Guest";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"CustomerMaster Page_Load Error: {ex.Message}");
                lblNavName.Text = "Guest";
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            try
            {
                Session.Clear();
                Session.Abandon();
                Response.Redirect("Landing.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Logout Error: {ex.Message}");
                Response.Redirect("Landing.aspx");
            }
        }
    }
}