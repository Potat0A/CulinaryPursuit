<%@ Page Title="" Language="C#" MasterPageFile="~/chef.Master" AutoEventWireup="true" CodeBehind="ChefViewReviews.aspx.cs" Inherits="CulinaryPursuit.ChefViewReviews" %>


<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <h3 class="mb-4">Customer Reviews</h3>

    <asp:GridView ID="gvReviews" runat="server"
        AutoGenerateColumns="False"
        CssClass="table table-striped table-bordered"
        DataKeyNames="ReviewID">

        <Columns>
            <asp:BoundField HeaderText="Overall" DataField="Rating" />
            <asp:BoundField HeaderText="Taste" DataField="TasteRating" />
            <asp:BoundField HeaderText="Affordability" DataField="AffordabilityRating" />
            <asp:BoundField HeaderText="Review" DataField="Comment" />
            <asp:TemplateField HeaderText="Status">
                <ItemTemplate>
                    <asp:Label ID="lblStatus" runat="server"
                        Text='<%# Eval("Reply") == DBNull.Value || string.IsNullOrEmpty(Eval("Reply").ToString()) ? "Not Replied" : "Replied" %>'
                        CssClass='<%# Eval("Reply") == DBNull.Value || string.IsNullOrEmpty(Eval("Reply").ToString()) ? "badge bg-warning text-dark" : "badge bg-success" %>'>
                    </asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Action">
                <ItemTemplate>
                    <asp:Button ID="btnReply" runat="server"
                        Text='<%# Eval("Reply") == DBNull.Value || string.IsNullOrEmpty(Eval("Reply").ToString()) ? "Reply" : "Replied" %>'
                        CssClass="btn btn-primary btn-sm"
                        Enabled='<%# Eval("Reply") == DBNull.Value || string.IsNullOrEmpty(Eval("Reply").ToString()) %>'
                        PostBackUrl='<%# "ChefReplyReview.aspx?ReviewID=" + Eval("ReviewID") %>' />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

</asp:Content>




