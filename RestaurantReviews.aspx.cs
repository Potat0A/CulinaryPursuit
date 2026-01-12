using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace CulinaryPursuit
{
    public partial class RestaurantReviews : System.Web.UI.Page
    {
        private readonly string connStr =
            ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

        private int OrderID;
        private int RestaurantID
        {
            get { return ViewState["RestaurantID"] != null ? (int)ViewState["RestaurantID"] : 0; }
            set { ViewState["RestaurantID"] = value; }
        }


        protected void Page_Load(object sender, EventArgs e)
        {
            // Must be logged in as customer
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Must come from a valid order
            if (!int.TryParse(Request.QueryString["orderId"], out OrderID))
            {
                Response.Redirect("CustomerOrdering.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadRestaurantFromOrder();
                LoadRestaurantDetails();
                LoadReviews();
                CheckCustomerLogin();
            }
        }

        // 🔐 SECURITY: Get restaurant ONLY from order
        private void LoadRestaurantFromOrder()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = @"
                    SELECT RestaurantID
                    FROM Orders
                    WHERE OrderID = @OrderID
                      AND CustomerID = @CustomerID";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@OrderID", OrderID);
                cmd.Parameters.AddWithValue("@CustomerID", Session["CustomerID"]);

                conn.Open();
                object result = cmd.ExecuteScalar();

                if (result == null)
                {
                    // User trying to access order not belonging to them
                    Response.Redirect("CustomerOrdering.aspx");
                    return;
                }

                RestaurantID = Convert.ToInt32(result);
            }
        }

        private void CheckCustomerLogin()
        {
            if (Session["CustomerID"] == null)
            {
                ddlOverall.Enabled = false;
                ddlTaste.Enabled = false;
                ddlAffordability.Enabled = false;
                txtComment.Enabled = false;

                btnSubmitReview.Attributes["onclick"] = "return confirmLogin();";
            }
            else
            {
                btnSubmitReview.Attributes.Remove("onclick");
            }
        }

        private void LoadRestaurantDetails()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT Name, ChefName, Phone, Address,
                           Description, OpeningHours, Logo, Rating
                    FROM Restaurants
                    WHERE RestaurantID = @RestaurantID";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    lblRestaurantName.Text = reader["Name"].ToString();
                    lblChefName.Text = reader["ChefName"].ToString();
                    lblPhone.Text = reader["Phone"].ToString();
                    lblAddress.Text = reader["Address"].ToString();
                    lblDescription.Text = reader["Description"].ToString();
                    lblOpeningHours.Text = reader["OpeningHours"].ToString();
                    lblAverageRating.Text = Convert.ToDecimal(reader["Rating"]).ToString("0.0");

                    if (reader["Logo"] != DBNull.Value)
                    {
                        byte[] logoBytes = (byte[])reader["Logo"];
                        imgLogo.ImageUrl =
                            "data:image/png;base64," + Convert.ToBase64String(logoBytes);
                    }
                }
            }
        }

        private void LoadReviews()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = @"
                    SELECT
                        r.Rating,
                        r.TasteRating,
                        r.AffordabilityRating,
                        r.Comment,
                        r.CreatedAt,
                        c.Name AS CustomerName,
                        r.Reply
                    FROM Reviews r
                    INNER JOIN Customers c ON r.CustomerID = c.CustomerID
                    WHERE r.RestaurantID = @RestaurantID
                      AND r.IsActive = 1
                    ORDER BY r.CreatedAt DESC";

                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                da.SelectCommand.Parameters.AddWithValue("@RestaurantID", RestaurantID);

                DataTable dt = new DataTable();
                da.Fill(dt);

                rptReviews.DataSource = dt;
                rptReviews.DataBind();
            }
        }

        protected void btnSubmitReview_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null)
            {
                lblMessage.Text = "Please log in to submit a review.";
                return;
            }

            int customerId = Convert.ToInt32(Session["CustomerID"]);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Prevent duplicate review for same order
                SqlCommand checkCmd = new SqlCommand(@"
                    SELECT COUNT(*)
                    FROM Reviews
                    WHERE OrderID = @OrderID", conn);

                checkCmd.Parameters.AddWithValue("@OrderID", OrderID);

                if ((int)checkCmd.ExecuteScalar() > 0)
                {
                    lblMessage.Text = "You have already reviewed this order.";
                    return;
                }

                SqlCommand insertCmd = new SqlCommand(@"
                    INSERT INTO Reviews
                        (OrderID, RestaurantID, CustomerID,
                         Rating, TasteRating, AffordabilityRating, Comment)
                    VALUES
                        (@OrderID, @RestaurantID, @CustomerID,
                         @Rating, @Taste, @Affordability, @Comment)", conn);

                insertCmd.Parameters.AddWithValue("@OrderID", OrderID);
                insertCmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                insertCmd.Parameters.AddWithValue("@CustomerID", customerId);
                insertCmd.Parameters.AddWithValue("@Rating", ddlOverall.SelectedValue);
                insertCmd.Parameters.AddWithValue("@Taste", ddlTaste.SelectedValue);
                insertCmd.Parameters.AddWithValue("@Affordability", ddlAffordability.SelectedValue);
                insertCmd.Parameters.AddWithValue("@Comment", txtComment.Text.Trim());

                // DEBUG: verify restaurant exists
                SqlCommand debugCmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Restaurants WHERE RestaurantID = @RID",
                    conn);

                debugCmd.Parameters.AddWithValue("@RID", RestaurantID);

                int exists = (int)debugCmd.ExecuteScalar();

                if (exists == 0)
                {
                    throw new Exception("DEBUG: RestaurantID " + RestaurantID + " does not exist");
                }

                insertCmd.ExecuteNonQuery();

                // Update restaurant rating
                SqlCommand updateCmd = new SqlCommand(@"
                    UPDATE Restaurants
                    SET Rating = (
                        SELECT AVG(CAST(Rating AS decimal(3,2)))
                        FROM Reviews
                        WHERE RestaurantID = @RestaurantID
                    ),
                    TotalReviews = (
                        SELECT COUNT(*)
                        FROM Reviews
                        WHERE RestaurantID = @RestaurantID
                    )
                    WHERE RestaurantID = @RestaurantID", conn);

                updateCmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                updateCmd.ExecuteNonQuery();
            }

            lblMessage.Text = "✅ Review submitted successfully!";
            txtComment.Text = "";

            LoadRestaurantDetails();
            LoadReviews();
        }
    }
}
