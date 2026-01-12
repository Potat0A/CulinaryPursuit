<%@ Page Title="" Language="C#" MasterPageFile="~/chef.Master" AutoEventWireup="true" CodeBehind="ChefReplyReview.aspx.cs" Inherits="CulinaryPursuit.ChefReplyReview" %>


<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <h3 class="mb-4">Reply to Review</h3>

    <div class="card p-4 mb-4">
        <p><strong>Customer Name:</strong> <asp:Label ID="lblCustomerName" runat="server" /></p>
        <p><strong>Phone:</strong> <asp:Label ID="lblPhone" runat="server" /></p>
        <p><strong>Overall:</strong> <asp:Label ID="lblOverall" runat="server" /></p>
        <p><strong>Taste:</strong> <asp:Label ID="lblTaste" runat="server" /></p>
        <p><strong>Affordability:</strong> <asp:Label ID="lblAffordability" runat="server" /></p>
        <p><strong>Review:</strong></p>
        <p class="border p-3 bg-light">
            <asp:Label ID="lblComment" runat="server" />
        </p>
    </div>

    <div class="mb-3">
        <label class="form-label fw-semibold">Your Reply</label>
        <asp:TextBox ID="txtReply" runat="server"
                     CssClass="form-control"
                     TextMode="MultiLine"
                     Rows="4" />
    </div>

    <asp:Button ID="btnSubmitReply" runat="server"
                Text="Submit Reply"
                CssClass="btn btn-success"
                OnClick="btnSubmitReply_Click" />

    <asp:Label ID="lblMessage" runat="server"
               CssClass="d-block mt-3 fw-semibold" />

</asp:Content>