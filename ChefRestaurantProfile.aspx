<%@ Page Title="Restaurant Profile"
    Language="C#"
    MasterPageFile="~/Chef.Master"
    AutoEventWireup="true"
    CodeBehind="ChefRestaurantProfile.aspx.cs"
    Inherits="CulinaryPursuit.ChefRestaurantProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h3 class="mb-4">🏪 Restaurant Profile</h3>

    <asp:Label ID="lblMessage" runat="server" CssClass="fw-bold" />

    <div class="card shadow-sm">
        <div class="card-body">

            <div class="mb-3">
                <label class="form-label">Restaurant Name</label>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" />
            </div>

            <div class="mb-3">
                <label class="form-label">Chef Name</label>
                <asp:TextBox ID="txtChefName" runat="server" CssClass="form-control" />
            </div>

            <div class="mb-3">
                <label class="form-label">Cuisine Type</label>
                <asp:TextBox ID="txtCuisine" runat="server" CssClass="form-control" />
            </div>

            <div class="mb-3">
                <label class="form-label">Description</label>
                <asp:TextBox ID="txtDescription" runat="server"
                    CssClass="form-control"
                    TextMode="MultiLine"
                    Rows="4" />
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                </div>

                <div class="col-md-6 mb-3">
                    <label class="form-label">Opening Hours</label>
                    <asp:TextBox ID="txtOpeningHours" runat="server" CssClass="form-control" />
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label">Address</label>
                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" />
            </div>

            <div class="mb-3">
                <label class="form-label">Restaurant Logo</label>
                <asp:FileUpload ID="fuLogo" runat="server" CssClass="form-control" />
            </div>

            <div class="mb-3">
                <label class="form-label">Restaurant Banner</label>
                <asp:FileUpload ID="fuBanner" runat="server" CssClass="form-control" />
            </div>

            <asp:Image ID="imgLogo" runat="server" CssClass="img-thumbnail mb-3" Width="150" />
            <asp:Image ID="imgBanner" runat="server" CssClass="img-fluid mb-3" />


            <asp:Button ID="btnSave"
                runat="server"
                Text="💾 Save Changes"
                CssClass="btn btn-primary"
                OnClick="btnSave_Click" />

        </div>
    </div>

</asp:Content>
