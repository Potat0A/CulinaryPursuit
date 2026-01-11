using System;

namespace CulinaryPursuit
{
    public partial class Admin : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if admin is logged in
            if (Session["AdminID"] == null)
            {
                Session.Clear();
                Response.Redirect("AdminLogin.aspx?expired=1", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                // Display admin email
                string adminEmail = Session["AdminEmail"]?.ToString() ?? "admin@culinarypursuit.com";
                lblAdminEmail.Text = adminEmail;

                // Display first letter of email as avatar initial
                if (!string.IsNullOrEmpty(adminEmail))
                {
                    lblAdminInitial.Text = adminEmail.Substring(0, 1).ToUpper();
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("AdminLogin.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
