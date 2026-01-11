<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/Chef.Master"
    CodeBehind="AddMenuItem.aspx.cs"
    Inherits="CulinaryPursuit.AddMenuItem" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .form-container {
            max-width: 900px;
            margin: 20px auto;
        }

        .card {
            background: white;
            padding: 20px;
            border-radius: 14px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.08);
        }

        .row-flex {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .field {
            flex: 1;
            min-width: 240px;
        }

        .field label {
            font-weight: 600;
            margin-bottom: 6px;
            display: block;
        }

        .validation {
            color: #d93025;
            font-size: 12px;
        }

        .actions {
            margin-top: 16px;
            display: flex;
            gap: 10px;
        }

        .msg-ok { color:#137333; font-weight:600; }
        .msg-err { color:#d93025; font-weight:600; }
    </style>

    <div class="form-container">

        <h2 style="font-weight:800;">➕ Add Menu Item</h2>
        <p class="text-muted">Fill in the details below to add a new dish.</p>

        <asp:Label ID="lblStatus" runat="server" EnableViewState="false" />

        <div class="card">

            <asp:ValidationSummary ID="ValidationSummary1"
                runat="server"
                CssClass="validation mb-3" />

            <div class="row-flex">
                <div class="field">
                    <label>Name *</label>
                    <asp:TextBox ID="txtName" runat="server" MaxLength="200" CssClass="form-control" />
                    <asp:RequiredFieldValidator runat="server"
                        ControlToValidate="txtName"
                        ErrorMessage="Name is required."
                        CssClass="validation" />
                </div>

                <div class="field">
                    <label>Category *</label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select">
                        <asp:ListItem Text="-- Select --" Value="" />
                        <asp:ListItem Text="Appetizer" />
                        <asp:ListItem Text="Main" />
                        <asp:ListItem Text="Dessert" />
                        <asp:ListItem Text="Drink" />
                        <asp:ListItem Text="Special" />
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator runat="server"
                        ControlToValidate="ddlCategory"
                        InitialValue=""
                        ErrorMessage="Category is required."
                        CssClass="validation" />
                </div>

                <div class="field">
                    <label>Price (S$) *</label>
                    <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control" />
                    <asp:RequiredFieldValidator runat="server"
                        ControlToValidate="txtPrice"
                        ErrorMessage="Price is required."
                        CssClass="validation" />
                    <asp:RangeValidator runat="server"
                        ControlToValidate="txtPrice"
                        Type="Double"
                        MinimumValue="0.50"
                        MaximumValue="9999"
                        ErrorMessage="Price must be between 0.50 and 9999."
                        CssClass="validation" />
                </div>
            </div>

            <div class="row-flex mt-3">
                <div class="field">
                    <label>Description</label>
                    <asp:TextBox ID="txtDescription" runat="server"
                        TextMode="MultiLine" Rows="3"
                        MaxLength="1000" CssClass="form-control" />
                </div>

                <div class="field">
                    <label>Dish Image (optional)</label>
                    <asp:FileUpload ID="fuImage" runat="server" CssClass="form-control" />
                    <small class="text-muted">Accepted formats: JPG, PNG (max 5MB)</small>
                </div>

            </div>

            <div class="row-flex mt-3">
                <div class="field">
                    <label>Spicy Level (0–5)</label>
                    <asp:TextBox ID="txtSpicy" runat="server" Text="0" CssClass="form-control" />
                    <asp:RangeValidator runat="server"
                        ControlToValidate="txtSpicy"
                        Type="Integer" MinimumValue="0" MaximumValue="5"
                        ErrorMessage="Spicy level must be 0–5."
                        CssClass="validation" />
                </div>

                <div class="field">
                    <label>Prep Time (minutes)</label>
                    <asp:TextBox ID="txtPrepTime" runat="server" CssClass="form-control" />
                </div>

                <div class="field">
                    <label>Options</label>
                    <asp:CheckBox ID="chkAvailable" runat="server" Text=" Available" Checked="true" /><br />
                    <asp:CheckBox ID="chkVegetarian" runat="server" Text=" Vegetarian" /><br />
                    <asp:CheckBox ID="chkVegan" runat="server" Text=" Vegan" /><br />
                    <asp:CheckBox ID="chkHalal" runat="server" Text=" Halal" />
                </div>
            </div>

            <div class="actions">
                <asp:Button ID="btnSave" runat="server"
                    Text="Save Item"
                    CssClass="btn btn-primary"
                    OnClick="btnSave_Click" />

                <asp:Button ID="btnBack" runat="server"
                    Text="Back to Menu"
                    CssClass="btn btn-secondary"
                    CausesValidation="false"
                    OnClick="btnBack_Click" />
            </div>

        </div>
    </div>

</asp:Content>
