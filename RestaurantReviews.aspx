<%@ Page Title="Leave a Review"
    Language="C#"
    MasterPageFile="~/Customer.Master"
    AutoEventWireup="true"
    CodeBehind="RestaurantReviews.aspx.cs"
    Inherits="CulinaryPursuit.RestaurantReviews" %>

<asp:Content ID="Content1"
    ContentPlaceHolderID="ContentPlaceHolder1"
    runat="server">

<script type="text/javascript">
    function confirmLogin() {
        if (confirm("You must be logged in to submit a review. Go to login page?")) {
            window.location.href = "Login.aspx";
        }
        return false;
    }
</script>

<div class="container mt-5">

    <!-- RESTAURANT INFO -->
    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <div class="row align-items-center">
                <div class="col-md-2">
                    <asp:Image ID="imgLogo"
                        runat="server"
                        CssClass="img-fluid rounded"
                        Style="max-height:120px;" />
                </div>

                <div class="col-md-10">
                    <h3 class="fw-bold mb-1">
                        <asp:Label ID="lblRestaurantName" runat="server" />
                    </h3>

                    <p class="mb-1 text-muted">
                        👨‍🍳 <asp:Label ID="lblChefName" runat="server" />
                    </p>

                    <p class="mb-1">
                        📍 <asp:Label ID="lblPhone" runat="server" />
                    </p>

                    <p class="mb-1">
                        📍 <asp:Label ID="lblOpeningHours" runat="server" />
                    </p>
                    <p class="mb-1">
                        📍 <asp:Label ID="lblAddress" runat="server" />
                    </p>

                    <p class="mb-1">
                        ⭐ <asp:Label ID="lblAverageRating" runat="server" /> / 5
                    </p>

                    <p class="mb-0 text-muted">
                        <asp:Label ID="lblDescription" runat="server" />
                    </p>
                </div>
            </div>
        </div>
    </div>

    <!-- EXISTING REVIEWS -->
    <h5 class="mb-3">Customer Reviews</h5>

    <asp:Repeater ID="rptReviews" runat="server">
        <ItemTemplate>
            <div class="card mb-3">
                <div class="card-body">
                    <h6>Overall: <%# Eval("Rating") %>/5</h6>

                    <p>
                        <strong>Taste:</strong> <%# Eval("TasteRating") %>/5 |
                        <strong>Affordability:</strong> <%# Eval("AffordabilityRating") %>/5
                    </p>

                    <p><%# Eval("Comment") %></p>

                    <small class="text-muted">
                        <%# Eval("CreatedAt", "{0:dd MMM yyyy}") %>
                        — <%# Eval("CustomerName") %>
                    </small>

                    <asp:Panel runat="server"
                        Visible='<%# !string.IsNullOrEmpty(Eval("Reply").ToString()) %>'
                        CssClass="mt-2 p-2 bg-light border rounded">
                        <strong>Chef Reply:</strong> <%# Eval("Reply") %>
                    </asp:Panel>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <hr />

    <!-- ADD REVIEW -->
    <h5 class="mb-3">Leave a Review</h5>

    <div class="row mb-3">
        <div class="col-md-4">
            <label>Overall Rating</label>
            <asp:DropDownList ID="ddlOverall" runat="server" CssClass="form-select">
                <asp:ListItem>1</asp:ListItem>
                <asp:ListItem>2</asp:ListItem>
                <asp:ListItem>3</asp:ListItem>
                <asp:ListItem>4</asp:ListItem>
                <asp:ListItem>5</asp:ListItem>
            </asp:DropDownList>
        </div>

        <div class="col-md-4">
            <label>Taste</label>
            <asp:DropDownList ID="ddlTaste" runat="server" CssClass="form-select">
                <asp:ListItem>1</asp:ListItem>
                <asp:ListItem>2</asp:ListItem>
                <asp:ListItem>3</asp:ListItem>
                <asp:ListItem>4</asp:ListItem>
                <asp:ListItem>5</asp:ListItem>
            </asp:DropDownList>
        </div>

        <div class="col-md-4">
            <label>Affordability</label>
            <asp:DropDownList ID="ddlAffordability" runat="server" CssClass="form-select">
                <asp:ListItem>1</asp:ListItem>
                <asp:ListItem>2</asp:ListItem>
                <asp:ListItem>3</asp:ListItem>
                <asp:ListItem>4</asp:ListItem>
                <asp:ListItem>5</asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>

    <asp:TextBox ID="txtComment"
        runat="server"
        CssClass="form-control mb-3"
        TextMode="MultiLine"
        Rows="4"
        placeholder="Share your experience..." />

    <asp:Button ID="btnSubmitReview"
        runat="server"
        Text="Submit Review"
        CssClass="btn btn-primary"
        OnClick="btnSubmitReview_Click" />

    <asp:Label ID="lblMessage"
        runat="server"
        CssClass="d-block mt-3 text-success" />

</div>
</asp:Content>
