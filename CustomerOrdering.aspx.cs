// Author: Henry
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class CustomerOrdering : Page
    {
        private int CustomerID
        {
            get { return Session["CustomerID"] != null ? Convert.ToInt32(Session["CustomerID"]) : 0; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check authentication
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadFilters();
                LoadMenuItems();
                UpdateCartCount();
            }
        }

        private void LoadFilters()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Load restaurants
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT RestaurantID, Name
                    FROM dbo.Restaurants
                    WHERE ApprovalStatus = N'Approved' AND IsActive = 1
                    ORDER BY Name", conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    ddlRestaurant.DataSource = reader;
                    ddlRestaurant.DataTextField = "Name";
                    ddlRestaurant.DataValueField = "RestaurantID";
                    ddlRestaurant.DataBind();
                    ddlRestaurant.Items.Insert(0, new ListItem("All Restaurants", ""));
                }

                // Load cuisine types
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT DISTINCT CuisineType
                    FROM dbo.Restaurants
                    WHERE ApprovalStatus = N'Approved' AND IsActive = 1
                    ORDER BY CuisineType", conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ddlCuisine.Items.Add(new ListItem(reader["CuisineType"].ToString()));
                    }
                    ddlCuisine.Items.Insert(0, new ListItem("All Cuisines", ""));
                }
            }
        }

        private void LoadMenuItems()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = @"
                    SELECT
                        m.MenuItemID,
                        m.Name,
                        m.Description,
                        m.Price,
                        m.Category,
                        m.IsAvailable,
                        r.Name AS RestaurantName,
                        r.RestaurantID,
                        r.CuisineType,
                        ISNULL(m.ImagePath, 'content/default-avatar.png') AS ImageUrl
                    FROM dbo.MenuItems m
                    INNER JOIN dbo.Restaurants r ON m.RestaurantID = r.RestaurantID
                    WHERE r.ApprovalStatus = N'Approved'
                        AND r.IsActive = 1
                        AND m.IsAvailable = 1";

                // Apply filters
                if (!string.IsNullOrWhiteSpace(txtSearch.Text))
                {
                    query += " AND (m.Name LIKE @Search OR m.Description LIKE @Search)";
                }

                if (!string.IsNullOrWhiteSpace(ddlRestaurant.SelectedValue))
                {
                    query += " AND r.RestaurantID = @RestaurantID";
                }

                if (!string.IsNullOrWhiteSpace(ddlCuisine.SelectedValue))
                {
                    query += " AND r.CuisineType = @CuisineType";
                }

                query += " ORDER BY r.Name, m.Name";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrWhiteSpace(txtSearch.Text))
                    {
                        cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 500).Value = "%" + txtSearch.Text.Trim() + "%";
                    }

                    if (!string.IsNullOrWhiteSpace(ddlRestaurant.SelectedValue))
                    {
                        cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = Convert.ToInt32(ddlRestaurant.SelectedValue);
                    }

                    if (!string.IsNullOrWhiteSpace(ddlCuisine.SelectedValue))
                    {
                        cmd.Parameters.Add("@CuisineType", SqlDbType.NVarChar, 100).Value = ddlCuisine.SelectedValue;
                    }

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptMenuItems.DataSource = dt;
                            rptMenuItems.DataBind();
                            pnlNoResults.Visible = false;
                        }
                        else
                        {
                            rptMenuItems.DataSource = null;
                            rptMenuItems.DataBind();
                            pnlNoResults.Visible = true;
                        }
                    }
                }
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LoadMenuItems();
        }

        protected void rptMenuItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "AddToCart")
            {
                int menuItemID = Convert.ToInt32(e.CommandArgument);
                AddToCart(menuItemID);
            }
        }

        private void AddToCart(int menuItemID)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Check if item already in cart
                using (SqlCommand cmdCheck = new SqlCommand(@"
                    SELECT CartID, Quantity
                    FROM dbo.Cart
                    WHERE CustomerID = @CustomerID AND MenuItemID = @MenuItemID", conn))
                {
                    cmdCheck.Parameters.Add("@CustomerID", SqlDbType.Int).Value = CustomerID;
                    cmdCheck.Parameters.Add("@MenuItemID", SqlDbType.Int).Value = menuItemID;

                    using (SqlDataReader reader = cmdCheck.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Item exists, update quantity
                            int cartID = Convert.ToInt32(reader["CartID"]);
                            int quantity = Convert.ToInt32(reader["Quantity"]);
                            reader.Close();

                            using (SqlCommand cmdUpdate = new SqlCommand(@"
                                UPDATE dbo.Cart
                                SET Quantity = @Quantity
                                WHERE CartID = @CartID", conn))
                            {
                                cmdUpdate.Parameters.Add("@Quantity", SqlDbType.Int).Value = quantity + 1;
                                cmdUpdate.Parameters.Add("@CartID", SqlDbType.Int).Value = cartID;
                                cmdUpdate.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            reader.Close();

                            // New item, insert
                            using (SqlCommand cmdInsert = new SqlCommand(@"
                                INSERT INTO dbo.Cart (CustomerID, MenuItemID, Quantity)
                                VALUES (@CustomerID, @MenuItemID, 1)", conn))
                            {
                                cmdInsert.Parameters.Add("@CustomerID", SqlDbType.Int).Value = CustomerID;
                                cmdInsert.Parameters.Add("@MenuItemID", SqlDbType.Int).Value = menuItemID;
                                cmdInsert.ExecuteNonQuery();
                            }
                        }
                    }
                }
            }

            UpdateCartCount();
            ShowAlert("✅ Item added to cart!");
        }

        private void UpdateCartCount()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(Quantity), 0)
                    FROM dbo.Cart
                    WHERE CustomerID = @CustomerID", conn))
                {
                    cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = CustomerID;

                    object result = cmd.ExecuteScalar();
                    lblCartCount.Text = result != null ? result.ToString() : "0";
                }
            }
        }

        private void ShowAlert(string message)
        {
            string script = $"alert('{message.Replace("'", "\\'")}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", script, true);
        }
    }
}
