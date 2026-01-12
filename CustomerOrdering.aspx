<%@ Page Title="Order Food" Language="C#" MasterPageFile="~/Customer.Master" AutoEventWireup="true" CodeBehind="CustomerOrdering.aspx.cs" Inherits="CulinaryPursuit.CustomerOrdering" %>
<%-- Author: Henry --%>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        .hero-section {
            background: linear-gradient(135deg, #ff3c00, #ff9a3c);
            padding: 60px 0;
            color: white;
            text-align: center;
        }

        .hero-section h1 {
            font-size: 3rem;
            font-weight: 900;
            margin-bottom: 20px;
        }

        .cart-badge {
            position: fixed;
            top: 100px;
            right: 30px;
            z-index: 999;
            background: #ff3c00;
            color: white;
            padding: 20px;
            border-radius: 50%;
            width: 70px;
            height: 70px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 25px rgba(255,60,0,0.4);
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .cart-badge:hover {
            transform: scale(1.1);
            box-shadow: 0 12px 35px rgba(255,60,0,0.6);
        }

        .cart-count {
            font-size: 1.5rem;
            font-weight: 900;
        }

        .filters-section {
            background: white;
            padding: 30px;
            margin: 30px 0;
            border-radius: 20px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }

        .filter-group {
            margin-bottom: 20px;
        }

        .filter-group label {
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
            display: block;
        }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 30px;
            margin: 30px 0;
        }

        .menu-card {
            background: white;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            transition: all 0.3s ease;
        }

        .menu-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
        }

        .menu-image {
            width: 100%;
            height: 200px;
            object-fit: cover;
            background: linear-gradient(135deg, #f5f5f5, #e0e0e0);
        }

        .menu-content {
            padding: 20px;
        }

        .menu-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: #333;
            margin-bottom: 10px;
        }

        .restaurant-name {
            color: #ff3c00;
            font-weight: 600;
            margin-bottom: 10px;
            font-size: 0.9rem;
        }

        .menu-description {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 15px;
            height: 40px;
            overflow: hidden;
        }

        .menu-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
        }

        .price {
            font-size: 1.5rem;
            font-weight: 900;
            color: #ff3c00;
        }

        .btn-add-cart {
            background: linear-gradient(135deg, #ff3c00, #ff9a3c);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-add-cart:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(255,60,0,0.4);
        }

        .badge-category {
            display: inline-block;
            background: rgba(255,60,0,0.1);
            color: #ff3c00;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .no-results {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }

        .no-results i {
            font-size: 4rem;
            margin-bottom: 20px;
        }

        .search-box {
            position: relative;
        }

        .search-box input {
            padding-left: 40px;
        }

        .search-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
        }

        .recommend-section {
            margin: 80px 0 40px;
            text-align: center;
            padding: 50px 30px;
            border-radius: 30px;
            background: linear-gradient(135deg, #fff5ee, #fff);
            box-shadow: 0 10px 35px rgba(0,0,0,0.08);
        }

        .recommend-title {
            font-size: 2.2rem;
            font-weight: 900;
            color: #ff3c00;
            margin-bottom: 15px;
        }

        .recommend-text {
            color: #666;
            font-size: 1.05rem;
            max-width: 650px;
            margin: 0 auto 30px;
        }

        .btn-recommend {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            padding: 16px 36px;
            font-size: 1.15rem;
            font-weight: 800;
            color: white;
            background: linear-gradient(135deg, #ff3c00, #ff9a3c);
            border-radius: 40px;
            text-decoration: none;
            box-shadow: 0 10px 30px rgba(255,60,0,0.45);
            transition: all 0.35s ease;
        }

        .btn-recommend:hover {
            transform: translateY(-4px) scale(1.05);
            box-shadow: 0 18px 45px rgba(255,60,0,0.6);
            color: white;
        }

    </style>

    <!-- FLOATING CART BUTTON -->
    <a href="CustomerCheckout.aspx" class="cart-badge">
        <div>🛒</div>
        <div class="cart-count">
            <asp:Label ID="lblCartCount" runat="server" Text="0" />
        </div>
    </a>

    <!-- HERO SECTION -->
    <div class="hero-section">
        <div class="container">
            <h1>🍽️ Order Delicious Food</h1>
            <p class="lead">Browse from our amazing selection of dishes from top restaurants</p>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <div class="container">
        <!-- FILTERS -->
        <div class="filters-section">
            <div class="row align-items-end">
                <div class="col-md-4">
                    <div class="filter-group">
                        <label>🔍 Search</label>
                        <div class="search-box">
                            <span class="search-icon">🔍</span>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" Placeholder="Search dishes..." />
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="filter-group">
                        <label>🏪 Restaurant</label>
                        <asp:DropDownList ID="ddlRestaurant" runat="server" CssClass="form-select">
                            <asp:ListItem Value="">All Restaurants</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="filter-group">
                        <label>🍜 Cuisine Type</label>
                        <asp:DropDownList ID="ddlCuisine" runat="server" CssClass="form-select">
                            <asp:ListItem Value="">All Cuisines</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="col-md-2">
                    <asp:Button ID="btnFilter" runat="server" Text="Apply Filters" CssClass="btn btn-add-cart w-100" OnClick="btnFilter_Click" />
                </div>
            </div>
        </div>

        <!-- MENU ITEMS GRID -->
        <div class="menu-grid">
            <asp:Repeater ID="rptMenuItems" runat="server" OnItemCommand="rptMenuItems_ItemCommand">
                <ItemTemplate>
                    <div class="menu-card">
                        <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("Name") %>' class="menu-image" />
                        <div class="menu-content">
                            <div class="badge-category"><%# Eval("Category") %></div>
                            <div class="menu-title"><%# Eval("Name") %></div>
                            <div class="restaurant-name">🏪 <%# Eval("RestaurantName") %></div>
                            <div class="menu-description"><%# Eval("Description") %></div>
                            <div class="menu-footer">
                                <div class="price">$<%# Eval("Price", "{0:F2}") %></div>
                                <asp:Button
                                    ID="btnAddToCart"
                                    runat="server"
                                    Text="Add to Cart"
                                    CssClass="btn-add-cart"
                                    CommandName="AddToCart"
                                    CommandArgument='<%# Eval("MenuItemID") %>'
                                    Enabled='<%# (bool)Eval("IsAvailable") %>' />
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- NO RESULTS MESSAGE -->
        <asp:Panel ID="pnlNoResults" runat="server" Visible="false" CssClass="no-results">
            <div class="no-results">
                <i>🍽️</i>
                <h3>No menu items found</h3>
                <p>Try adjusting your filters or search terms</p>
            </div>
        </asp:Panel>

        <!-- PERSONALIZED RECOMMENDATIONS CTA -->
        <div class="recommend-section">
            <h2 class="recommend-title">✨ Not sure what to eat?</h2>
            <p class="recommend-text">
                Let us recommend restaurants and dishes just for you based on your preferences,
                past orders, and trending favourites.
            </p>

            <a href="RecommendedRestaurants.aspx" class="btn-recommend">
                🎯 Find Restaurants For Me
            </a>
        </div>

    </div>
</asp:Content>
