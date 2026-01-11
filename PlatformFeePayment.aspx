<%@ Page Title="Platform Fees" Language="C#" MasterPageFile="~/chef.Master" AutoEventWireup="true" CodeBehind="PlatformFeePayment.aspx.cs" Inherits="CulinaryPursuit.PlatformFeePayment" %>
<%-- Author: Henry --%>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .stats-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            text-align: center;
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

        .stat-value {
            font-size: 2rem;
            font-weight: 900;
            margin: 10px 0;
        }

        .stat-label {
            color: #666;
            font-size: 0.9rem;
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

        .fee-item {
            padding: 20px;
            border-bottom: 1px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .fee-item:last-child {
            border-bottom: none;
        }

        .fee-details {
            flex: 1;
        }

        .fee-order {
            font-weight: 700;
            color: #333;
            margin-bottom: 5px;
        }

        .fee-date {
            color: #666;
            font-size: 0.9rem;
        }

        .fee-amount {
            font-size: 1.5rem;
            font-weight: 900;
            color: #1e88e5;
            margin-right: 20px;
        }

        .fee-status {
            padding: 8px 20px;
            border-radius: 25px;
            font-weight: 600;
            font-size: 0.9rem;
            margin-right: 15px;
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

        .btn-pay {
            background: linear-gradient(135deg, #1e88e5, #1565c0);
            color: white;
            border: none;
            padding: 10px 25px;
            border-radius: 25px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-pay:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(30,136,229,0.4);
        }

        .btn-pay-later {
            background: white;
            color: #1e88e5;
            border: 2px solid #1e88e5;
            padding: 10px 25px;
            border-radius: 25px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-pay-later:hover {
            background: #1e88e5;
            color: white;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 20px;
        }

        .payment-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        .modal-content {
            background: white;
            padding: 40px;
            border-radius: 20px;
            max-width: 500px;
            width: 90%;
        }

        .modal-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 20px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <h2 class="mb-4">💳 Platform Fees</h2>

    <!-- STATISTICS -->
    <div class="stats-row">
        <div class="stat-card pending">
            <div class="stat-label">⏳ Pending Fees</div>
            <div class="stat-value">$<asp:Label ID="lblPendingTotal" runat="server" Text="0.00" /></div>
            <div class="stat-label"><asp:Label ID="lblPendingCount" runat="server" Text="0" /> fees</div>
        </div>

        <div class="stat-card overdue">
            <div class="stat-label">⚠️ Overdue Fees</div>
            <div class="stat-value">$<asp:Label ID="lblOverdueTotal" runat="server" Text="0.00" /></div>
            <div class="stat-label"><asp:Label ID="lblOverdueCount" runat="server" Text="0" /> fees</div>
        </div>

        <div class="stat-card paid">
            <div class="stat-label">✅ Paid This Month</div>
            <div class="stat-value">$<asp:Label ID="lblPaidTotal" runat="server" Text="0.00" /></div>
            <div class="stat-label"><asp:Label ID="lblPaidCount" runat="server" Text="0" /> fees</div>
        </div>
    </div>

    <!-- PENDING & OVERDUE FEES -->
    <div class="fees-section">
        <h3 class="section-title">Unpaid Fees</h3>

        <asp:Panel ID="pnlUnpaidFees" runat="server">
            <asp:Repeater ID="rptUnpaidFees" runat="server" OnItemCommand="rptUnpaidFees_ItemCommand">
                <ItemTemplate>
                    <div class="fee-item">
                        <div class="fee-details">
                            <div class="fee-order">Order #<%# Eval("OrderID") %></div>
                            <div class="fee-date">
                                Due: <%# ((DateTime)Eval("DueDate")).ToString("MMM dd, yyyy") %>
                                <%# ((DateTime)Eval("DueDate") < DateTime.Now) ? "<span style='color:#dc3545; font-weight:700;'>(OVERDUE)</span>" : "" %>
                            </div>
                        </div>
                        <div class="fee-amount">$<%# Eval("FeeAmount", "{0:F2}") %></div>
                        <span class='fee-status <%# GetStatusClass(Eval("FeeStatus").ToString()) %>'>
                            <%# Eval("FeeStatus") %>
                        </span>
                        <asp:Button
                            runat="server"
                            Text="Pay Now"
                            CssClass="btn-pay"
                            CommandName="PayNow"
                            CommandArgument='<%# Eval("PlatformFeeID") %>' />
                        <asp:Button
                            runat="server"
                            Text="Request Extension"
                            CssClass="btn-pay-later"
                            CommandName="RequestExtension"
                            CommandArgument='<%# Eval("PlatformFeeID") %>' />
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

        <asp:Panel ID="pnlNoUnpaid" runat="server" Visible="false" CssClass="empty-state">
            <div>✅</div>
            <h3>All caught up!</h3>
            <p>You have no unpaid platform fees</p>
        </asp:Panel>
    </div>

    <!-- PAYMENT HISTORY -->
    <div class="fees-section">
        <h3 class="section-title">Payment History</h3>

        <asp:Panel ID="pnlPaidFees" runat="server">
            <asp:Repeater ID="rptPaidFees" runat="server">
                <ItemTemplate>
                    <div class="fee-item">
                        <div class="fee-details">
                            <div class="fee-order">Order #<%# Eval("OrderID") %></div>
                            <div class="fee-date">
                                Paid: <%# Eval("PaidDate", "{0:MMM dd, yyyy}") %> |
                                Method: <%# Eval("PaymentMethod") %>
                            </div>
                        </div>
                        <div class="fee-amount">$<%# Eval("FeeAmount", "{0:F2}") %></div>
                        <span class="fee-status status-paid">Paid</span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </asp:Panel>

        <asp:Panel ID="pnlNoPaid" runat="server" Visible="false" CssClass="empty-state">
            <div>📋</div>
            <h3>No payment history</h3>
            <p>Your paid fees will appear here</p>
        </asp:Panel>
    </div>

    <!-- PAYMENT MODAL (Hidden by default) -->
    <div id="paymentModal" class="payment-modal">
        <div class="modal-content">
            <h3 class="modal-title">💳 Complete Payment</h3>
            <asp:HiddenField ID="hfSelectedFeeID" runat="server" />

            <div class="form-group mb-3">
                <label>Payment Method</label>
                <asp:DropDownList ID="ddlPaymentMethod" runat="server" CssClass="form-select">
                    <asp:ListItem Value="BankTransfer">🏦 Bank Transfer</asp:ListItem>
                    <asp:ListItem Value="CreditCard">💳 Credit Card</asp:ListItem>
                    <asp:ListItem Value="PayNow">📱 PayNow</asp:ListItem>
                    <asp:ListItem Value="Cheque">📝 Cheque</asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="form-group mb-3">
                <label>Transaction Reference (Optional)</label>
                <asp:TextBox ID="txtTransactionRef" runat="server" CssClass="form-control" Placeholder="e.g., TXN123456" />
            </div>

            <div class="d-flex gap-2">
                <asp:Button ID="btnConfirmPayment" runat="server" Text="Confirm Payment" CssClass="btn-pay flex-fill" OnClick="btnConfirmPayment_Click" />
                <button type="button" class="btn-pay-later flex-fill" onclick="closePaymentModal()">Cancel</button>
            </div>
        </div>
    </div>

    <script>
        function showPaymentModal(feeID) {
            document.getElementById('paymentModal').style.display = 'flex';
            document.getElementById('<%= hfSelectedFeeID.ClientID %>').value = feeID;
        }

        function closePaymentModal() {
            document.getElementById('paymentModal').style.display = 'none';
        }
    </script>
</asp:Content>
