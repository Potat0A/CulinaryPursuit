<%@ Page Title="Analytics" Language="C#" MasterPageFile="~/chef.Master" AutoEventWireup="true" CodeBehind="SellerAnalytics.aspx.cs" Inherits="CulinaryPursuit.SellerAnalytics" %>
<%-- Author: Henry --%>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
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
            color: #1e88e5;
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

        .date-filter {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
        }

        .metric-comparison {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #e9ecef;
        }

        .progress-bar-custom {
            height: 8px;
            border-radius: 10px;
            background: #e9ecef;
            overflow: hidden;
            margin-top: 8px;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #1e88e5, #1565c0);
            transition: width 0.3s ease;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <h2 class="mb-4">📊 Your Analytics</h2>

    <!-- Date Filter -->
    <div class="date-filter">
        <div class="row align-items-end">
            <div class="col-md-4">
                <label><strong>Start Date</strong></label>
                <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="form-control" />
            </div>
            <div class="col-md-4">
                <label><strong>End Date</strong></label>
                <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="form-control" />
            </div>
            <div class="col-md-2">
                <asp:Button ID="btnApplyFilter" runat="server" Text="Apply" CssClass="btn btn-primary w-100" OnClick="btnApplyFilter_Click" />
            </div>
            <div class="col-md-2">
                <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-secondary w-100" OnClick="btnReset_Click" />
            </div>
        </div>
    </div>

    <!-- Key Metrics -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon">💰</div>
            <div class="stat-value">$<asp:Label ID="lblTotalRevenue" runat="server" Text="0.00" /></div>
            <div class="stat-label">Total Revenue</div>
            <div class="stat-change positive">+<asp:Label ID="lblRevenueGrowth" runat="server" Text="0" />% vs last period</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">📦</div>
            <div class="stat-value"><asp:Label ID="lblTotalOrders" runat="server" Text="0" /></div>
            <div class="stat-label">Total Orders</div>
            <div class="stat-change positive">+<asp:Label ID="lblOrderGrowth" runat="server" Text="0" />% vs last period</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">👥</div>
            <div class="stat-value"><asp:Label ID="lblUniqueCustomers" runat="server" Text="0" /></div>
            <div class="stat-label">Unique Customers</div>
            <div class="stat-change">Retention: <asp:Label ID="lblRetentionRate" runat="server" Text="0" />%</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">⭐</div>
            <div class="stat-value"><asp:Label ID="lblAvgRating" runat="server" Text="0.0" /></div>
            <div class="stat-label">Average Rating</div>
            <div class="stat-change"><asp:Label ID="lblTotalReviews" runat="server" Text="0" /> reviews</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">📊</div>
            <div class="stat-value">$<asp:Label ID="lblAvgOrderValue" runat="server" Text="0.00" /></div>
            <div class="stat-label">Avg Order Value</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">💸</div>
            <div class="stat-value">$<asp:Label ID="lblPlatformFees" runat="server" Text="0.00" /></div>
            <div class="stat-label">Platform Fees (Total)</div>
            <div class="stat-change">$<asp:Label ID="lblPendingFees" runat="server" Text="0.00" /> pending</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">💵</div>
            <div class="stat-value">$<asp:Label ID="lblNetEarnings" runat="server" Text="0.00" /></div>
            <div class="stat-label">Net Earnings</div>
            <small class="text-muted">Revenue - Fees</small>
        </div>

        <div class="stat-card">
            <div class="stat-icon">📈</div>
            <div class="stat-value"><asp:Label ID="lblDailyAverage" runat="server" Text="0" /></div>
            <div class="stat-label">Daily Avg Orders</div>
        </div>
    </div>

    <!-- Revenue Trend Chart -->
    <div class="chart-section">
        <h3 class="section-title">📈 Revenue Trend</h3>
        <canvas id="revenueTrendChart" height="80"></canvas>
    </div>

    <!-- Top Selling Items -->
    <div class="row">
        <div class="col-lg-7">
            <div class="table-section">
                <h3 class="section-title">🏆 Top Selling Menu Items</h3>
                <table class="performance-table">
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th>Category</th>
                            <th>Sold</th>
                            <th>Revenue</th>
                            <th>Performance</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptTopItems" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><strong><%# Eval("ItemName") %></strong></td>
                                    <td><%# Eval("Category") %></td>
                                    <td><%# Eval("TotalSold") %></td>
                                    <td><strong>$<%# Eval("TotalRevenue", "{0:F2}") %></strong></td>
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
        </div>

        <div class="col-lg-5">
            <div class="table-section">
                <h3 class="section-title">📊 Sales by Category</h3>
                <table class="performance-table">
                    <thead>
                        <tr>
                            <th>Category</th>
                            <th>Items Sold</th>
                            <th>Revenue</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptCategories" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><strong><%# Eval("Category") %></strong></td>
                                    <td><%# Eval("TotalSold") %></td>
                                    <td><strong>$<%# Eval("TotalRevenue", "{0:F2}") %></strong></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Recent Orders -->
    <div class="table-section">
        <h3 class="section-title">📦 Recent Orders</h3>
        <table class="performance-table">
            <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Customer</th>
                    <th>Date</th>
                    <th>Items</th>
                    <th>Amount</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptRecentOrders" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><strong>#<%# Eval("OrderID") %></strong></td>
                            <td><%# Eval("CustomerName") %></td>
                            <td><%# Eval("OrderDate", "{0:MMM dd, yyyy HH:mm}") %></td>
                            <td><%# Eval("ItemCount") %> items</td>
                            <td><strong>$<%# Eval("FinalAmount", "{0:F2}") %></strong></td>
                            <td><span class="badge bg-info"><%# Eval("Status") %></span></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>

    <script>
        // Revenue Trend Chart
        <asp:Literal ID="litChartData" runat="server" />
    </script>
</asp:Content>
