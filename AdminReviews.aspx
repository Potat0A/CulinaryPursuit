<%@ Page Language="C#" 
    MasterPageFile="~/admin.Master"
    AutoEventWireup="true"
    CodeBehind="AdminReviews.aspx.cs"
    Inherits="CulinaryPursuit.AdminReviews" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-title {
            font-weight: 800;
            color: #333;
        }

        .card-admin {
            background: white;
            border-radius: 18px;
            box-shadow: 0 8px 30px rgba(0,0,0,0.08);
            padding: 25px;
        }

        .gridview th {
            background: #ff8c42;
            color: white;
            text-align: center;
            vertical-align: middle;
        }

        .gridview td {
            vertical-align: middle;
        }

        .review-text {
            max-width: 300px;
            white-space: normal;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- PAGE HEADER -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3 class="page-title">📝 Manage Customer Reviews</h3>

        <asp:Button ID="btnBack"
            runat="server"
            Text="← Back to Dashboard"
            CssClass="btn btn-outline-secondary"
            OnClick="btnBack_Click" />
    </div>

    <!-- CARD WRAPPER -->
    <div class="card-admin">

        <asp:GridView ID="gvReviews"
            runat="server"
            AutoGenerateColumns="False"
            DataKeyNames="ReviewID"
            CssClass="table table-hover table-bordered gridview"
            OnRowDeleting="gvReviews_RowDeleting">

            <Columns>

                <asp:BoundField HeaderText="Restaurant"
                    DataField="RestaurantName" />

                <asp:BoundField HeaderText="Customer"
                    DataField="CustomerName" />

                <asp:BoundField HeaderText="Phone"
                    DataField="Phone" />

                <asp:BoundField HeaderText="Overall ⭐"
                    DataField="Rating" />

                <asp:BoundField HeaderText="Taste ⭐"
                    DataField="TasteRating" />

                <asp:BoundField HeaderText="Affordability ⭐"
                    DataField="AffordabilityRating" />

                <asp:TemplateField HeaderText="Review">
                    <ItemTemplate>
                        <div class="review-text">
                            <%# Eval("Comment") %>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="Date"
                    DataField="CreatedAt"
                    DataFormatString="{0:dd MMM yyyy}" />

                <asp:TemplateField HeaderText="Action">
                    <ItemTemplate>
                        <asp:Button ID="btnDelete"
                            runat="server"
                            Text="Delete"
                            CssClass="btn btn-danger btn-sm"
                            CommandName="Delete"
                            OnClientClick="return confirm('Are you sure you want to delete this review?');" />
                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>
        </asp:GridView>

        <asp:Label ID="lblMessage"
            runat="server"
            CssClass="text-success fw-semibold mt-3 d-block" />

    </div>

</asp:Content>
