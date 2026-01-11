<%@ Page Title="View Redemptions" Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="AdminViewRedemptions.aspx.cs" Inherits="CulinaryPursuit.AdminViewRedemptions" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .rewards-container {
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            padding: 25px;
            margin-bottom: 20px;
        }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }

        .header-section h2 {
            margin: 0;
            color: #333;
            font-weight: 700;
        }

        /* Pill Button Navigation - matching customer rewards style */
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
            border: 2px solid #ff6b35;
        }

        .pill-item.active {
            background-color: #ff6b35;
            color: #ffffff;
        }

        .pill-item.inactive {
            background-color: #ffffff;
            color: #ff6b35;
        }

        .pill-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 107, 53, 0.3);
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table-header {
            background: linear-gradient(135deg, #ff6b35, #ff8c42);
            color: white;
            font-weight: 600;
        }

        .table-row:hover {
            background-color: #f8f9fa;
        }

        .msg-ok {
            background: #d4edda;
            color: #155724;
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid #c3e6cb;
        }

        .msg-err {
            background: #f8d7da;
            color: #721c24;
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 8px;
        }

        .alert-info {
            background-color: #d1ecf1;
            border: 1px solid #bee5eb;
            color: #0c5460;
        }

        .alert-link {
            color: #0c5460;
            text-decoration: underline;
            font-weight: 600;
        }

        .alert-link:hover {
            color: #062c33;
        }

        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #ff6b35;
            text-decoration: none;
            font-weight: 600;
        }

        .back-link:hover {
            color: #ff8c42;
            text-decoration: underline;
        }
    </style>

    <div class="rewards-container">
        <!-- Pill Button Navigation -->
        <nav class="nav-tabs-pill">
            <a href="AdminRewards.aspx?view=manage" class="pill-item inactive">
                Manage Rewards Store
            </a>
            <a href="AdminRewards.aspx?view=add" class="pill-item inactive">
                Add New Reward
            </a>
            <a href="AdminViewRedemptions.aspx" class="pill-item active">
                View All Redemptions
            </a>
        </nav>

        <div class="card">
            <div class="header-section">
                <h2>View All Redemptions</h2>
            </div>

            <asp:Label ID="lblStatus" runat="server" EnableViewState="false" />

            <!-- Filter Controls -->
            <div class="filter-controls" style="background: #f8f9fa; padding: 20px; border-radius: 10px; margin-bottom: 20px;">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <label class="form-label" style="font-weight: 600; margin-bottom: 8px;">Filter by Reward Name:</label>
                        <asp:DropDownList ID="ddlRewardName" runat="server" CssClass="form-select" 
                            AutoPostBack="true" OnSelectedIndexChanged="ddlRewardName_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label" style="font-weight: 600; margin-bottom: 8px;">Filter by Category:</label>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select" 
                            AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>
                </div>
            </div>

            <asp:GridView ID="gvAllRedemptions" runat="server"
                AutoGenerateColumns="false"
                DataKeyNames="RedemptionID"
                OnRowDeleting="gvAllRedemptions_RowDeleting"
                EmptyDataText="No redemptions found."
                GridLines="None"
                CssClass="table table-hover"
                HeaderStyle-CssClass="table-header">
                <Columns>
                    <asp:BoundField DataField="RedemptionID" HeaderText="Redemption ID" ReadOnly="true" ItemStyle-Width="80px" />
                    <asp:BoundField DataField="RewardID" HeaderText="Reward ID" ReadOnly="true" ItemStyle-Width="80px" />
                    <asp:BoundField DataField="RewardName" HeaderText="Reward Name" ReadOnly="true" />
                    <asp:BoundField DataField="Category" HeaderText="Category" ReadOnly="true" />
                    <asp:BoundField DataField="CustomerID" HeaderText="Customer ID" ReadOnly="true" />
                    <asp:BoundField DataField="PointsUsed" HeaderText="Points Used" ReadOnly="true" />
                    <asp:BoundField DataField="RedemptionDate" HeaderText="Redemption Date" 
                        DataFormatString="{0:dd/MM/yyyy HH:mm}" ReadOnly="true" />
                    <asp:BoundField DataField="Status" HeaderText="Status" ReadOnly="true" />
                    <asp:BoundField DataField="ExpiryDate" HeaderText="Expiry Date" 
                        DataFormatString="{0:dd/MM/yyyy}" 
                        NullDisplayText="N/A" ReadOnly="true" />
                    <asp:BoundField DataField="UsedDate" HeaderText="Used Date" 
                        DataFormatString="{0:dd/MM/yyyy HH:mm}" 
                        NullDisplayText="N/A" ReadOnly="true" />
                    <asp:CommandField ShowDeleteButton="true" ButtonType="Button"
                        DeleteText="Delete"
                        ControlStyle-CssClass="btn btn-sm btn-outline-danger" />
                </Columns>
            </asp:GridView>
        </div>
    </div>


</asp:Content>
