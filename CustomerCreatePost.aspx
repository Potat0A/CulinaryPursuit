<%@ Page Title="" Language="C#" MasterPageFile="~/Customer.Master" AutoEventWireup="true" CodeBehind="CustomerCreatePost.aspx.cs" Inherits="CulinaryPursuit.CustomerCreatePost" %>


<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <h3>Create Community Post</h3>

    <asp:Label ID="lblMessage" runat="server" CssClass="text-danger" />

    <div class="mb-3">
        <label>Food Photo</label>
        <asp:FileUpload ID="fuPhoto" runat="server" CssClass="form-control" />
    </div>

    <div class="mb-3">
        <label>Caption</label>
        <asp:TextBox ID="txtCaption" runat="server"
                     CssClass="form-control"
                     TextMode="MultiLine"
                     Rows="3" />
    </div>

    <asp:Button ID="btnPost" runat="server"
                Text="Post"
                CssClass="btn btn-primary"
                OnClick="btnPost_Click" />

</asp:Content>