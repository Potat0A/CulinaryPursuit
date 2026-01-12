using System;

namespace CulinaryPursuit
{
    public partial class ReviewPrompt : System.Web.UI.Page
    {
        private int OrderID
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["orderId"], out id) ? id : 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Must be logged in customer
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // OrderID is REQUIRED
            if (OrderID == 0)
            {
                Response.Redirect("CustomerOrdering.aspx");
                return;
            }
        }

        protected void btnYes_Click(object sender, EventArgs e)
        {
            // Redirect to review page WITH orderId
            Response.Redirect($"RestaurantReviews.aspx?orderId={OrderID}");
        }

        protected void btnNo_Click(object sender, EventArgs e)
        {
            // Skip review, go back to ordering
            Response.Redirect("CustomerOrdering.aspx");
        }
    }
}