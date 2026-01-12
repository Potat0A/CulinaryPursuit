<%@ Page Title="Edit Review"
    Language="C#"
    MasterPageFile="~/Customer.Master"
    AutoEventWireup="true"
    CodeBehind="EditReview.aspx.cs"
    Inherits="CulinaryPursuit.EditReview" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<div class="container mt-5">
    <h3 class="mb-4">✏️ Edit Your Review</h3>

    <div class="card p-4 shadow-sm">

        <label>Overall Rating</label>
        <asp:DropDownList ID="ddlOverall" runat="server" CssClass="form-select mb-3">
            <asp:ListItem>1</asp:ListItem>
            <asp:ListItem>2</asp:ListItem>
            <asp:ListItem>3</asp:ListItem>
            <asp:ListItem>4</asp:ListItem>
            <asp:ListItem>5</asp:ListItem>
        </asp:DropDownList>

        <label>Taste</label>
        <asp:DropDownList ID="ddlTaste" runat="server" CssClass="form-select mb-3">
            <asp:ListItem>1</asp:ListItem>
            <asp:ListItem>2</asp:ListItem>
            <asp:ListItem>3</asp:ListItem>
            <asp:ListItem>4</asp:ListItem>
            <asp:ListItem>5</asp:ListItem>
        </asp:DropDownList>

        <label>Affordability</label>
        <asp:DropDownList ID="ddlAffordability" runat="server" CssClass="form-select mb-3">
            <asp:ListItem>1</asp:ListItem>
            <asp:ListItem>2</asp:ListItem>
            <asp:ListItem>3</asp:ListItem>
            <asp:ListItem>4</asp:ListItem>
            <asp:ListItem>5</asp:ListItem>
        </asp:DropDownList>

        <label>Comment</label>
        <asp:TextBox ID="txtComment"
            runat="server"
            CssClass="form-control mb-3"
            TextMode="MultiLine"
            Rows="4" />

        <asp:Button ID="btnSave"
            runat="server"
            Text="💾 Save Changes"
            CssClass="btn btn-primary"
            OnClick="btnSave_Click" />

        <asp:Label ID="lblMessage"
            runat="server"
            CssClass="d-block mt-3 fw-semibold" />

    </div>
</div>

</asp:Content>
