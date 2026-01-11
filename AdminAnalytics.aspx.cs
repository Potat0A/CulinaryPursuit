// Author: Henry
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class AdminAnalytics : Page
    {
        private DateTime StartDate { get; set; }
        private DateTime EndDate { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check admin authentication
            if (Session["AdminID"] == null)
            {
                Response.Redirect("AdminLogin.aspx", false);
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

        protected void btnApplyDateFilter_Click(object sender, EventArgs e)
        {
            LoadAllAnalytics();
        }

        protected void btnResetFilter_Click(object sender, EventArgs e)
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
            LoadTopRestaurants();
            LoadCuisinePerformance();
            LoadSalesByCategory();
            GenerateRevenueTrendChart();
        }

        private void LoadKeyMetrics()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Total Revenue (from platform fees collected)
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(FeeAmount), 0)
                    FROM dbo.PlatformFees
                    WHERE FeeStatus = N'Paid'
                        AND PaidDate >= @StartDate
                        AND PaidDate <= @EndDate", conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);
                    lblTotalRevenue.Text = Convert.ToDecimal(cmd.ExecuteScalar()).ToString("F2");
                }

                // Total Orders
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*)
                    FROM dbo.Orders
                    WHERE OrderDate >= @StartDate
                        AND OrderDate <= @EndDate", conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);
                    lblTotalOrders.Text = cmd.ExecuteScalar().ToString();
                }

                // Total Customers
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Customers", conn))
                {
                    lblTotalCustomers.Text = cmd.ExecuteScalar().ToString();
                }

                // New Customers Today
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*)
                    FROM dbo.Customers
                    WHERE CAST(CreatedDate AS DATE) = CAST(GETDATE() AS DATE)", conn))
                {
                    lblNewCustomers.Text = cmd.ExecuteScalar().ToString();
                }

                // Active Restaurants
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*)
                    FROM dbo.Restaurants
                    WHERE ApprovalStatus = N'Approved' AND IsActive = 1", conn))
                {
                    lblActiveRestaurants.Text = cmd.ExecuteScalar().ToString();
                }

                // Total Expenses (waived fees)
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(FeeAmount), 0)
                    FROM dbo.PlatformFees
                    WHERE FeeStatus = N'Waived'
                        AND CreatedDate >= @StartDate
                        AND CreatedDate <= @EndDate", conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);
                    lblTotalExpenses.Text = Convert.ToDecimal(cmd.ExecuteScalar()).ToString("F2");
                }

                // Net Profit (Revenue - Expenses)
                decimal revenue = Convert.ToDecimal(lblTotalRevenue.Text);
                decimal expenses = Convert.ToDecimal(lblTotalExpenses.Text);
                decimal netProfit = revenue - expenses;
                lblNetProfit.Text = netProfit.ToString("F2");

                // Profit Margin
                if (revenue > 0)
                {
                    decimal margin = (netProfit / revenue) * 100;
                    lblProfitMargin.Text = margin.ToString("F1");
                }
                else
                {
                    lblProfitMargin.Text = "0";
                }

                // Average Order Value
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(AVG(FinalAmount), 0)
                    FROM dbo.Orders
                    WHERE OrderDate >= @StartDate
                        AND OrderDate <= @EndDate", conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);
                    lblAvgOrderValue.Text = Convert.ToDecimal(cmd.ExecuteScalar()).ToString("F2");
                }

                // Daily Active Customers (customers who placed orders today)
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(DISTINCT CustomerID)
                    FROM dbo.Orders
                    WHERE CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)", conn))
                {
                    lblDailyCustomers.Text = cmd.ExecuteScalar().ToString();
                }
            }
        }

        private void LoadTopRestaurants()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT TOP 10
                        r.Name AS RestaurantName,
                        r.CuisineType,
                        COUNT(o.OrderID) AS TotalOrders,
                        ISNULL(SUM(o.FinalAmount), 0) AS TotalRevenue,
                        ISNULL(r.Rating, 0) AS AvgRating
                    FROM dbo.Restaurants r
                    LEFT JOIN dbo.Orders o ON r.RestaurantID = o.RestaurantID
                        AND o.OrderDate >= @StartDate
                        AND o.OrderDate <= @EndDate
                    WHERE r.ApprovalStatus = N'Approved' AND r.IsActive = 1
                    GROUP BY r.RestaurantID, r.Name, r.CuisineType, r.Rating
                    ORDER BY TotalRevenue DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        rptTopRestaurants.DataSource = dt;
                        rptTopRestaurants.DataBind();
                    }
                }
            }
        }

        private void LoadCuisinePerformance()
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT
                        r.CuisineType,
                        COUNT(o.OrderID) AS TotalOrders,
                        ISNULL(SUM(o.FinalAmount), 0) AS TotalRevenue,
                        ISNULL(AVG(o.FinalAmount), 0) AS AvgPrice
                    FROM dbo.Restaurants r
                    LEFT JOIN dbo.Orders o ON r.RestaurantID = o.RestaurantID
                        AND o.OrderDate >= @StartDate
                        AND o.OrderDate <= @EndDate
                    WHERE r.ApprovalStatus = N'Approved' AND r.IsActive = 1
                    GROUP BY r.CuisineType
                    ORDER BY TotalRevenue DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);
                        rptCuisinePerformance.DataSource = dt;
                        rptCuisinePerformance.DataBind();
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

                // First get total revenue for percentage calculation
                decimal totalRevenue = 0;
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(oi.Subtotal), 0)
                    FROM dbo.OrderItems oi
                    INNER JOIN dbo.Orders o ON oi.OrderID = o.OrderID
                    WHERE o.OrderDate >= @StartDate
                        AND o.OrderDate <= @EndDate", conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);
                    totalRevenue = Convert.ToDecimal(cmd.ExecuteScalar());
                }

                // Get sales by category
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT
                        ISNULL(m.Category, N'Uncategorized') AS Category,
                        SUM(oi.Quantity) AS TotalSold,
                        ISNULL(SUM(oi.Subtotal), 0) AS TotalRevenue
                    FROM dbo.OrderItems oi
                    INNER JOIN dbo.Orders o ON oi.OrderID = o.OrderID
                    INNER JOIN dbo.MenuItems m ON oi.MenuItemID = m.MenuItemID
                    WHERE o.OrderDate >= @StartDate
                        AND o.OrderDate <= @EndDate
                    GROUP BY m.Category
                    ORDER BY TotalRevenue DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", StartDate);
                    cmd.Parameters.AddWithValue("@EndDate", EndDate);

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        // Add Percentage column before calculating
                        dt.Columns.Add("Percentage", typeof(decimal));

                        // Calculate percentage
                        foreach (DataRow row in dt.Rows)
                        {
                            decimal categoryRevenue = Convert.ToDecimal(row["TotalRevenue"]);
                            decimal percentage = totalRevenue > 0 ? (categoryRevenue / totalRevenue) * 100 : 0;
                            row["Percentage"] = percentage;
                        }

                        rptSalesByCategory.DataSource = dt;
                        rptSalesByCategory.DataBind();
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

                // Get revenue for last 30 days
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT
                        CAST(PaidDate AS DATE) AS Date,
                        ISNULL(SUM(FeeAmount), 0) AS Revenue
                    FROM dbo.PlatformFees
                    WHERE FeeStatus = N'Paid'
                        AND PaidDate >= DATEADD(DAY, -30, GETDATE())
                    GROUP BY CAST(PaidDate AS DATE)
                    ORDER BY Date", conn))
                {
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
                                    borderColor: '#667eea',
                                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
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

        protected string GetRankClass(int rank)
        {
            if (rank == 1) return "1";
            if (rank == 2) return "2";
            if (rank == 3) return "3";
            return "other";
        }

        protected string GetPerformancePercent(object revenue)
        {
            // Calculate percentage based on max revenue in the list
            if (rptTopRestaurants.DataSource == null) return "0";

            DataTable dt = (DataTable)rptTopRestaurants.DataSource;
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
