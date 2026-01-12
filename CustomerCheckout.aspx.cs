// Author: Henry
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class CustomerCheckout : Page
    {
        private int CustomerID
        {
            get { return Session["CustomerID"] != null ? Convert.ToInt32(Session["CustomerID"]) : 0; }
        }

        private const decimal DELIVERY_FEE = 5.00m;
        private const decimal PLATFORM_FEE_PERCENTAGE = 10.00m;

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
                LoadCart();
            }
        }

        private void LoadCart()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT
                        c.CartID,
                        c.Quantity,
                        m.MenuItemID,
                        m.Name AS MenuItemName,
                        m.Price,
                        r.Name AS RestaurantName,
                        (c.Quantity * m.Price) AS Subtotal,
                        ISNULL(m.ImagePath, 'content/default-avatar.png') AS ImageUrl
                    FROM dbo.Cart c
                    INNER JOIN dbo.MenuItems m ON c.MenuItemID = m.MenuItemID
                    INNER JOIN dbo.Restaurants r ON m.RestaurantID = r.RestaurantID
                    WHERE c.CustomerID = @CustomerID
                    ORDER BY r.Name, m.Name", conn))
                {
                    cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = CustomerID;

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptCart.DataSource = dt;
                            rptCart.DataBind();
                            pnlCartItems.Visible = true;
                            pnlEmptyCart.Visible = false;
                            pnlPayment.Visible = true;

                            CalculateTotals(dt);
                        }
                        else
                        {
                            pnlCartItems.Visible = false;
                            pnlEmptyCart.Visible = true;
                            pnlPayment.Visible = false;
                        }
                    }
                }
            }
        }

        private void CalculateTotals(DataTable cartData)
        {
            decimal subtotal = 0;

            foreach (DataRow row in cartData.Rows)
            {
                subtotal += Convert.ToDecimal(row["Subtotal"]);
            }

            lblSubtotal.Text = subtotal.ToString("F2");
            lblDeliveryFee.Text = DELIVERY_FEE.ToString("F2");
            lblTotal.Text = (subtotal + DELIVERY_FEE).ToString("F2");
        }

        protected void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int cartID = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "IncreaseQty")
            {
                UpdateQuantity(cartID, 1);
            }
            else if (e.CommandName == "DecreaseQty")
            {
                UpdateQuantity(cartID, -1);
            }
            else if (e.CommandName == "Remove")
            {
                RemoveFromCart(cartID);
            }

            LoadCart();
        }

        private void UpdateQuantity(int cartID, int change)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Get current quantity
                using (SqlCommand cmdGet = new SqlCommand("SELECT Quantity FROM dbo.Cart WHERE CartID = @CartID", conn))
                {
                    cmdGet.Parameters.Add("@CartID", SqlDbType.Int).Value = cartID;
                    int currentQty = Convert.ToInt32(cmdGet.ExecuteScalar());

                    int newQty = currentQty + change;

                    if (newQty <= 0)
                    {
                        RemoveFromCart(cartID);
                    }
                    else
                    {
                        using (SqlCommand cmdUpdate = new SqlCommand(@"
                            UPDATE dbo.Cart
                            SET Quantity = @Quantity
                            WHERE CartID = @CartID", conn))
                        {
                            cmdUpdate.Parameters.Add("@Quantity", SqlDbType.Int).Value = newQty;
                            cmdUpdate.Parameters.Add("@CartID", SqlDbType.Int).Value = cartID;
                            cmdUpdate.ExecuteNonQuery();
                        }
                    }
                }
            }
        }

        private void RemoveFromCart(int cartID)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.Cart WHERE CartID = @CartID", conn))
                {
                    cmd.Parameters.Add("@CartID", SqlDbType.Int).Value = cartID;
                    cmd.ExecuteNonQuery();
                }
            }
        }

        protected void btnPlaceOrder_Click(object sender, EventArgs e)
        {
            int lastOrderID = 0;

            if (string.IsNullOrWhiteSpace(txtDeliveryAddress.Text))
            {
                ShowAlert("❌ Please enter a delivery address!");
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        DataTable cartData = GetCartData(conn, tx);

                        if (cartData.Rows.Count == 0)
                        {
                            tx.Rollback();
                            ShowAlert("❌ Your cart is empty!");
                            return;
                        }

                        var restaurantGroups = cartData.AsEnumerable()
                            .GroupBy(row => row.Field<int>("RestaurantID"));

                        foreach (var restaurantGroup in restaurantGroups)
                        {
                            int restaurantID = restaurantGroup.Key;
                            decimal orderTotal = restaurantGroup.Sum(row => row.Field<decimal>("Subtotal"));
                            decimal finalAmount = orderTotal + DELIVERY_FEE;

                            int orderID = CreateOrder(conn, tx, restaurantID, finalAmount);
                            lastOrderID = orderID;

                            foreach (DataRow item in restaurantGroup)
                            {
                                CreateOrderItem(conn, tx, orderID, item);
                            }

                            CreatePayment(conn, tx, orderID, finalAmount);
                            CreatePlatformFee(conn, tx, restaurantID, orderID, orderTotal);
                        }

                        ClearCart(conn, tx);
                        UpdateCustomerStats(conn, tx);

                        // ✅ COMMIT ONCE
                        tx.Commit();

                        // ✅ Redirect SAFELY
                        Response.Redirect($"ReviewPrompt.aspx?orderId={lastOrderID}", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                    catch (Exception ex)
                    {
                        try { tx.Rollback(); } catch { }
                        ShowAlert($"❌ Error placing order: {ex.Message}");
                    }
                }
            }
        }


        private DataTable GetCartData(SqlConnection conn, SqlTransaction tx)
        {
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT
                    c.CartID,
                    c.Quantity,
                    m.MenuItemID,
                    m.Name AS MenuItemName,
                    m.Price,
                    m.RestaurantID,
                    (c.Quantity * m.Price) AS Subtotal
                FROM dbo.Cart c
                INNER JOIN dbo.MenuItems m ON c.MenuItemID = m.MenuItemID
                WHERE c.CustomerID = @CustomerID", conn, tx))
            {
                cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = CustomerID;

                using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
            }
        }

        private int CreateOrder(SqlConnection conn, SqlTransaction tx, int restaurantID, decimal finalAmount)
        {
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO dbo.Orders (CustomerID, RestaurantID, OrderDate, FinalAmount, Status)
                OUTPUT INSERTED.OrderID
                VALUES (@CustomerID, @RestaurantID, GETDATE(), @FinalAmount, N'Pending')", conn, tx))
            {
                cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = CustomerID;
                cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = restaurantID;
                cmd.Parameters.Add("@FinalAmount", SqlDbType.Decimal).Value = finalAmount;

                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private void CreateOrderItem(SqlConnection conn, SqlTransaction tx, int orderID, DataRow item)
        {
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO dbo.OrderItems (OrderID, MenuItemID, Quantity, UnitPrice, Subtotal)
                VALUES (@OrderID, @MenuItemID, @Quantity, @UnitPrice, @Subtotal)", conn, tx))
            {
                cmd.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                cmd.Parameters.Add("@MenuItemID", SqlDbType.Int).Value = item["MenuItemID"];
                cmd.Parameters.Add("@Quantity", SqlDbType.Int).Value = item["Quantity"];
                cmd.Parameters.Add("@UnitPrice", SqlDbType.Decimal).Value = item["Price"];
                cmd.Parameters.Add("@Subtotal", SqlDbType.Decimal).Value = item["Subtotal"];
                cmd.ExecuteNonQuery();
            }
        }

        private void CreatePayment(SqlConnection conn, SqlTransaction tx, int orderID, decimal amount)
        {
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO dbo.Payments (OrderID, CustomerID, Amount, PaymentMethod, PaymentStatus, TransactionID)
                VALUES (@OrderID, @CustomerID, @Amount, @PaymentMethod, N'Completed', @TransactionID)", conn, tx))
            {
                cmd.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = CustomerID;
                cmd.Parameters.Add("@Amount", SqlDbType.Decimal).Value = amount;
                cmd.Parameters.Add("@PaymentMethod", SqlDbType.NVarChar, 50).Value = ddlPaymentMethod.SelectedValue;
                cmd.Parameters.Add("@TransactionID", SqlDbType.NVarChar, 100).Value = "TXN" + DateTime.Now.Ticks;
                cmd.ExecuteNonQuery();
            }
        }

        private void CreatePlatformFee(SqlConnection conn, SqlTransaction tx, int restaurantID, int orderID, decimal orderTotal)
        {
            decimal feeAmount = orderTotal * (PLATFORM_FEE_PERCENTAGE / 100);
            DateTime dueDate = DateTime.Now.AddDays(30); // 30 days to pay

            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO dbo.PlatformFees (RestaurantID, OrderID, FeeAmount, FeePercentage, FeeStatus, DueDate)
                VALUES (@RestaurantID, @OrderID, @FeeAmount, @FeePercentage, N'Pending', @DueDate)", conn, tx))
            {
                cmd.Parameters.Add("@RestaurantID", SqlDbType.Int).Value = restaurantID;
                cmd.Parameters.Add("@OrderID", SqlDbType.Int).Value = orderID;
                cmd.Parameters.Add("@FeeAmount", SqlDbType.Decimal).Value = feeAmount;
                cmd.Parameters.Add("@FeePercentage", SqlDbType.Decimal).Value = PLATFORM_FEE_PERCENTAGE;
                cmd.Parameters.Add("@DueDate", SqlDbType.DateTime).Value = dueDate;
                cmd.ExecuteNonQuery();
            }
        }

        private void ClearCart(SqlConnection conn, SqlTransaction tx)
        {
            using (SqlCommand cmd = new SqlCommand("DELETE FROM dbo.Cart WHERE CustomerID = @CustomerID", conn, tx))
            {
                cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = CustomerID;
                cmd.ExecuteNonQuery();
            }
        }

        private void UpdateCustomerStats(SqlConnection conn, SqlTransaction tx)
        {
            using (SqlCommand cmd = new SqlCommand(@"
                UPDATE dbo.Customers
                SET TotalOrders = TotalOrders + 1
                WHERE CustomerID = @CustomerID", conn, tx))
            {
                cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = CustomerID;
                cmd.ExecuteNonQuery();
            }
        }

        private void ShowAlert(string message)
        {
            string script = $"alert('{message.Replace("'", "\\'")}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", script, true);
        }
    }
}
