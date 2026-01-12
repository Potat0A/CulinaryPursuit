<%@ Page Title="My Reviews"
    Language="C#"
    MasterPageFile="~/Customer.Master"
    AutoEventWireup="true"
    CodeBehind="CustomerMyReviews.aspx.cs"
    Inherits="CulinaryPursuit.CustomerMyReviews" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<div class="container mt-5">

    <h3 class="mb-4">📝 My Reviews</h3>

    <asp:Repeater ID="rptReviews" runat="server" OnItemCommand="rptReviews_ItemCommand">
        <ItemTemplate>
            <div class="card mb-4 shadow-sm">
                <div class="card-body">

                    <h5 class="fw-bold mb-1">
                        <%# Eval("RestaurantName") %>
                    </h5>

                    <small class="text-muted">
                        Reviewed on <%# Eval("CreatedAt", "{0:dd MMM yyyy}") %>
                    </small>

                    <hr />

                    <p>
                        ⭐ Overall: <%# Eval("Rating") %>/5 <br />
                        🍽 Taste: <%# Eval("TasteRating") %>/5 |
                        💰 Affordability: <%# Eval("AffordabilityRating") %>/5
                    </p>

                    <p class="border p-3 bg-light rounded">
                        <%# Eval("Comment") %>
                    </p>

                    <!-- CHEF REPLY -->
                    <asp:Panel runat="server"
                        Visible='<%# !string.IsNullOrEmpty(Eval("Reply").ToString()) %>'
                        CssClass="border-start border-4 border-success p-3 bg-white mt-3 rounded">
                        <strong>👨‍🍳 Chef Reply:</strong>
                        <p class="mb-0"><%# Eval("Reply") %></p>
                    </asp:Panel>

                    <div class="mt-3 text-end">
                        <asp:Button ID="btnEdit"
                            runat="server"
                            Text="✏️ Edit Review"
                            CssClass="btn btn-outline-primary btn-sm"
                            CommandName="Edit"
                            CommandArgument='<%# Eval("ReviewID") %>' />
                    </div>

                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <asp:Label ID="lblMessage"
        runat="server"
        CssClass="text-muted" />

</div>

</asp:Content>
