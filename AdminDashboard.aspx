<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="CulinaryPursuit.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .dashboard-header {
            background: linear-gradient(135deg, #ff8c42, #ff5c5c);
            padding: 40px 30px;
            border-radius: 15px;
            color: white;
            margin-bottom: 25px;
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

        .quick-btn {
            width: 100%;
            padding: 15px;
            border-radius: 15px;
            font-weight: 700;
            background: #ff6f3c;
            color: white;
            text-align: center;
            margin-bottom: 15px;
            display: block;
            transition: 0.3s;
        }

        .quick-btn:hover {
            background: #ff4f1c;
            color: white;
            text-decoration: none;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Dashboard Header -->
    <div class="dashboard-header">
        <h1 style="font-weight:800;">Dashboard Overview</h1>
        <p style="opacity:0.8;">Manage chefs, customers, rewards & events</p>
    </div>

    <!-- Stats Row -->
    <div class="row g-4">
        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number">
                    <asp:Label ID="lblPending" runat="server" Text="0" />
                </div>
                <div class="stat-label">Pending Chef Applications</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number">
                    <asp:Label ID="lblApproved" runat="server" Text="0" />
                </div>
                <div class="stat-label">Approved Chefs</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number">
                    <asp:Label ID="lblCustomers" runat="server" Text="0" />
                </div>
                <div class="stat-label">Total Customers</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number">
                    <asp:Label ID="lblOrders" runat="server" Text="0" />
                </div>
                <div class="stat-label">Total Orders</div>
            </div>
        </div>
    </div>

</asp:Content>
