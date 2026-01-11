<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/Chef.Master"
    CodeBehind="ChefMenu.aspx.cs"
    Inherits="CulinaryPursuit.ChefMenu" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .menu-container {
            max-width: 1100px;
            margin: 20px auto;
        }

        .card {
            background: white;
            padding: 20px;
            border-radius: 14px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.08);
        }

        .actions {
            margin-top: 16px;
            display: flex;
            justify-content: flex-end;
        }

        .msg-ok { color:#137333; font-weight:600; }
        .msg-err { color:#d93025; font-weight:600; }
    </style>

    <div class="menu-container">

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h2 style="font-weight:800;">🍽️ My Menu</h2>

            <asp:Button ID="btnGoAdd"
                runat="server"
                Text="+ Add Item"
                CssClass="btn btn-primary"
                CausesValidation="false"
                OnClick="btnGoAdd_Click" />
        </div>

        <asp:Label ID="lblStatus" runat="server" EnableViewState="false" />

        <div class="card mt-3">
            <asp:GridView ID="gvMenu" runat="server"
                AutoGenerateColumns="false"
                DataKeyNames="MenuItemID"
                OnRowEditing="gvMenu_RowEditing"
                OnRowCancelingEdit="gvMenu_RowCancelingEdit"
                OnRowUpdating="gvMenu_RowUpdating"
                OnRowDeleting="gvMenu_RowDeleting"
                EmptyDataText="No menu items yet. Click + Add Item to get started."
                GridLines="None"
                CssClass="table table-hover">

                <Columns>
                    <asp:BoundField DataField="MenuItemID" HeaderText="ID" ReadOnly="true" />

                    <asp:TemplateField HeaderText="Name">
                        <ItemTemplate><%# Eval("Name") %></ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditName" runat="server"
                                Text='<%# Bind("Name") %>' MaxLength="200"
                                CssClass="form-control" />
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Category">
                        <ItemTemplate><%# Eval("Category") %></ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditCategory" runat="server"
                                Text='<%# Bind("Category") %>' MaxLength="100"
                                CssClass="form-control" />
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Price">
                        <ItemTemplate>S$ <%# Eval("Price", "{0:0.00}") %></ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditPrice" runat="server"
                                Text='<%# Bind("Price", "{0:0.00}") %>'
                                CssClass="form-control" />
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Available">
                        <ItemTemplate>
                            <%# (bool)Eval("IsAvailable") ? "Yes" : "No" %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:CheckBox ID="chkEditAvailable"
                                runat="server"
                                Checked='<%# Bind("IsAvailable") %>' />
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:CommandField ShowEditButton="true" />
                    <asp:CommandField ShowDeleteButton="true" />
                </Columns>
            </asp:GridView>
        </div>

    </div>

</asp:Content>
