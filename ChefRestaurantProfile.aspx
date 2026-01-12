<%@ Page Title="Restaurant Profile"
    Language="C#"
    MasterPageFile="~/Chef.Master"
    AutoEventWireup="true"
    CodeBehind="ChefRestaurantProfile.aspx.cs"
    Inherits="CulinaryPursuit.ChefRestaurantProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
.restaurant-banner {
    position: relative;
    width: 100%;
    height: 280px;
    border-radius: 12px;
    overflow: hidden;
    background-color: #eee;
}

.banner-img {
    width: 100%;
    height: 100%;
    object-fit: cover; /* KEY */
    display: block;
}

.banner-overlay {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    padding: 20px;
    background: linear-gradient(
        to top,
        rgba(0,0,0,0.6),
        rgba(0,0,0,0)
    );
    color: white;
}

.banner-overlay h2 {
    margin: 0;
    font-weight: 800;
}

.banner-overlay p {
    margin: 4px 0 0;
    font-size: 0.95rem;
    opacity: 0.9;
}

</style>

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

                <h5 class="mt-4">⏰ Opening Hours</h5>

                <asp:Repeater ID="rptOpeningHours" runat="server">
                    <ItemTemplate>
                        <div class="row align-items-center mb-2">
                            <div class="col-md-2 fw-bold">
                                <%# Eval("Day") %>
                            </div>

                            <div class="col-md-2">
                                <asp:CheckBox ID="chkClosed"
                                              runat="server"
                                              Text="Closed"
                                              Checked='<%# Eval("Closed") %>' />
                            </div>

                            <div class="col-md-4">
                                <asp:TextBox ID="txtOpen"
                                             runat="server"
                                             CssClass="form-control"
                                             Text='<%# Eval("Open") %>'
                                             placeholder="09:00" />
                            </div>

                            <div class="col-md-4">
                                <asp:TextBox ID="txtClose"
                                             runat="server"
                                             CssClass="form-control"
                                             Text='<%# Eval("Close") %>'
                                             placeholder="18:00" />
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

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
            <!-- RESTAURANT BANNER -->
            <div class="restaurant-banner mb-4">
                <asp:Image ID="imgBanner" runat="server" CssClass="banner-img" />
                <div class="banner-overlay">
                    <h2><asp:Label ID="lblBannerName" runat="server" /></h2>
                    <p><asp:Label ID="lblBannerCuisine" runat="server" /></p>
                </div>
            </div>



            <asp:Button ID="btnSave"
                runat="server"
                Text="💾 Save Changes"
                CssClass="btn btn-primary"
                OnClick="btnSave_Click" />

        </div>
    </div>

</asp:Content>
