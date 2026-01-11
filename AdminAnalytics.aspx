<%@ Page Title="Analytics" Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="AdminAnalytics.aspx.cs" Inherits="CulinaryPursuit.AdminAnalytics" %>
<%-- Author: Henry --%>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        .dashboard-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            padding: 40px 30px;
            border-radius: 15px;
            color: white;
            margin-bottom: 25px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }

        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 10px;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 900;
            color: #333;
            margin: 10px 0;
        }

        .stat-label {
            color: #666;
            font-size: 0.95rem;
            font-weight: 600;
        }

        .stat-change {
            font-size: 0.85rem;
            margin-top: 8px;
        }

        .stat-change.positive {
            color: #28a745;
        }

        .stat-change.negative {
            color: #dc3545;
        }

        .chart-section {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }

        .section-title {
            font-size: 1.3rem;
            font-weight: 700;
            margin-bottom: 20px;
            color: #333;
        }

        .table-section {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }

        .performance-table {
            width: 100%;
        }

        .performance-table thead {
            background: #f8f9fa;
        }

        .performance-table th {
            padding: 12px;
            font-weight: 700;
            color: #333;
            border-bottom: 2px solid #dee2e6;
        }

        .performance-table td {
            padding: 12px;
            border-bottom: 1px solid #f0f0f0;
        }

        .performance-table tr:hover {
            background: #f8f9fa;
        }

        .rank-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            font-weight: 700;
            color: white;
        }

        .rank-1 { background: linear-gradient(135deg, #FFD700, #FFA500); }
        .rank-2 { background: linear-gradient(135deg, #C0C0C0, #A9A9A9); }
        .rank-3 { background: linear-gradient(135deg, #CD7F32, #8B4513); }
        .rank-other { background: #6c757d; }

        .progress-bar-custom {
            height: 8px;
            border-radius: 10px;
            background: #e9ecef;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea, #764ba2);
            transition: width 0.3s ease;
        }

        .date-filter {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <div class="dashboard-header">
        <h1 style="font-weight:800;">📊 Analytics Dashboard</h1>
        <p style="opacity:0.8;">Comprehensive platform performance and insights</p>
    </div>

            <!-- Date Filter -->
            <div class="date-filter">
                <div class="row align-items-end">
                    <div class="col-md-3">
                        <label><strong>Start Date</strong></label>
                        <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>
                    <div class="col-md-3">
                        <label><strong>End Date</strong></label>
                        <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>
                    <div class="col-md-3">
                        <asp:Button ID="btnApplyDateFilter" runat="server" Text="Apply Filter" CssClass="btn btn-primary w-100" OnClick="btnApplyDateFilter_Click" />
                    </div>
                    <div class="col-md-3">
                        <asp:Button ID="btnResetFilter" runat="server" Text="Reset to This Month" CssClass="btn btn-secondary w-100" OnClick="btnResetFilter_Click" />
                    </div>
                </div>
            </div>

            <!-- Key Metrics -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">💰</div>
                    <div class="stat-value">$<asp:Label ID="lblTotalRevenue" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Total Revenue</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">📦</div>
                    <div class="stat-value"><asp:Label ID="lblTotalOrders" runat="server" Text="0" /></div>
                    <div class="stat-label">Total Orders</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">👥</div>
                    <div class="stat-value"><asp:Label ID="lblTotalCustomers" runat="server" Text="0" /></div>
                    <div class="stat-label">Total Customers</div>
                    <div class="stat-change positive">+<asp:Label ID="lblNewCustomers" runat="server" Text="0" /> new today</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">🏪</div>
                    <div class="stat-value"><asp:Label ID="lblActiveRestaurants" runat="server" Text="0" /></div>
                    <div class="stat-label">Active Restaurants</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">💸</div>
                    <div class="stat-value">$<asp:Label ID="lblTotalExpenses" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Total Expenses</div>
                    <small class="text-muted">Platform fees waived</small>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">📈</div>
                    <div class="stat-value">$<asp:Label ID="lblNetProfit" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Net Profit</div>
                    <div class="stat-change positive"><asp:Label ID="lblProfitMargin" runat="server" Text="0" />% margin</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">📊</div>
                    <div class="stat-value">$<asp:Label ID="lblAvgOrderValue" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Avg Order Value</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">⏱️</div>
                    <div class="stat-value"><asp:Label ID="lblDailyCustomers" runat="server" Text="0" /></div>
                    <div class="stat-label">Customers Today</div>
                </div>
            </div>

            <!-- Revenue Trend Chart -->
            <div class="chart-section">
                <h3 class="section-title">📈 Revenue Trend (Last 30 Days)</h3>
                <canvas id="revenueTrendChart" height="80"></canvas>
            </div>

            <!-- Top Performers -->
            <div class="table-section">
                <h3 class="section-title">🏆 Top Performing Restaurants</h3>
                <table class="performance-table">
                    <thead>
                        <tr>
                            <th>Rank</th>
                            <th>Restaurant</th>
                            <th>Cuisine</th>
                            <th>Total Orders</th>
                            <th>Total Revenue</th>
                            <th>Avg Rating</th>
                            <th>Performance</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptTopRestaurants" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <span class='rank-badge rank-<%# GetRankClass((int)Container.ItemIndex + 1) %>'>
                                            <%# Container.ItemIndex + 1 %>
                                        </span>
                                    </td>
                                    <td><strong><%# Eval("RestaurantName") %></strong></td>
                                    <td><%# Eval("CuisineType") %></td>
                                    <td><%# Eval("TotalOrders") %></td>
                                    <td><strong>$<%# Eval("TotalRevenue", "{0:F2}") %></strong></td>
                                    <td>⭐ <%# Eval("AvgRating", "{0:F1}") %></td>
                                    <td>
                                        <div class="progress-bar-custom">
                                            <div class="progress-fill" style='width: <%# GetPerformancePercent(Eval("TotalRevenue")) %>%'></div>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <!-- Cuisine Performance -->
            <div class="row">
                <div class="col-md-6">
                    <div class="table-section">
                        <h3 class="section-title">🍜 Most Popular Cuisines</h3>
                        <table class="performance-table">
                            <thead>
                                <tr>
                                    <th>Cuisine</th>
                                    <th>Orders</th>
                                    <th>Revenue</th>
                                    <th>Avg Price</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptCuisinePerformance" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td><strong><%# Eval("CuisineType") %></strong></td>
                                            <td><%# Eval("TotalOrders") %></td>
                                            <td><strong>$<%# Eval("TotalRevenue", "{0:F2}") %></strong></td>
                                            <td>$<%# Eval("AvgPrice", "{0:F2}") %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="table-section">
                        <h3 class="section-title">📊 Sales by Category</h3>
                        <table class="performance-table">
                            <thead>
                                <tr>
                                    <th>Category</th>
                                    <th>Items Sold</th>
                                    <th>Revenue</th>
                                    <th>% of Total</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptSalesByCategory" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td><strong><%# Eval("Category") %></strong></td>
                                            <td><%# Eval("TotalSold") %></td>
                                            <td><strong>$<%# Eval("TotalRevenue", "{0:F2}") %></strong></td>
                                            <td><%# Eval("Percentage", "{0:F1}") %>%</td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    <script>
        // Revenue Trend Chart
        <asp:Literal ID="litChartData" runat="server" />
    </script>
</asp:Content>
