<%@ Page Title="Payment Voucher Simulator" Language="C#" MasterPageFile="~/Customer.Master" AutoEventWireup="true" CodeBehind="PaymentVoucherSimulator.aspx.cs" Inherits="CulinaryPursuit.PaymentVoucherSimulator" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        body {
            background-color: #fff7f2 !important;
        }

        .payment-container {
            max-width: 800px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .payment-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .payment-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f0f0f0;
        }

        .payment-header h1 {
            color: #333;
            font-weight: 800;
            margin-bottom: 10px;
        }

        .payment-header p {
            color: #666;
            font-size: 1.1rem;
        }

        .order-summary {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
        }

        .order-item {
            display: flex;
            justify-content: space-between;
            padding: 15px 0;
            border-bottom: 1px solid #e0e0e0;
        }

        .order-item:last-child {
            border-bottom: none;
        }

        .order-item-label {
            font-weight: 600;
            color: #333;
        }

        .order-item-value {
            color: #666;
        }

        .reward-applied {
            background: #e8f5e9;
            border-left: 4px solid #28a745;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .reward-applied h3 {
            color: #28a745;
            margin: 0 0 10px 0;
            font-size: 1.2rem;
        }

        .reward-applied p {
            margin: 5px 0;
            color: #333;
        }

        .discount-applied {
            color: #28a745;
            font-weight: 700;
        }

        .voucher-applied {
            color: #28a745;
            font-weight: 700;
        }

        .free-item {
            color: #ff6b35;
            font-weight: 700;
        }

        .total-section {
            background: linear-gradient(135deg, #ff8c42, #ff5c5c);
            color: white;
            padding: 25px;
            border-radius: 15px;
            margin-top: 20px;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 1.1rem;
        }

        .total-row.final {
            font-size: 1.8rem;
            font-weight: 900;
            padding-top: 15px;
            border-top: 2px solid rgba(255,255,255,0.3);
            margin-top: 15px;
        }

        .payment-methods {
            margin-top: 30px;
        }

        .payment-methods h3 {
            margin-bottom: 20px;
            color: #333;
        }

        .payment-btn {
            width: 100%;
            padding: 15px;
            margin-bottom: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            background: white;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
            font-size: 1rem;
        }

        .payment-btn:hover {
            border-color: #ff6b35;
            background: #fff7f2;
        }

        .payment-btn.selected {
            border-color: #ff6b35;
            background: #fff7f2;
        }

        .btn-complete-payment {
            width: 100%;
            padding: 18px;
            background: linear-gradient(135deg, #ff8c42, #ff5c5c);
            color: white;
            border: none;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1.2rem;
            cursor: pointer;
            margin-top: 20px;
            transition: all 0.3s ease;
        }

        .btn-complete-payment:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(255, 108, 53, 0.3);
        }

        .btn-complete-payment:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }

        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            padding: 12px 24px;
            background: white;
            color: #ff6b35;
            text-decoration: none;
            font-weight: 600;
            border: 2px solid #ff6b35;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .back-link:hover {
            background: #ff6b35;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 107, 53, 0.3);
        }

        .msg-status {
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-weight: 600;
        }

        .msg-success {
            background: #e8f5e9;
            color: #137333;
        }

        .msg-error {
            background: #ffebee;
            color: #d93025;
        }
    </style>

    <div class="payment-container">
        <a href="redeemrewards.aspx" class="back-link">Back to Redeemed Rewards</a>

        <div class="payment-card">
            <div class="payment-header">
                <h1>Payment Voucher Simulator</h1>
                <p>Complete your payment with your reward applied</p>
            </div>

            <asp:Label ID="lblStatus" runat="server" EnableViewState="false" />

            <div class="order-summary">
                <h3 style="margin-top: 0; margin-bottom: 20px; color: #333;">Order Summary</h3>
                
                <div class="order-item">
                    <span class="order-item-label">Subtotal:</span>
                    <span class="order-item-value">$<asp:Label ID="lblSubtotal" runat="server" Text="100.00" /></span>
                </div>

                <asp:Panel ID="pnlRewardApplied" runat="server" Visible="false">
                    <div class="reward-applied">
                        <h3>Reward Applied</h3>
                        <p><strong><asp:Label ID="lblRewardName" runat="server" /></strong></p>
                        <p><asp:Label ID="lblRewardDescription" runat="server" /></p>
                        <asp:Panel ID="pnlDiscount" runat="server" Visible="false">
                            <p class="discount-applied">Discount: <asp:Label ID="lblDiscountPercentage" runat="server" />% OFF</p>
                        </asp:Panel>
                        <asp:Panel ID="pnlVoucher" runat="server" Visible="false">
                            <p class="voucher-applied">Voucher Amount: $<asp:Label ID="lblVoucherAmount" runat="server" /></p>
                        </asp:Panel>
                        <asp:Panel ID="pnlFreeItem" runat="server" Visible="false">
                            <p class="free-item">Free Item Applied!</p>
                        </asp:Panel>
                    </div>
                </asp:Panel>

                <div class="order-item">
                    <span class="order-item-label">Discount:</span>
                    <span class="order-item-value discount-applied">- $<asp:Label ID="lblDiscountAmount" runat="server" Text="0.00" /></span>
                </div>

                <div class="order-item">
                    <span class="order-item-label">Tax (10%):</span>
                    <span class="order-item-value">$<asp:Label ID="lblTax" runat="server" Text="10.00" /></span>
                </div>
            </div>

            <div class="total-section">
                <div class="total-row">
                    <span>Subtotal:</span>
                    <span>$<asp:Label ID="lblTotalSubtotal" runat="server" Text="100.00" /></span>
                </div>
                <div class="total-row">
                    <span>Discount:</span>
                    <span>- $<asp:Label ID="lblTotalDiscount" runat="server" Text="0.00" /></span>
                </div>
                <div class="total-row">
                    <span>Tax:</span>
                    <span>$<asp:Label ID="lblTotalTax" runat="server" Text="10.00" /></span>
                </div>
                <div class="total-row final">
                    <span>Total:</span>
                    <span>$<asp:Label ID="lblFinalTotal" runat="server" Text="110.00" /></span>
                </div>
            </div>

            <div class="payment-methods">
                <h3>Select Payment Method</h3>
                <button type="button" class="payment-btn" onclick="selectPaymentMethod('card')">
                    Credit/Debit Card
                </button>
                <button type="button" class="payment-btn" onclick="selectPaymentMethod('paypal')">
                    PayPal
                </button>
                <button type="button" class="payment-btn" onclick="selectPaymentMethod('cash')">
                    Cash on Delivery
                </button>
            </div>

            <asp:HiddenField ID="hdnRedemptionID" runat="server" />
            <asp:HiddenField ID="hdnPaymentMethod" runat="server" />

            <asp:Button ID="btnCompletePayment" runat="server" 
                Text="Complete Payment" 
                CssClass="btn-complete-payment"
                OnClick="btnCompletePayment_Click"
                Enabled="false" />
        </div>
    </div>

    <script type="text/javascript">
        function selectPaymentMethod(method) {
            // Remove selected class from all buttons
            var buttons = document.querySelectorAll('.payment-btn');
            buttons.forEach(function(btn) {
                btn.classList.remove('selected');
            });

            // Add selected class to clicked button
            event.target.classList.add('selected');

            // Enable complete payment button
            document.getElementById('<%= btnCompletePayment.ClientID %>').disabled = false;

            // Store selected method
            document.getElementById('<%= hdnPaymentMethod.ClientID %>').value = method;
        }
    </script>
</asp:Content>
