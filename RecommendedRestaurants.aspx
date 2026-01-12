<%@ Page Title="" Language="C#" MasterPageFile="~/Customer.Master" AutoEventWireup="true" CodeBehind="RecommendedRestaurants.aspx.cs" Inherits="CulinaryPursuit.RecommendedRestaurants" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <h3 class="mb-4">🍽️ Recommended Restaurants For You</h3>




    <asp:Literal ID="litWeather" runat="server" />

    <asp:Repeater ID="rptRestaurants" runat="server" OnItemCommand="rptRestaurants_ItemCommand">
        <ItemTemplate>
            <div class="card mb-3 shadow-sm">
                <div class="row g-0">
                    <div class="col-md-4">
                        <asp:Image ID="imgRestaurant" runat="server"
                                   ImageUrl='<%# GetBannerImage(Eval("Banner")) %>'
                                   CssClass="img-fluid rounded-start"
                                   Style="height:200px; width:100%; object-fit:cover;" />

                    </div>
                    <div class="col-md-8">
                        <div class="card-body">
                            <h5 class="card-title"><%# Eval("Name") %></h5>
                            <p class="card-text mb-1"><strong>Chef:</strong> <%# Eval("ChefName") %></p>
                            <p class="card-text mb-1"><strong>Rating:</strong> <%# Eval("Rating") %> ⭐</p>
                            <p class="card-text mb-1"><strong>Description:</strong> <%# Eval("Description") %></p>
                            <asp:Button
                                ID="btnAddToCart"
                                runat="server"
                                Text="Add to Cart 🛒"
                                CssClass="btn btn-success btn-sm mt-2"
                                CommandName="AddToCart"
                                CommandArgument='<%# Eval("MenuItemID") %>'
                                Enabled='<%# Eval("MenuItemID") != DBNull.Value && (bool)Eval("IsAvailable") %>' />

                        </div>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

</asp:Content>