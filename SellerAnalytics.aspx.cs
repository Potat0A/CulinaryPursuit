// Author: Henry
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class SellerAnalytics : Page
    {
        private int RestaurantID
        {
            get { return Session["RestaurantID"] != null ? Convert.ToInt32(Session["RestaurantID"]) : 0; }
        }

        private DateTime StartDate { get; set; }
        private DateTime EndDate { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check authentication
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Restaurant")
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                // Default to current month
                StartDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
                EndDate = DateTime.Now;

                txtStartDate.Text = StartDate.ToString("yyyy-MM-dd");
                txtEndDate.Text = EndDate.ToString("yyyy-MM-dd");

                LoadAllAnalytics();
            }
        }

        protected void btnApplyFilter_Click(object sender, EventArgs e)
        {
            LoadAllAnalytics();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            StartDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            EndDate = DateTime.Now;

            txtStartDate.Text = StartDate.ToString("yyyy-MM-dd");
            txtEndDate.Text = EndDate.ToString("yyyy-MM-dd");

            LoadAllAnalytics();
        }

        private void LoadAllAnalytics()
        {
            if (!string.IsNullOrEmpty(txtStartDate.Text))
                StartDate = DateTime.Parse(txtStartDate.Text);
            else
                StartDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);

            if (!string.IsNullOrEmpty(txtEndDate.Text))
                EndDate = DateTime.Parse(txtEndDate.Text);
            else
                EndDate = DateTime.Now;

            LoadKeyMetrics();
            LoadTopSellingItems();
            LoadSalesByCategory();
            LoadRecentOrders();
            GenerateRevenueTrendChart();
        }

        private void LoadKeyMetrics()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Total Revenue
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(FinalAmount), 0)
                    FROM dbo.Orders
                    WHERE RestaurantID = @RestaurantID
                        AND OrderDate >= @StartDate
                        AND OrderDate <= @EndDate", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);
                    decimal revenue = Convert.ToDecimal(cmd.ExecuteScalar());
                    lblTotalRevenue.Text = revenue.ToString("F2");
                }

                // Total Orders
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*)
                    FROM dbo.Orders
                    WHERE RestaurantID = @RestaurantID
                        AND OrderDate >= @StartDate
                        AND OrderDate <= @EndDate", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);
                    int orders = Convert.ToInt32(cmd.ExecuteScalar());
                    lblTotalOrders.Text = orders.ToString();

                    // Calculate daily average
                    int days = (EndDate - StartDate).Days + 1;
                    lblDailyAverage.Text = (orders / days).ToString();
                }

                // Unique Customers
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(DISTINCT CustomerID)
                    FROM dbo.Orders
                    WHERE RestaurantID = @RestaurantID
                        AND OrderDate >= @StartDate
                        AND OrderDate <= @EndDate", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);
                    lblUniqueCustomers.Text = cmd.ExecuteScalar().ToString();
                }

                // Average Rating & Reviews
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT Rating, TotalReviews
                    FROM dbo.Restaurants
                    WHERE RestaurantID = @RestaurantID", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblAvgRating.Text = reader["Rating"] != DBNull.Value
                                ? Convert.ToDecimal(reader["Rating"]).ToString("F1")
                                : "0.0";
                            lblTotalReviews.Text = reader["TotalReviews"].ToString();
                        }
                    }
                }

                // Average Order Value
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(AVG(FinalAmount), 0)
                    FROM dbo.Orders
                    WHERE RestaurantID = @RestaurantID
                        AND OrderDate >= @StartDate
                        AND OrderDate <= @EndDate", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);
                    lblAvgOrderValue.Text = Convert.ToDecimal(cmd.ExecuteScalar()).ToString("F2");
                }

                // Platform Fees (Total)
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(FeeAmount), 0)
                    FROM dbo.PlatformFees
                    WHERE RestaurantID = @RestaurantID
                        AND CreatedDate >= @StartDate
                        AND CreatedDate <= @EndDate", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);
                    decimal fees = Convert.ToDecimal(cmd.ExecuteScalar());
                    lblPlatformFees.Text = fees.ToString("F2");

                    // Net Earnings
                    decimal revenue = Convert.ToDecimal(lblTotalRevenue.Text);
                    lblNetEarnings.Text = (revenue - fees).ToString("F2");
                }

                // Pending Platform Fees
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(FeeAmount), 0)
                    FROM dbo.PlatformFees
                    WHERE RestaurantID = @RestaurantID
                        AND FeeStatus IN (N'Pending', N'Overdue')", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    lblPendingFees.Text = Convert.ToDecimal(cmd.ExecuteScalar()).ToString("F2");
                }

                // Revenue Growth (compare to previous period)
                TimeSpan period = EndDate - StartDate;
                DateTime prevStart = StartDate.AddDays(-period.Days);
                DateTime prevEnd = StartDate.AddDays(-1);

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(FinalAmount), 0)
                    FROM dbo.Orders
                    WHERE RestaurantID = @RestaurantID
                        AND OrderDate >= @PrevStart
                        AND OrderDate <= @PrevEnd", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    cmd.Parameters.AddWithValue("@PrevStart", prevStart);
                    cmd.Parameters.AddWithValue("@PrevEnd", prevEnd);

                    decimal prevRevenue = Convert.ToDecimal(cmd.ExecuteScalar());
                    decimal currentRevenue = Convert.ToDecimal(lblTotalRevenue.Text);

                    if (prevRevenue > 0)
                    {
                        decimal growth = ((currentRevenue - prevRevenue) / prevRevenue) * 100;
                        lblRevenueGrowth.Text = Math.Abs(growth).ToString("F1");
                    }
                    else
                    {
                        lblRevenueGrowth.Text = "0";
                    }
                }

                // Order Growth
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*)
                    FROM dbo.Orders
                    WHERE RestaurantID = @RestaurantID
                        AND OrderDate >= @PrevStart
                        AND OrderDate <= @PrevEnd", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    cmd.Parameters.AddWithValue("@PrevStart", prevStart);
                    cmd.Parameters.AddWithValue("@PrevEnd", prevEnd);

                    int prevOrders = Convert.ToInt32(cmd.ExecuteScalar());
                    int currentOrders = Convert.ToInt32(lblTotalOrders.Text);

                    if (prevOrders > 0)
                    {
                        decimal growth = ((decimal)(currentOrders - prevOrders) / prevOrders) * 100;
                        lblOrderGrowth.Text = Math.Abs(growth).ToString("F1");
                    }
                    else
                    {
                        lblOrderGrowth.Text = "0";
                    }
                }

                // Retention Rate (customers who ordered more than once)
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT
                        COUNT(DISTINCT CustomerID) AS TotalCustomers,
                        SUM(CASE WHEN OrderCount > 1 THEN 1 ELSE 0 END) AS ReturningCustomers
                    FROM (
                        SELECT CustomerID, COUNT(*) AS OrderCount
                        FROM dbo.Orders
                        WHERE RestaurantID = @RestaurantID
                        GROUP BY CustomerID
                    ) AS CustomerOrders", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int total = Convert.ToInt32(reader["TotalCustomers"]);
                            int returning = reader["ReturningCustomers"] != DBNull.Value
                                ? Convert.ToInt32(reader["ReturningCustomers"])
                                : 0;

                            if (total > 0)
                            {
                                decimal retention = ((decimal)returning / total) * 100;
                                lblRetentionRate.Text = retention.ToString("F1");
                            }
                            else
                            {
                                lblRetentionRate.Text = "0";
                            }
                        }
                    }
                }
            }
        }

        private void LoadTopSellingItems()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 10
                        m.Name AS ItemName,
                        ISNULL(m.Category, N'Uncategorized') AS Category,
                        SUM(oi.Quantity) AS TotalSold,
                        ISNULL(SUM(oi.Subtotal), 0) AS TotalRevenue
                    FROM dbo.MenuItems m
                    LEFT JOIN dbo.OrderItems oi ON m.MenuItemID = oi.MenuItemID
                    LEFT JOIN dbo.Orders o ON oi.OrderID = o.OrderID
                        AND o.OrderDate >= @StartDate
                        AND o.OrderDate <= @EndDate
                    WHERE m.RestaurantID = @RestaurantID
                    GROUP BY m.MenuItemID, m.Name, m.Category
                    HAVING SUM(oi.Quantity) > 0
                    ORDER BY TotalRevenue DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        rptTopItems.DataSource = dt;
                        rptTopItems.DataBind();
                    }
                }
            }
        }

        private void LoadSalesByCategory()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT
                        ISNULL(m.Category, N'Uncategorized') AS Category,
                        SUM(oi.Quantity) AS TotalSold,
                        ISNULL(SUM(oi.Subtotal), 0) AS TotalRevenue
                    FROM dbo.MenuItems m
                    LEFT JOIN dbo.OrderItems oi ON m.MenuItemID = oi.MenuItemID
                    LEFT JOIN dbo.Orders o ON oi.OrderID = o.OrderID
                        AND o.OrderDate >= @StartDate
                        AND o.OrderDate <= @EndDate
                    WHERE m.RestaurantID = @RestaurantID
                    GROUP BY m.Category
                    HAVING SUM(oi.Quantity) > 0
                    ORDER BY TotalRevenue DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        rptCategories.DataSource = dt;
                        rptCategories.DataBind();
                    }
                }
            }
        }

        private void LoadRecentOrders()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 15
                        o.OrderID,
                        c.Name AS CustomerName,
                        o.OrderDate,
                        o.FinalAmount,
                        o.Status,
                        (SELECT COUNT(*) FROM dbo.OrderItems WHERE OrderID = o.OrderID) AS ItemCount
                    FROM dbo.Orders o
                    INNER JOIN dbo.Customers c ON o.CustomerID = c.CustomerID
                    WHERE o.RestaurantID = @RestaurantID
                    ORDER BY o.OrderDate DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        rptRecentOrders.DataSource = dt;
                        rptRecentOrders.DataBind();
                    }
                }
            }
        }

        private void GenerateRevenueTrendChart()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Get revenue per day for date range
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT
                        CAST(OrderDate AS DATE) AS Date,
                        ISNULL(SUM(FinalAmount), 0) AS Revenue
                    FROM dbo.Orders
                    WHERE RestaurantID = @RestaurantID
                        AND OrderDate >= @StartDate
                        AND OrderDate <= @EndDate
                    GROUP BY CAST(OrderDate AS DATE)
                    ORDER BY Date", conn))
                {
                    cmd.Parameters.AddWithValue("@RestaurantID", RestaurantID);
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        StringBuilder labels = new StringBuilder();
                        StringBuilder data = new StringBuilder();

                        while (reader.Read())
                        {
                            DateTime date = Convert.ToDateTime(reader["Date"]);
                            decimal revenue = Convert.ToDecimal(reader["Revenue"]);

                            if (labels.Length > 0)
                            {
                                labels.Append(",");
                                data.Append(",");
                            }

                            labels.Append($"'{date:MMM dd}'");
                            data.Append(revenue.ToString("F2"));
                        }

                        // Generate Chart.js code
                        string chartScript = $@"
                        const ctx = document.getElementById('revenueTrendChart').getContext('2d');
                        new Chart(ctx, {{
                            type: 'line',
                            data: {{
                                labels: [{labels}],
                                datasets: [{{
                                    label: 'Revenue ($)',
                                    data: [{data}],
                                    borderColor: '#1e88e5',
                                    backgroundColor: 'rgba(30, 136, 229, 0.1)',
                                    borderWidth: 3,
                                    fill: true,
                                    tension: 0.4
                                }}]
                            }},
                            options: {{
                                responsive: true,
                                plugins: {{
                                    legend: {{
                                        display: true,
                                        position: 'top'
                                    }}
                                }},
                                scales: {{
                                    y: {{
                                        beginAtZero: true,
                                        ticks: {{
                                            callback: function(value) {{
                                                return '$' + value;
                                            }}
                                        }}
                                    }}
                                }}
                            }}
                        }});";

                        litChartData.Text = chartScript;
                    }
                }
            }
        }

        protected string GetPerformancePercent(object revenue)
        {
            if (rptTopItems.DataSource == null) return "0";

            DataTable dt = (DataTable)rptTopItems.DataSource;
            if (dt.Rows.Count == 0) return "0";

            decimal maxRevenue = 0;
            foreach (DataRow row in dt.Rows)
            {
                decimal rev = Convert.ToDecimal(row["TotalRevenue"]);
                if (rev > maxRevenue) maxRevenue = rev;
            }

            if (maxRevenue == 0) return "0";

            decimal currentRevenue = Convert.ToDecimal(revenue);
            decimal percent = (currentRevenue / maxRevenue) * 100;

            return percent.ToString("F0");
        }
    }
}
