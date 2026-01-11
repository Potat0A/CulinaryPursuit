<%@ Page Title="Points Transactions" Language="C#" MasterPageFile="~/Customer.Master" AutoEventWireup="true" CodeBehind="PointsTransactions.aspx.cs" Inherits="CulinaryPursuit.PointsTransactions" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        body {
            background-color: #fff7f2 !important;
            margin: 0;
            padding: 0;
        }

        .transactions-page {
            padding: 30px 0;
            min-height: 80vh;
        }

        .points-header {
            background: linear-gradient(135deg, #ff8c42, #ff5c5c);
            color: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            text-align: center;
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
        }

        .points-header h1 {
            font-weight: 800;
            margin-bottom: 10px;
        }

        .points-display {
            font-size: 3rem;
            font-weight: 900;
            margin: 15px 0;
        }

        .nav-tabs-pill {
            display: flex;
            justify-content: center;
            gap: 15px;
            flex-wrap: wrap;
            margin-bottom: 30px;
        }

        .pill-item {
            padding: 10px 25px;
            border-radius: 50px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.3s ease;
            font-size: 0.95rem;
            border: 2px solid #ff3c00;
        }

        .pill-item.active {
            background-color: #ff3c00;
            color: #ffffff;
        }

        .pill-item.inactive {
            background-color: #ffffff;
            color: #ff3c00;
        }

        .pill-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(255, 60, 0, 0.3);
        }

        .transactions-container {
            max-width: 1000px;
            margin: 0 auto;
        }

        .transaction-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: transform 0.2s ease;
        }

        .transaction-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .transaction-info {
            flex-grow: 1;
        }

        .transaction-type {
            font-size: 1.1rem;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .transaction-type.earned {
            color: #28a745;
        }

        .transaction-type.spent {
            color: #dc3545;
        }

        .transaction-type.expired {
            color: #6c757d;
        }

        .transaction-description {
            color: #666;
            font-size: 0.95rem;
            margin-bottom: 5px;
        }

        .transaction-date {
            color: #999;
            font-size: 0.85rem;
        }

        .transaction-points {
            font-size: 1.5rem;
            font-weight: 900;
            text-align: right;
        }

        .transaction-points.positive {
            color: #28a745;
        }

        .transaction-points.negative {
            color: #dc3545;
        }

        .expiry-badge {
            background: #ffc107;
            color: #333;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-top: 5px;
            display: inline-block;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
            background: white;
            border-radius: 12px;
        }

        .empty-state h3 {
            margin-bottom: 10px;
        }

        .filter-controls {
            background: white;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
    </style>

    <div class="container transactions-p age">
        <!-- Points Header -->
        <div class="points-header">
            <h1>Points Transactions</h1>
            <p>View your complete points history</p>
            <div class="points-display">
                <asp:Label ID="lblPointsBalance" runat="server" Text="0" /> Points
            </div>
        </div>

        <!-- Tab Pills Navigation -->
        <nav class="nav-tabs-pill">
            <a href="Rewards.aspx" class="pill-item inactive">Rewards Store</a>
            <a href="redeemrewards.aspx" class="pill-item inactive">Redeem Rewards</a>
            <a href="PointsTransactions.aspx" class="pill-item active">Points Transactions</a>
        </nav>

        <div class="transactions-container">
            <div class="filter-controls">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <label class="form-label">Filter by Type:</label>
                        <asp:DropDownList ID="ddlTransactionType" runat="server" CssClass="form-select" 
                            AutoPostBack="true" OnSelectedIndexChanged="ddlTransactionType_SelectedIndexChanged">
                            <asp:ListItem Value="">All Types</asp:ListItem>
                            <asp:ListItem Value="Earned">Earned</asp:ListItem>
                            <asp:ListItem Value="Spent">Spent</asp:ListItem>
                            <asp:ListItem Value="SpinWheel">Spin Wheel</asp:ListItem>
                            <asp:ListItem Value="Redeemed">Redeemed</asp:ListItem>
                            <asp:ListItem Value="Used">Used</asp:ListItem>
                            <asp:ListItem Value="Expired">Expired</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Sort by:</label>
                        <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-select" 
                            AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                            <asp:ListItem Value="TransactionDate DESC" Selected="True">Newest First</asp:ListItem>
                            <asp:ListItem Value="TransactionDate ASC">Oldest First</asp:ListItem>
                            <asp:ListItem Value="Points DESC">Points: High to Low</asp:ListItem>
                            <asp:ListItem Value="Points ASC">Points: Low to High</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
            </div>

            <asp:Label ID="lblStatus" runat="server" EnableViewState="false" />

            <asp:Repeater ID="rptTransactions" runat="server">
                <ItemTemplate>
                    <div class="transaction-card">
                        <div class="transaction-info">
                            <div class="transaction-type <%# GetTransactionTypeClass(Eval("TransactionType")) %>">
                                <%# GetTransactionTypeDisplay(Eval("TransactionType")) %>
                            </div>
                            <div class="transaction-description">
                                <%# Eval("Description") != DBNull.Value ? Eval("Description") : "No description" %>
                            </div>
                            <div class="transaction-date">
                                <%# Convert.ToDateTime(Eval("TransactionDate")).ToString("dd MMM yyyy, hh:mm tt") %>
                            </div>
                            <%# GetExpiryBadge(Eval("ExpiryDate")) %>
                        </div>
                        <div class="transaction-points <%# Convert.ToInt32(Eval("Points")) >= 0 ? "positive" : "negative" %>">
                            <%# Convert.ToInt32(Eval("Points")) >= 0 ? "+" : "" %><%# Eval("Points") %> pts
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Label ID="lblEmpty" runat="server" 
                Text="<div class='empty-state'><h3>No transactions found.</h3><p>Your points history will appear here.</p></div>"
                Visible="false" />
        </div>
    </div>
</asp:Content>
