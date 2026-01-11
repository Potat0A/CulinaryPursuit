<%@ Page Title="Rewards Store" Language="C#" MasterPageFile="~/Customer.Master" AutoEventWireup="true" CodeBehind="Rewards.aspx.cs" Inherits="CulinaryPursuit.Rewards" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        body {
            background-color: #fff7f2 !important;
            margin: 0;
            padding: 0;
        }

        .rewards-page {
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

        .filter-section {
            background: white;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
        }

        /* Voucher cards – stacked & responsive */
        .voucher-grid {
            display: flex;
            flex-direction: column;
            gap: 24px;
            max-width: 800px;
            margin: 40px auto 60px auto;
        }

        .voucher-card {
            display: flex;
            background: white;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 8px 25px rgba(0,0,0,0.08);
            transition: transform 0.3s ease;
            position: relative;
        }

        .voucher-card:hover {
            transform: scale(1.01);
        }

        .voucher-card.unavailable {
            opacity: 0.6;
            pointer-events: none;
        }

        .voucher-image-box {
            width: 260px;
            height: 275px;
            background: #f0f0f0;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            flex-shrink: 0;
        }

        .voucher-image-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .voucher-image-box .no-image {
            color: #999;
            font-size: 3rem;
        }

        .voucher-details {
            padding: 20px 30px;
            flex-grow: 1;
            text-align: left;
            display: flex;
            flex-direction: column;
        }

        .v-title {
            font-weight: 800;
            font-size: 1.6rem;
            margin: 0 0 4px 0;
            color: #222;
        }

        .v-rest {
            margin: 4px 0 0 0;
            color: #777;
            font-size: 1.0rem;
        }

        .v-highlight {
            color: #ff7b00;
            font-size: 1.0rem;
            font-weight: 600;
            margin: 0;
        }

        .v-limits {
            color: #777;
            font-size: 0.9rem;
            font-weight: 600;
            font-style: italic;
            margin: 0;
        }

        .voucher-divider {
            margin: 30px 0 0 0;
            border-top: 1px solid #e0e0e0;
            width: 100%;
        }

        .v-cost {
            font-size: 2.1rem;
            font-weight: 900;
            color: #FF2C2C;
            margin: 5px 0 0 0;
        }

        .voucher-bottom {
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            gap: 10px;
            margin-top: auto;
        }

        .btn-redeem-large {
            background-color: #ff3c00;
            color: white;
            border: none;
            padding: 10px 28px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1rem;
            cursor: pointer;
            width: fit-content;
            transition: 0.3s;
            margin-top: 10px;
        }

        .btn-redeem-large:hover {
            background-color: #e63600;
        }

        .btn-redeem-large:disabled {
            background-color: #ccc;
            cursor: not-allowed;
        }

        .badge-green {
            background-color: #28a745;
            color: white;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            padding: 15px 12px;
            font-weight: bold;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 2px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .badge-exclusive {
            background-color: #FFD700;
            color: #3b3200;
            writing-mode: vertical-rl;
            text-orientation: mixed;
            padding: 15px 12px;
            font-weight: bold;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 2px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }

        .empty-state h3 {
            margin-bottom: 10px;
        }

        .msg-status {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-weight: 600;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
        }

        .msg-success {
            background: #e8f5e9;
            color: #137333;
        }

        .msg-error {
            background: #ffebee;
            color: #d93025;
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

        /* Responsive tweaks */
        @media (max-width: 900px) {
            .voucher-card {
                flex-direction: column;
            }

            .voucher-image-box {
                width: 100%;
                height: 200px;
            }

            .badge-green,
            .badge-exclusive {
                writing-mode: horizontal-tb;
                padding: 8px;
                font-size: 0.8rem;
                justify-content: center;
            }
        }

        @media (max-width: 600px) {
            .voucher-details {
                padding: 18px 18px;
                text-align: center;
                align-items: center;
            }

            .voucher-bottom {
                flex-direction: column;
                align-items: center;
                gap: 6px;
            }

            .v-cost {
                font-size: 1.8rem;
                margin: 0;
            }

            .btn-redeem-large {
                width: 100%;
                text-align: center;
                margin-top: 4px;
            }

            .header-title {
                font-size: 2rem;
            }
        }
    </style>

    <div class="container rewards-page">
        <!-- Points Header -->
        <div class="points-header">
            <h1>🏆 Rewards Store</h1>
            <p>Redeem your points for amazing rewards!</p>
            <div class="points-display">
                <asp:Label ID="lblPointsBalance" runat="server" Text="0" /> Points
            </div>
        </div>

        <!-- Tab Pills Navigation -->
        <nav class="nav-tabs-pill">
            <a href="Rewards.aspx" class="pill-item active">Rewards Store</a>
            <a href="redeemrewards.aspx" class="pill-item inactive">Redeem Rewards</a>
            <a href="PointsTransactions.aspx" class="pill-item inactive">Points Transactions</a>
        </nav>

        <asp:Label ID="lblStatus" runat="server" EnableViewState="false" />

        <!-- Spin the Wheel Section -->
        <div style="background: linear-gradient(135deg, #ff8c42, #ff5c5c); padding: 25px; border-radius: 15px; margin-bottom: 25px; text-align: center; max-width: 800px; margin-left: auto; margin-right: auto; box-shadow: 0 8px 20px rgba(0,0,0,0.1);">
            <h3 style="color: white; margin-bottom: 15px; font-weight: 700;">🎡 Spin the Wheel</h3>
            <p style="color: rgba(255,255,255,0.9); margin-bottom: 20px;">Spin daily to win points! 3 spins per day. Points expire in 1 year.</p>
            <a href="SpinGame.aspx" style="background: white; color: #ff3c00; padding: 12px 30px; border-radius: 50px; font-weight: 700; text-decoration: none; display: inline-block; transition: all 0.3s ease;">
                🎯 Spin Now
            </a>
        </div>

        <!-- Filter Section -->
        <div class="filter-section">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <label class="form-label">Filter by Category:</label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                        <asp:ListItem Value="">All Categories</asp:ListItem>
                        <asp:ListItem Value="Discounts">Discounts</asp:ListItem>
                        <asp:ListItem Value="Vouchers">Vouchers</asp:ListItem>
                        <asp:ListItem Value="Free Items">Free Items</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Sort by:</label>
                    <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-select"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                        <asp:ListItem Value="PointsRequired ASC">Points: Low to High</asp:ListItem>
                        <asp:ListItem Value="PointsRequired DESC">Points: High to Low</asp:ListItem>
                        <asp:ListItem Value="Name ASC">Name: A to Z</asp:ListItem>
                        <asp:ListItem Value="CreatedDate DESC" Selected="True">Newest First</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
        </div>

        <!-- Vouchers stacked vertically -->
        <div class="voucher-grid">
            <asp:Repeater ID="rptRewards" runat="server" OnItemCommand="rptRewards_ItemCommand">
                <ItemTemplate>
                    <div class="voucher-card <%# !(bool)Eval("IsAvailable") ? "unavailable" : "" %>">
                        <div class="voucher-image-box">
                            <%# GetRewardImage(Eval("ImagePath")) %>
                        </div>
                        <div class="voucher-details">
                            <div>
                                <p class="v-title"><%# Eval("Name") %></p>
                                <p class="v-rest">
                                    Partnering: <span class="v-highlight"><%# GetPartneringStores(Eval("PartneringStores")) %></span>
                                </p>
                                <p class="v-rest">
                                    Category: <span class="v-highlight"><%# Eval("Category") == DBNull.Value || Eval("Category") == null ? "General" : Eval("Category") %></span>
                                </p>
                                <p class="v-rest" runat="server" visible='<%# HasExpiryInfo(Eval("ExpiryType"), Eval("ExpiryDate"), Eval("ExpiryTimespanValue"), Eval("ExpiryTimespanUnit")) %>'>
                                    Expiry: <span class="v-highlight"><%# FormatExpiryInfo(Eval("ExpiryType"), Eval("ExpiryDate"), Eval("ExpiryTimespanValue"), Eval("ExpiryTimespanUnit")) %></span>
                                </p>
                                <p class="v-limits">
                                    <%# Eval("StockQuantity") == DBNull.Value
                                        ? "Unlimited"
                                        : "Limited " + Eval("StockQuantity").ToString() + " only" %>
                                </p>
                            </div>
                            <div class="voucher-divider"></div>
                            <div class="voucher-bottom">
                                <div class="v-cost"><%# Eval("PointsRequired") %> pts</div>
                                <asp:Button ID="btnRedeem" runat="server"
                                    Text="Redeem Now"
                                    CssClass="btn-redeem-large"
                                    CommandName="Redeem"
                                    CommandArgument='<%# Eval("RewardID") %>'
                                    Enabled='<%# GetRedeemEnabled(Eval("IsAvailable"), Eval("PointsRequired")) %>'
                                    OnClientClick='<%# GetRedeemConfirmScript(Eval("RewardID"), Eval("Name"), Eval("PointsRequired")) %>' />
                            </div>
                        </div>
                        <div class='<%# GetBadgeClass(Eval("StockQuantity")) %>'>
                            <%# GetBadgeText(Eval("StockQuantity")) %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <asp:Label ID="lblEmpty" runat="server"
            Text="<div class='empty-state'><h3>No rewards available at the moment.</h3><p>Check back later for new rewards!</p></div>"
            Visible="false" />
    </div>

    <!-- Confirmation Modal for Redeem -->
    <div class="modal fade" id="confirmRedeemModal" tabindex="-1" aria-labelledby="confirmRedeemModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="confirmRedeemModalLabel">Confirm Redemption</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to redeem this reward?</p>
                    <p id="confirmRedeemRewardName" style="font-weight: 600; color: #ff6b35;"></p>
                    <p id="confirmRedeemPoints" style="color: #666;"></p>
                    <p style="color: #d93025; font-weight: 600;">This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">No, Cancel</button>
                    <asp:Button ID="btnConfirmRedeem" runat="server" Text="Yes, Redeem" CssClass="btn btn-primary"
                        OnClick="btnConfirmRedeem_Click" style="display: none;" />
                    <button type="button" id="btnConfirmRedeemClient" class="btn btn-primary" onclick="proceedToRedeem()">Yes, Redeem</button>
                </div>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hdnRedeemRewardID" runat="server" />

    <script type="text/javascript">
        function confirmRedeem(rewardId, rewardName, pointsRequired) {
            document.getElementById('<%= hdnRedeemRewardID.ClientID %>').value = rewardId;
            document.getElementById('confirmRedeemRewardName').textContent = rewardName;
            document.getElementById('confirmRedeemPoints').textContent = 'This will cost you ' + pointsRequired + ' points.';
            var modal = new bootstrap.Modal(document.getElementById('confirmRedeemModal'));
            modal.show();
            return false; // Prevent postback
        }

        function proceedToRedeem() {
            document.getElementById('<%= btnConfirmRedeem.ClientID %>').click();
        }
    </script>
</asp:Content>
