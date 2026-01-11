<%@ Page Title="Platform Fees" Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="AdminPlatformFees.aspx.cs" Inherits="CulinaryPursuit.AdminPlatformFees" %>
<%-- Author: Henry --%>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .dashboard-header {
            background: linear-gradient(135deg, #ff8c42, #ff5c5c);
            padding: 40px 30px;
            border-radius: 15px;
            color: white;
            margin-bottom: 25px;
        }

        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
            transition: all 0.25s;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 25px rgba(0,0,0,0.15);
        }

        .stat-card.pending {
            border-left: 5px solid #ffc107;
        }

        .stat-card.overdue {
            border-left: 5px solid #dc3545;
        }

        .stat-card.paid {
            border-left: 5px solid #28a745;
        }

        .stat-card.total {
            border-left: 5px solid #007bff;
        }

        .stat-number {
            font-size: 2.2rem;
            font-weight: 800;
            color: #ff6f3c;
        }

        .stat-label {
            font-size: 1.1rem;
            font-weight: 600;
            color: #444;
        }

        .fees-section {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 20px;
            color: #333;
        }

        .filters {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        .fee-table {
            width: 100%;
        }

        .fee-table thead {
            background: #f8f9fa;
        }

        .fee-table th {
            padding: 15px;
            font-weight: 700;
            color: #333;
            border-bottom: 2px solid #dee2e6;
        }

        .fee-table td {
            padding: 15px;
            border-bottom: 1px solid #f0f0f0;
        }

        .fee-table tr:hover {
            background: #f8f9fa;
        }

        .status-badge {
            padding: 6px 15px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.85rem;
            display: inline-block;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
        }

        .status-overdue {
            background: #f8d7da;
            color: #721c24;
        }

        .status-paid {
            background: #d4edda;
            color: #155724;
        }

        .status-waived {
            background: #d1ecf1;
            color: #0c5460;
        }

        .btn-action {
            padding: 8px 15px;
            border-radius: 20px;
            border: none;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.85rem;
        }

        .btn-waive {
            background: #17a2b8;
            color: white;
        }

        .btn-waive:hover {
            background: #138496;
        }

        .btn-extend {
            background: #ffc107;
            color: #333;
        }

        .btn-extend:hover {
            background: #e0a800;
        }

        .restaurant-name {
            font-weight: 700;
            color: #ff6f3c;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <div class="dashboard-header">
        <h1 style="font-weight:800;">💳 Platform Fees Management</h1>
        <p style="opacity:0.8;">Monitor and manage platform fee payments from all restaurants</p>
    </div>

            <!-- Statistics -->
            <div class="stats-row">
                <div class="stat-card pending">
                    <div class="stat-number">$<asp:Label ID="lblPendingTotal" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Pending Fees</div>
                    <small><asp:Label ID="lblPendingCount" runat="server" Text="0" /> fees</small>
                </div>

                <div class="stat-card overdue">
                    <div class="stat-number">$<asp:Label ID="lblOverdueTotal" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Overdue Fees</div>
                    <small><asp:Label ID="lblOverdueCount" runat="server" Text="0" /> fees</small>
                </div>

                <div class="stat-card paid">
                    <div class="stat-number">$<asp:Label ID="lblPaidTotal" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Collected This Month</div>
                    <small><asp:Label ID="lblPaidCount" runat="server" Text="0" /> payments</small>
                </div>

                <div class="stat-card total">
                    <div class="stat-number">$<asp:Label ID="lblTotalRevenue" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Total Revenue (All Time)</div>
                </div>
            </div>

            <!-- Filters -->
            <div class="fees-section">
                <h3 class="section-title">Filter Fees</h3>
                <div class="filters">
                    <div class="row">
                        <div class="col-md-4">
                            <label>Status</label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">All Statuses</asp:ListItem>
                                <asp:ListItem Value="Pending">Pending</asp:ListItem>
                                <asp:ListItem Value="Overdue">Overdue</asp:ListItem>
                                <asp:ListItem Value="Paid">Paid</asp:ListItem>
                                <asp:ListItem Value="Waived">Waived</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <label>Restaurant</label>
                            <asp:DropDownList ID="ddlRestaurant" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">All Restaurants</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <label>&nbsp;</label>
                            <asp:Button ID="btnApplyFilter" runat="server" Text="Apply Filters" CssClass="btn btn-primary w-100" OnClick="btnApplyFilter_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Fees Table -->
            <div class="fees-section">
                <h3 class="section-title">Platform Fees</h3>

                <asp:Panel ID="pnlFees" runat="server">
                    <div class="table-responsive">
                        <table class="fee-table">
                            <thead>
                                <tr>
                                    <th>Restaurant</th>
                                    <th>Order ID</th>
                                    <th>Amount</th>
                                    <th>Fee %</th>
                                    <th>Status</th>
                                    <th>Due Date</th>
                                    <th>Paid Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptFees" runat="server" OnItemCommand="rptFees_ItemCommand">
                                    <ItemTemplate>
                                        <tr>
                                            <td><span class="restaurant-name"><%# Eval("RestaurantName") %></span></td>
                                            <td>#<%# Eval("OrderID") %></td>
                                            <td><strong>$<%# Eval("FeeAmount", "{0:F2}") %></strong></td>
                                            <td><%# Eval("FeePercentage", "{0:F2}") %>%</td>
                                            <td>
                                                <span class='status-badge <%# GetStatusClass(Eval("FeeStatus").ToString()) %>'>
                                                    <%# Eval("FeeStatus") %>
                                                </span>
                                            </td>
                                            <td><%# Eval("DueDate", "{0:MMM dd, yyyy}") %></td>
                                            <td><%# Eval("PaidDate") != DBNull.Value ? ((DateTime)Eval("PaidDate")).ToString("MMM dd, yyyy") : "-" %></td>
                                            <td>
                                                <asp:Button
                                                    runat="server"
                                                    Text="Waive"
                                                    CssClass="btn-action btn-waive"
                                                    CommandName="Waive"
                                                    CommandArgument='<%# Eval("PlatformFeeID") %>'
                                                    Visible='<%# Eval("FeeStatus").ToString() != "Paid" && Eval("FeeStatus").ToString() != "Waived" %>' />
                                                <asp:Button
                                                    runat="server"
                                                    Text="Extend"
                                                    CssClass="btn-action btn-extend"
                                                    CommandName="Extend"
                                                    CommandArgument='<%# Eval("PlatformFeeID") %>'
                                                    Visible='<%# Eval("FeeStatus").ToString() != "Paid" && Eval("FeeStatus").ToString() != "Waived" %>' />
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlNoFees" runat="server" Visible="false" CssClass="text-center py-5">
                    <h4>No fees found</h4>
                    <p class="text-muted">Try adjusting your filters</p>
                </asp:Panel>
            </div>
        </div>
</asp:Content>
