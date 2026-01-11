<%@ Page Title="Checkout" Language="C#" MasterPageFile="~/Customer.Master" AutoEventWireup="true" CodeBehind="CustomerCheckout.aspx.cs" Inherits="CulinaryPursuit.CustomerCheckout" %>
<%-- Author: Henry --%>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        .checkout-container {
            padding: 40px 0;
        }

        .page-title {
            text-align: center;
            margin-bottom: 40px;
        }

        .page-title h1 {
            font-size: 2.5rem;
            font-weight: 900;
            background: linear-gradient(135deg, #ff3c00, #ff9a3c);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .cart-section, .payment-section {
            background: white;
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 20px;
            color: #333;
        }

        .cart-item {
            display: flex;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid #f0f0f0;
        }

        .cart-item:last-child {
            border-bottom: none;
        }

        .item-image {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 10px;
            margin-right: 20px;
            background: #f5f5f5;
        }

        .item-details {
            flex: 1;
        }

        .item-name {
            font-size: 1.1rem;
            font-weight: 700;
            color: #333;
        }

        .item-restaurant {
            color: #ff3c00;
            font-size: 0.9rem;
            margin-top: 5px;
        }

        .item-price {
            font-size: 1.2rem;
            font-weight: 700;
            color: #ff3c00;
            margin-right: 20px;
        }

        .quantity-control {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-right: 20px;
        }

        .qty-btn {
            width: 35px;
            height: 35px;
            border: 2px solid #ff3c00;
            background: white;
            color: #ff3c00;
            border-radius: 50%;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .qty-btn:hover {
            background: #ff3c00;
            color: white;
        }

        .qty-value {
            min-width: 40px;
            text-align: center;
            font-weight: 700;
            font-size: 1.1rem;
        }

        .btn-remove {
            background: #dc3545;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 20px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-remove:hover {
            background: #c82333;
            transform: scale(1.05);
        }

        .order-summary {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            margin-top: 20px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 1.1rem;
        }

        .summary-row.total {
            font-size: 1.5rem;
            font-weight: 900;
            color: #ff3c00;
            padding-top: 15px;
            border-top: 2px solid #dee2e6;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            font-weight: 600;
            margin-bottom: 8px;
            display: block;
            color: #333;
        }

        .form-control, .form-select {
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            padding: 12px;
            transition: all 0.3s ease;
        }

        .form-control:focus, .form-select:focus {
            border-color: #ff3c00;
            box-shadow: 0 0 0 0.2rem rgba(255,60,0,0.15);
        }

        .btn-checkout {
            background: linear-gradient(135deg, #ff3c00, #ff9a3c);
            color: white;
            border: none;
            padding: 15px 40px;
            border-radius: 25px;
            font-weight: 700;
            font-size: 1.2rem;
            width: 100%;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 20px;
        }

        .btn-checkout:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(255,60,0,0.4);
        }

        .empty-cart {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }

        .empty-cart i {
            font-size: 4rem;
            margin-bottom: 20px;
        }

        .btn-continue-shopping {
            background: white;
            color: #ff3c00;
            border: 2px solid #ff3c00;
            padding: 10px 30px;
            border-radius: 25px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            margin-top: 20px;
            transition: all 0.3s ease;
        }

        .btn-continue-shopping:hover {
            background: #ff3c00;
            color: white;
        }
    </style>

    <div class="checkout-container">
        <div class="container">
            <div class="page-title">
                <h1>🛒 Checkout</h1>
                <p class="lead">Review your order and complete payment</p>
            </div>

            <div class="row">
                <div class="col-lg-8">
                    <!-- CART ITEMS -->
                    <div class="cart-section">
                        <h2 class="section-title">Your Cart</h2>
                        <asp:Panel ID="pnlCartItems" runat="server">
                            <asp:Repeater ID="rptCart" runat="server" OnItemCommand="rptCart_ItemCommand">
                                <ItemTemplate>
                                    <div class="cart-item">
                                        <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("MenuItemName") %>' class="item-image" />
                                        <div class="item-details">
                                            <div class="item-name"><%# Eval("MenuItemName") %></div>
                                            <div class="item-restaurant">🏪 <%# Eval("RestaurantName") %></div>
                                            <div class="item-price">$<%# Eval("Price", "{0:F2}") %> each</div>
                                        </div>
                                        <div class="quantity-control">
                                            <asp:LinkButton runat="server" CssClass="qty-btn" CommandName="DecreaseQty" CommandArgument='<%# Eval("CartID") %>'>−</asp:LinkButton>
                                            <span class="qty-value"><%# Eval("Quantity") %></span>
                                            <asp:LinkButton runat="server" CssClass="qty-btn" CommandName="IncreaseQty" CommandArgument='<%# Eval("CartID") %>'>+</asp:LinkButton>
                                        </div>
                                        <div class="item-price">$<%# Eval("Subtotal", "{0:F2}") %></div>
                                        <asp:LinkButton runat="server" CssClass="btn-remove" CommandName="Remove" CommandArgument='<%# Eval("CartID") %>'>Remove</asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>

                        <asp:Panel ID="pnlEmptyCart" runat="server" Visible="false" CssClass="empty-cart">
                            <div>🛒</div>
                            <h3>Your cart is empty</h3>
                            <p>Add some delicious items to get started!</p>
                            <a href="CustomerOrdering.aspx" class="btn-continue-shopping">Browse Menu</a>
                        </asp:Panel>
                    </div>
                </div>

                <div class="col-lg-4">
                    <!-- PAYMENT SECTION -->
                    <asp:Panel ID="pnlPayment" runat="server">
                        <div class="payment-section">
                            <h2 class="section-title">Payment Details</h2>

                            <div class="form-group">
                                <label>Delivery Address</label>
                                <asp:TextBox ID="txtDeliveryAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" Placeholder="Enter your delivery address" />
                            </div>

                            <div class="form-group">
                                <label>Payment Method</label>
                                <asp:DropDownList ID="ddlPaymentMethod" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="CreditCard">💳 Credit Card</asp:ListItem>
                                    <asp:ListItem Value="DebitCard">💳 Debit Card</asp:ListItem>
                                    <asp:ListItem Value="PayNow">📱 PayNow</asp:ListItem>
                                    <asp:ListItem Value="GrabPay">🟢 GrabPay</asp:ListItem>
                                    <asp:ListItem Value="Cash">💵 Cash on Delivery</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="order-summary">
                                <div class="summary-row">
                                    <span>Subtotal:</span>
                                    <span>$<asp:Label ID="lblSubtotal" runat="server" Text="0.00" /></span>
                                </div>
                                <div class="summary-row">
                                    <span>Delivery Fee:</span>
                                    <span>$<asp:Label ID="lblDeliveryFee" runat="server" Text="5.00" /></span>
                                </div>
                                <div class="summary-row total">
                                    <span>Total:</span>
                                    <span>$<asp:Label ID="lblTotal" runat="server" Text="0.00" /></span>
                                </div>
                            </div>

                            <asp:Button ID="btnPlaceOrder" runat="server" Text="Place Order" CssClass="btn-checkout" OnClick="btnPlaceOrder_Click" />
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
