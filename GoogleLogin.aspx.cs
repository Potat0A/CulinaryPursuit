using System;
using System.Configuration;
using System.Web;

namespace CulinaryPursuit
{
    public partial class GoogleLogin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string clientId = ConfigurationManager.AppSettings["GoogleClientId"];
            string redirectUri = "https://localhost:44321/GoogleCallback.aspx";

            string url =
                "https://accounts.google.com/o/oauth2/v2/auth" +
                "?client_id=" + clientId +
                "&response_type=code" +
                "&scope=openid%20email%20profile" +
                "&redirect_uri=" + HttpUtility.UrlEncode(redirectUri);

            Response.Redirect(url);
        }
    }
}