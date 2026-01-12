<%@ Page Language="C#" MasterPageFile="~/Customer.Master" AutoEventWireup="true"
CodeBehind="ReviewPrompt.aspx.cs" Inherits="CulinaryPursuit.ReviewPrompt" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container mt-5 text-center">
        <h3>⭐ Enjoyed your meal?</h3>
        <p>Your feedback helps chefs improve!</p>

        <asp:Button ID="btnYes" runat="server"
                    Text="Leave a Review"
                    CssClass="btn btn-primary me-2"
                    OnClick="btnYes_Click" />

        <asp:Button ID="btnNo" runat="server"
                    Text="Maybe Later"
                    CssClass="btn btn-secondary"
                    OnClick="btnNo_Click" />
    </div>
</asp:Content>