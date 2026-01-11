<%@ Page Title="Restaurant Approvals" Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="AdminApproval.aspx.cs" Inherits="CulinaryPursuit.AdminApproval" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>

        .header-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }

        .header-title {
            font-size: 2rem;
            font-weight: 800;
            color: #f76b1c;
            margin-bottom: 10px;
        }

        .stats-bar {
            display: flex;
            gap: 20px;
            margin-top: 20px;
            flex-wrap: wrap;
        }

        .stat-badge {
            background: linear-gradient(135deg, #f76b1c, #ff9f4d);
            color: white;
            padding: 15px 30px;
            border-radius: 15px;
            font-weight: 700;
            font-size: 1.1rem;
            box-shadow: 0 5px 15px rgba(247,107,28,0.3);
        }

        .application-card {
            background: white;
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .application-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.25);
        }

        .application-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 5px;
            height: 100%;
            background: linear-gradient(135deg, #f76b1c, #ff9f4d);
        }

        .chef-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .chef-name {
            font-size: 1.8rem;
            font-weight: 800;
            color: #333;
            margin-bottom: 5px;
        }

        .restaurant-name {
            font-size: 1.3rem;
            color: #f76b1c;
            font-weight: 600;
        }

        .pending-badge {
            background: #ffc107;
            color: #333;
            padding: 8px 20px;
            border-radius: 50px;
            font-weight: 700;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .info-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 12px;
            border-left: 4px solid #f76b1c;
        }

        .info-label {
            font-size: 0.85rem;
            color: #6c757d;
            font-weight: 600;
            margin-bottom: 5px;
            text-transform: uppercase;
        }

        .info-value {
            font-size: 1.1rem;
            color: #333;
            font-weight: 600;
        }

        .story-section {
            background: #fff9f0;
            border: 2px dashed #f76b1c;
            border-radius: 15px;
            padding: 20px;
            margin: 20px 0;
        }

        .story-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #f76b1c;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .story-text {
            font-size: 1rem;
            line-height: 1.7;
            color: #555;
            font-style: italic;
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 25px;
            flex-wrap: wrap;
        }

        .btn-approve {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
            border: none;
            padding: 14px 35px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 1.05rem;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 6px 20px rgba(40,167,69,0.3);
        }

        .btn-approve:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(40,167,69,0.5);
        }

        .btn-reject {
            background: linear-gradient(135deg, #dc3545, #c82333);
            color: white;
            border: none;
            padding: 14px 35px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 1.05rem;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 6px 20px rgba(220,53,69,0.3);
        }

        .btn-reject:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(220,53,69,0.5);
        }

        .btn-back {
            background: #6c757d;
            color: white;
            padding: 12px 30px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 700;
            display: inline-block;
            transition: all 0.3s ease;
        }

        .btn-back:hover {
            background: #5a6268;
            color: white;
            transform: translateY(-2px);
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        }

        .empty-state-icon {
            font-size: 5rem;
            margin-bottom: 20px;
        }

        .empty-state-text {
            font-size: 1.5rem;
            color: #6c757d;
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .chef-header {
                flex-direction: column;
            }

            .info-grid {
                grid-template-columns: 1fr;
            }

            .action-buttons {
                flex-direction: column;
            }

            .btn-approve, .btn-reject {
                width: 100%;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Header -->
    <div class="header-card">
                <h1 class="header-title">👨‍🍳 Chef Applications</h1>
                <p style="color: #6c757d; font-size: 1.1rem;">Review and approve home chef registrations</p>
                
                <div class="stats-bar">
                    <div class="stat-badge">⏳ Pending: <asp:Label ID="lblPendingCount" runat="server" /></div>
                    <div class="stat-badge">✅ Approved Today: <asp:Label ID="lblApprovedToday" runat="server" /></div>
                </div>

                <div style="margin-top: 20px;">
                    <a href="AdminDashboard.aspx" class="btn-back">← Back to Dashboard</a>
                </div>
            </div>

            <!-- Applications List -->
            <asp:Repeater ID="rptApplications" runat="server" OnItemCommand="rptApplications_ItemCommand">
                <ItemTemplate>
                    <div class="application-card">
                        <div class="chef-header">
                            <div>
                                <div class="chef-name">👨‍🍳 <%# Eval("ChefName") %></div>
                                <div class="restaurant-name">🍽️ <%# Eval("Name") %></div>
                            </div>
                            <span class="pending-badge">⏳ Pending Review</span>
                        </div>

                        <div class="info-grid">
                            
                            <div class="info-item">
                                <div class="info-label">📱 Phone</div>
                                <div class="info-value"><%# Eval("Phone") %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">🍳 Cuisine Type</div>
                                <div class="info-value"><%# Eval("CuisineType") %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">📅 Applied On</div>
                                <div class="info-value"><%# Eval("CreatedDate", "{0:MMM dd, yyyy}") %></div>
                            </div>
                        </div>

                        <div class="info-item" style="margin-bottom: 20px;">
                            <div class="info-label">📍 Address</div>
                            <div class="info-value"><%# Eval("Address") %></div>
                        </div>

                        <!-- Chef Story Section -->
                        <div class="story-section">
                            <div class="story-title">
                                <span>📖</span>
                                <span>Chef's Story</span>
                            </div>
                            <div class="story-text">
                                <%# string.IsNullOrEmpty(Eval("ChefStory").ToString()) 
                                    ? "No story provided yet." 
                                    : Eval("ChefStory") %>
                            </div>
                        </div>

                        <div class="action-buttons">
                            <asp:Button ID="btnApprove" runat="server" 
                                        CssClass="btn-approve" 
                                        Text="✅ Approve Chef" 
                                        CommandName="Approve" 
                                        CommandArgument='<%# Eval("RestaurantID") %>'
                                        OnClientClick="return confirm('Approve this chef application?');" />
                            
                            <asp:Button ID="btnReject" runat="server" 
                                        CssClass="btn-reject" 
                                        Text="❌ Reject Application" 
                                        CommandName="Reject" 
                                        CommandArgument='<%# Eval("RestaurantID") %>'
                                        OnClientClick="return confirm('Reject this application? This cannot be undone.');" />
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

    <!-- Empty State -->
    <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty-state" Visible="false">
        <div class="empty-state-icon">🎉</div>
        <div class="empty-state-text">All caught up! No pending applications.</div>
        <p style="color: #6c757d; margin-top: 15px;">Check back later for new chef registrations.</p>
    </asp:Panel>
</asp:Content>