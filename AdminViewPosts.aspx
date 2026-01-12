<%@ Page
    Language="C#"
    MasterPageFile="~/admin.Master"
    AutoEventWireup="true"
    CodeBehind="AdminViewPosts.aspx.cs"
    Inherits="CulinaryPursuit.AdminViewPosts" %>

<asp:Content ID="HeadContent"
    ContentPlaceHolderID="HeadContent"
    runat="server">
    <title>Community Posts Management | Admin</title>
</asp:Content>

<asp:Content ID="MainContent"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <h3 class="mb-4">📢 Community Posts Management</h3>

    <asp:Button
        ID="btnBack"
        runat="server"
        Text="← Back to Dashboard"
        CssClass="btn btn-secondary mb-3"
        OnClick="btnBack_Click1" />

    <div class="card shadow-sm">
        <div class="card-body">

            <asp:GridView
                ID="gvPosts"
                runat="server"
                AutoGenerateColumns="False"
                CssClass="table table-striped table-bordered align-middle"
                DataKeyNames="PostID"
                OnRowCommand="gvPosts_RowCommand">

                <Columns>
                    <asp:BoundField HeaderText="Post ID" DataField="PostID" />
                    <asp:BoundField HeaderText="Customer Name" DataField="CustomerName" />
                    <asp:BoundField HeaderText="Caption" DataField="Caption" />

                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <asp:Image
                                ID="imgPost"
                                runat="server"
                                ImageUrl='<%# ResolveUrl(Eval("ImagePath").ToString()) %>'
                                CssClass="img-thumbnail"
                                Style="max-height:100px;" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:BoundField
                        HeaderText="Created At"
                        DataField="CreatedAt"
                        DataFormatString="{0:dd MMM yyyy}" />

                    <asp:TemplateField HeaderText="Action">
                        <ItemTemplate>
                            <asp:Button
                                ID="btnDelete"
                                runat="server"
                                CommandName="DeletePost"
                                CommandArgument='<%# Eval("PostID") %>'
                                Text="Delete"
                                CssClass="btn btn-sm btn-danger"
                                OnClientClick="return confirm('Are you sure you want to delete this post?');" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>

            </asp:GridView>

            <asp:Label
                ID="lblMessage"
                runat="server"
                CssClass="text-success mt-2 d-block" />

        </div>
    </div>

</asp:Content>
