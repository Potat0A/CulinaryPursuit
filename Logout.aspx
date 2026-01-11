protected void Page_Load(object sender, EventArgs e)
{
Session.Clear();
Session.Abandon();
Response.Redirect("AdminLogin.aspx");
}