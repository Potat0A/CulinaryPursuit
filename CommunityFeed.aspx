<%@ Page Title="" Language="C#" MasterPageFile="~/Customer.Master"
    AutoEventWireup="true" CodeBehind="CommunityFeed.aspx.cs"
    Inherits="CulinaryPursuit.CommunityFeed" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<h3>Community Feed</h3>

<asp:Repeater ID="rptPosts" runat="server" OnItemCommand="rptPosts_ItemCommand">
    <ItemTemplate>
        <div class="card mb-4">
            <div class="card-body">

                <!-- Post Header -->
                <h6>
                    <%# Eval("CustomerName") %>
                    <small class="text-muted">• <%# Eval("CreatedAt", "{0:dd MMM yyyy}") %></small>
                </h6>

                <!-- Post Image -->
                <asp:Image ID="imgPost" runat="server"
                    ImageUrl='<%# ResolveUrl(Eval("ImagePath").ToString()) %>'
                    CssClass="img-fluid rounded mb-2"
                    Style="max-height:400px;" />

                <!-- Caption -->
                <p><%# Eval("Caption") %></p>

                <!-- Likes -->
                <asp:Button ID="btnLike"
                    runat="server"
                    CommandName="Like"
                    CommandArgument='<%# Eval("PostID") %>'
                    Text='<%# (bool)Eval("IsLiked") ? "Unlike ❤️" : "Like ❤️" %>'
                    CssClass="btn btn-sm btn-outline-danger" />

                <span class="ms-2">
                    <%# Eval("LikeCount") %> likes
                </span>

                <hr />

                <!-- Comments Toggle -->
                <p>
                    <a class="btn btn-sm btn-outline-secondary"
                       data-bs-toggle="collapse"
                       href='#comments<%# Eval("PostID") %>'>
                        Show Comments (<%# GetCommentCount(Eval("Comments")) %>)
                    </a>
                </p>

                <div class="collapse" id="comments<%# Eval("PostID") %>">
                    <div class="mt-2 border p-2 rounded bg-light">
                        <asp:Repeater ID="rptComments" runat="server"
                            DataSource='<%# Eval("Comments") %>'>
                            <ItemTemplate>
                                <p class="mb-1">
                                    <strong><%# Eval("CustomerName") %>:</strong>
                                    <%# Eval("Comment") %>
                                </p>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <!-- Add Comment -->
                <asp:TextBox ID="txtComment" runat="server"
                    CssClass="form-control mb-2"
                    placeholder="Write a comment..." />

                <asp:Button ID="btnComment"
                    runat="server"
                    CommandName="Comment"
                    CommandArgument='<%# Eval("PostID") %>'
                    Text="Comment"
                    CssClass="btn btn-sm btn-primary" />

            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>

<!-- ✅ SINGLE Add Post Button at the bottom -->
<div class="text-center my-5">
    <asp:Button
        ID="btnAddPost"
        runat="server"
        Text="➕ Add a New Post"
        CssClass="btn btn-lg btn-primary"
        OnClick="btnAddPost_Click" />
</div>

</asp:Content>
