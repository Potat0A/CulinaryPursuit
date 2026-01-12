<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/Chef.Master"
    CodeBehind="RestaurantDashboard.aspx.cs"
    Inherits="CulinaryPursuit.RestaurantDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <!-- HEADER -->
    <div class="mb-4">
        <h2 style="font-weight:800;">👨‍🍳 Chef Dashboard</h2>
        <p class="text-muted">
            Welcome back,
            <asp:Label ID="lblRestaurantName" runat="server" />
        </p>
    </div>

    <!-- STATS -->
    <div class="row g-4">

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number">
                    <asp:Label ID="lblTodayOrders" runat="server" Text="0" />
                </div>
                <div>Orders Today</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number">
                    $<asp:Label ID="lblMonthlyEarnings" runat="server" Text="0" />
                </div>
                <div>This Month's Earnings</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number">
                    <asp:Label ID="lblRating" runat="server" Text="0" />
                </div>
                <div>Average Rating</div>
            </div>
        </div>

        <div class="col-md-3">
            <div class="stat-card">
                <div class="stat-number">
                    <asp:Label ID="lblTotalMenuItems" runat="server" Text="0" />
                </div>
                <div>Menu Items</div>
            </div>
        </div>

    </div>

    

</asp:Content>
