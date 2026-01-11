<%@ Page Title="Manage Rewards" Language="C#" MasterPageFile="~/admin.Master" AutoEventWireup="true" CodeBehind="AdminRewards.aspx.cs" Inherits="CulinaryPursuit.AdminRewards" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <style>
        .rewards-container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .card {
            background: white;
            padding: 25px;
            border-radius: 14px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.08);
            margin-bottom: 20px;
        }

        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .header-section h2 {
            font-weight: 800;
            color: #333;
            margin: 0;
        }

        .msg-ok { 
            color: #137333; 
            font-weight: 600; 
            padding: 10px;
            background: #e8f5e9;
            border-radius: 5px;
            margin-bottom: 15px;
        }
        .msg-err { 
            color: #d93025; 
            font-weight: 600; 
            padding: 10px;
            background: #ffebee;
            border-radius: 5px;
            margin-bottom: 15px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            font-weight: 600;
            margin-bottom: 5px;
            display: block;
        }

        .stock-info {
            font-size: 0.9rem;
            color: #666;
            font-style: italic;
        }

        .actions {
            margin-top: 20px;
            display: flex;
            gap: 10px;
        }

        .validation {
            color: #d93025;
            font-size: 12px;
        }

        /* Modal fixes */
        .modal {
            z-index: 1055;
        }

        .modal-backdrop {
            z-index: 1050;
        }

        .modal-dialog {
            z-index: 1055;
        }

        .modal-content {
            position: relative;
            z-index: 1056;
        }

        .modal-body input,
        .modal-body textarea {
            pointer-events: auto !important;
        }

        /* Fix for redemptions modal backdrop */
        #redemptionsModal {
            z-index: 1060;
        }

        #redemptionsModal .modal-dialog {
            z-index: 1061;
        }

        #redemptionsModal .modal-content {
            z-index: 1062;
        }

        .modal-backdrop {
            z-index: 1050;
        }

        .modal-backdrop.show {
            z-index: 1050;
        }
        

        .action-buttons-vertical {
            display: flex;
            flex-direction: column;
            gap: 5px;
            align-items: stretch;
        }

        .action-buttons-vertical .btn {
            width: 100%;
            margin: 0;
            white-space: nowrap;
        }
        
        /* Responsive Table Styles */
        .table-responsive-wrapper {
            width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
            margin-bottom: 20px;
        }
        
        .table-responsive-wrapper table {
            width: 100%;
            min-width: 1200px; /* Minimum width to prevent cramping */
            border-collapse: collapse;
        }
        
        .table-responsive-wrapper .table th,
        .table-responsive-wrapper .table td {
            padding: 12px 8px;
            vertical-align: middle;
            word-wrap: break-word;
            max-width: 200px;
        }
        
        .table-responsive-wrapper .table th {
            background-color: #f8f9fa;
            font-weight: 600;
            position: sticky;
            top: 0;
            z-index: 10;
        }
        
        /* Make specific columns more compact */
        .table-responsive-wrapper .table td:nth-child(1) { /* ID column */
            min-width: 50px;
            max-width: 60px;
            text-align: center;
        }
        
        .table-responsive-wrapper .table td:nth-child(2) { /* Name column */
            min-width: 120px;
            max-width: 200px;
        }
        
        .table-responsive-wrapper .table td:nth-child(3) { /* Description column */
            min-width: 150px;
            max-width: 300px;
        }
        
        .table-responsive-wrapper .table td:nth-child(4) { /* Points column */
            min-width: 80px;
            max-width: 100px;
            text-align: center;
        }
        
        .table-responsive-wrapper .table td:nth-child(5) { /* Category column */
            min-width: 100px;
            max-width: 120px;
        }
        
        .table-responsive-wrapper .table td:nth-child(6) { /* Discount/Voucher column */
            min-width: 100px;
            max-width: 120px;
        }
        
        .table-responsive-wrapper .table td:nth-child(7) { /* Partnering Stores column */
            min-width: 120px;
            max-width: 200px;
        }
        
        .table-responsive-wrapper .table td:nth-child(8) { /* Stock column */
            min-width: 70px;
            max-width: 100px;
            text-align: center;
        }
        
        .table-responsive-wrapper .table td:nth-child(9) { /* Available column */
            min-width: 80px;
            max-width: 100px;
            text-align: center;
        }
        
        .table-responsive-wrapper .table td:nth-child(10) { /* Expiry column */
            min-width: 150px;
            max-width: 200px;
        }
        
        .table-responsive-wrapper .table td:nth-child(11) { /* Image column */
            min-width: 120px;
            max-width: 150px;
            text-align: center;
        }
        
        .table-responsive-wrapper .table td:nth-child(12) { /* Redemptions column */
            min-width: 80px;
            max-width: 100px;
            text-align: center;
        }
        
        .table-responsive-wrapper .table td:last-child { /* Actions column */
            min-width: 100px;
            max-width: 120px;
        }
        
        /* Edit mode input fields */
        .table-responsive-wrapper .table input[type="text"],
        .table-responsive-wrapper .table input[type="number"],
        .table-responsive-wrapper .table textarea,
        .table-responsive-wrapper .table select {
            width: 100%;
            max-width: 100%;
            box-sizing: border-box;
            font-size: 0.9em;
        }
        
        .table-responsive-wrapper .table textarea {
            resize: vertical;
            min-height: 60px;
        }
        
        /* Responsive breakpoints */
        @media (max-width: 1400px) {
            .table-responsive-wrapper table {
                min-width: 1000px;
            }
        }
        
        @media (max-width: 1200px) {
            .rewards-container {
                padding: 0 10px;
            }
            
            .table-responsive-wrapper table {
                min-width: 900px;
            }
        }
        
        @media (max-width: 768px) {
            .table-responsive-wrapper {
                border: 1px solid #dee2e6;
                border-radius: 8px;
            }
            
            .table-responsive-wrapper table {
                min-width: 800px;
            }
            
            .table-responsive-wrapper .table th,
            .table-responsive-wrapper .table td {
                padding: 8px 6px;
                font-size: 0.85em;
            }
        }
    </style>

    <style>
        /* Pill Button Navigation - matching customer rewards style */
        .nav-tabs-pill {
            display: flex;
            justify-content: center;
            gap: 15px;
            flex-wrap: wrap;
            margin-bottom: 30px;
        }

        .pill-item {
            padding: 10px 25px;
            border-radius: 50px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.3s ease;
            font-size: 0.95rem;
            border: 2px solid #ff6b35;
        }

        .pill-item.active {
            background-color: #ff6b35;
            color: #ffffff;
        }

        .pill-item.inactive {
            background-color: #ffffff;
            color: #ff6b35;
        }

        .pill-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 107, 53, 0.3);
        }

        .admin-content-section {
            display: none;
        }

        .admin-content-section.active {
            display: block;
        }
    </style>

    <div class="rewards-container">
        <!-- Pill Button Navigation -->
        <nav class="nav-tabs-pill">
            <a href="AdminRewards.aspx" class="pill-item active" id="tabManage">
                Manage Rewards Store
            </a>
            <a href="AddReward.aspx" class="pill-item inactive" id="tabAdd">
                Add New Reward
            </a>
            <a href="AdminViewRedemptions.aspx" class="pill-item inactive" id="tabRedemptions">
                View All Redemptions
            </a>
        </nav>

        <!-- Manage Rewards Store Section -->
        <div id="sectionManage" class="admin-content-section active">
            <div class="card">
                <div class="header-section">
                    <h2>🏆 Manage Rewards Store</h2>
                </div>

                <asp:Label ID="lblStatus" runat="server" EnableViewState="false" />

            <div class="table-responsive-wrapper">
            <asp:GridView ID="gvRewards" runat="server"
                AutoGenerateColumns="false"
                DataKeyNames="RewardID"
                OnRowEditing="gvRewards_RowEditing"
                OnRowCancelingEdit="gvRewards_RowCancelingEdit"
                OnRowUpdating="gvRewards_RowUpdating"
                OnRowDeleting="gvRewards_RowDeleting"
                EmptyDataText="No rewards available. Click + Add New Reward to get started."
                GridLines="None"
                CssClass="table table-hover"
                HeaderStyle-CssClass="table-header"
                RowStyle-CssClass="table-row"
                EnableViewState="true"
                ViewStateMode="Enabled">

                <Columns>
                    <asp:BoundField DataField="RewardID" HeaderText="ID" ReadOnly="true" ItemStyle-Width="50px" />

                    <asp:TemplateField HeaderText="Name">
                        <ItemTemplate><%# Eval("Name") %></ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditName" runat="server"
                                Text='<%# Bind("Name") %>' 
                                MaxLength="200"
                                CssClass="form-control" />
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Description">
                        <ItemTemplate>
                            <div style="max-width: 300px; overflow: hidden; text-overflow: ellipsis;">
                                <%# Eval("Description") %>
                            </div>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditDescription" runat="server"
                                Text='<%# Bind("Description") %>' 
                                MaxLength="1000"
                                TextMode="MultiLine"
                                Rows="2"
                                CssClass="form-control" />
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Points Required">
                        <ItemTemplate><%# Eval("PointsRequired") %> pts</ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditPoints" runat="server"
                                Text='<%# Bind("PointsRequired") %>'
                                CssClass="form-control" 
                                style="width: 100px;" />
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Category">
                        <ItemTemplate><%# Eval("Category") == DBNull.Value || Eval("Category") == null ? "N/A" : Eval("Category") %></ItemTemplate>
                        <EditItemTemplate>
                            <asp:DropDownList ID="ddlEditCategory" runat="server" CssClass="form-control"
                                SelectedValue='<%# Bind("Category") %>'>
                                <asp:ListItem Value="">-- Select Category --</asp:ListItem>
                                <asp:ListItem Value="Discounts">Discounts</asp:ListItem>
                                <asp:ListItem Value="Vouchers">Vouchers</asp:ListItem>
                                <asp:ListItem Value="Free Items">Free Items</asp:ListItem>
                            </asp:DropDownList>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Discount/Voucher">
                        <ItemTemplate>
                            <%# FormatDiscountVoucherInfo(Eval("Category"), Eval("DiscountPercentage"), Eval("VoucherAmount")) %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditDiscountPercentage" runat="server" 
                                Text='<%# Eval("DiscountPercentage") == DBNull.Value ? "" : Eval("DiscountPercentage") %>'
                                CssClass="form-control edit-discount-percentage" 
                                TextMode="Number" 
                                min="0" 
                                max="100" 
                                step="0.01"
                                style="width: 100px; display: none;"
                                placeholder="%" />
                            <asp:TextBox ID="txtEditVoucherAmount" runat="server" 
                                Text='<%# Eval("VoucherAmount") == DBNull.Value ? "" : Eval("VoucherAmount") %>'
                                CssClass="form-control edit-voucher-amount" 
                                TextMode="Number" 
                                min="0" 
                                step="0.01"
                                style="width: 100px; display: none;"
                                placeholder="$" />
                            <span class="edit-discount-voucher-display">—</span>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Partnering Stores">
                        <ItemTemplate><%# Eval("PartneringStores") == DBNull.Value || Eval("PartneringStores") == null ? "N/A" : Eval("PartneringStores") %></ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditPartneringStores" runat="server"
                                Text='<%# Bind("PartneringStores") %>' 
                                MaxLength="200"
                                CssClass="form-control" />
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Stock">
                        <ItemTemplate>
                            <%# Eval("StockQuantity") == DBNull.Value ? "Unlimited" : Eval("StockQuantity").ToString() %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtEditStock" runat="server"
                                Text='<%# Eval("StockQuantity") == DBNull.Value ? "" : Eval("StockQuantity").ToString() %>'
                                CssClass="form-control" 
                                style="width: 100px;"
                                placeholder="Leave empty for unlimited" />
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Available">
                        <ItemTemplate>
                            <%# (bool)Eval("IsAvailable") ? "✅ Yes" : "❌ No" %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:CheckBox ID="chkEditAvailable"
                                runat="server"
                                Checked='<%# Bind("IsAvailable") %>' />
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Expiry">
                        <ItemTemplate>
                            <%# FormatExpiryInfo(Eval("ExpiryType"), Eval("ExpiryDate"), Eval("ExpiryTimespanValue"), Eval("ExpiryTimespanUnit")) %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <div style="min-width: 200px;">
                                <asp:DropDownList ID="ddlEditExpiryType" runat="server" CssClass="form-control edit-expiry-type-ddl" 
                                    style="margin-bottom: 5px; font-size: 0.9em;"
                                    data-expiry-type='<%# Eval("ExpiryType") != DBNull.Value && Eval("ExpiryType") != null ? Eval("ExpiryType").ToString() : "" %>'>
                                    <asp:ListItem Value="">No Expiry</asp:ListItem>
                                    <asp:ListItem Value="FixedDate">Fixed Date</asp:ListItem>
                                    <asp:ListItem Value="Timespan">Timespan</asp:ListItem>
                                </asp:DropDownList>
                                <asp:TextBox ID="txtEditExpiryDate" runat="server" 
                                    TextMode="Date" CssClass="form-control edit-expiry-date" 
                                    style="margin-bottom: 5px; font-size: 0.9em; display: none;"
                                    Text='<%# Eval("ExpiryDate") != DBNull.Value && Eval("ExpiryDate") != null ? ((DateTime)Eval("ExpiryDate")).ToString("yyyy-MM-dd") : "" %>' />
                                <div style="display: none; gap: 5px;" class="edit-expiry-timespan">
                                    <asp:TextBox ID="txtEditExpiryTimespanValue" runat="server" 
                                        TextMode="Number" min="1" max="365" CssClass="form-control" 
                                        style="width: 80px; font-size: 0.9em;"
                                        Text='<%# Eval("ExpiryTimespanValue") != DBNull.Value && Eval("ExpiryTimespanValue") != null ? Eval("ExpiryTimespanValue").ToString() : "" %>' />
                                    <asp:DropDownList ID="ddlEditExpiryTimespanUnit" runat="server" CssClass="form-control" 
                                        style="width: 100px; font-size: 0.9em;"
                                        data-expiry-unit='<%# Eval("ExpiryTimespanUnit") != DBNull.Value && Eval("ExpiryTimespanUnit") != null ? Eval("ExpiryTimespanUnit").ToString() : "" %>'>
                                        <asp:ListItem Value="Days">Days</asp:ListItem>
                                        <asp:ListItem Value="Weeks">Weeks</asp:ListItem>
                                        <asp:ListItem Value="Months">Months</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Image">
                        <ItemTemplate>
                            <%# GetImageDisplay(Eval("ImagePath")) %>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <div style="min-width: 150px;">
                                <%# GetImageDisplay(Eval("ImagePath")) %>
                                <asp:FileUpload ID="fuEditImage" runat="server" CssClass="form-control" 
                                    style="margin-top: 5px; font-size: 0.85em;"
                                    accept="image/jpeg,image/jpg,image/png,image/gif" />
                                <small style="font-size: 0.75em; color: #666; display: block; margin-top: 3px;">
                                    Leave empty to keep current image
                                </small>
                                <asp:CheckBox ID="chkRemoveImage" runat="server" 
                                    Text=" Remove image" 
                                    style="font-size: 0.75em; color: #d93025; margin-top: 5px; display: block;" />
                                <small style="font-size: 0.7em; color: #999; display: block; margin-top: 2px;">
                                    Check to remove current image
                                </small>
                            </div>
                        </EditItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Redemptions">
                        <ItemTemplate>
                            <asp:HyperLink ID="lnkViewRedemptions" runat="server" 
                                Text="View" 
                                CssClass="btn btn-sm btn-outline-info"
                                NavigateUrl='<%# "AdminViewRedemptions.aspx?rewardId=" + Eval("RewardID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Actions" ItemStyle-Width="100px">
                        <ItemTemplate>
                            <div class="action-buttons-vertical">
                                <asp:LinkButton ID="btnEdit" runat="server" 
                                    CommandName="Edit" 
                                    CssClass="btn btn-sm btn-outline-primary"
                                    Text="✏️ Edit"
                                    CausesValidation="false" />
                                <asp:LinkButton ID="btnDelete" runat="server" 
                                    CommandName="Delete" 
                                    CssClass="btn btn-sm btn-outline-danger"
                                    Text="🗑️ Delete"
                                    CausesValidation="false" />
                            </div>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <div class="action-buttons-vertical">
                                <asp:LinkButton ID="btnUpdate" runat="server" 
                                    CommandName="Update" 
                                    CssClass="btn btn-sm btn-outline-success"
                                    Text="💾 Save"
                                    CausesValidation="false" />
                                <asp:LinkButton ID="btnCancel" runat="server" 
                                    CommandName="Cancel" 
                                    CssClass="btn btn-sm btn-outline-secondary"
                                    Text="❌ Cancel"
                                    CausesValidation="false" />
                            </div>
                        </EditItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            </div>
            </div>
        </div>

        <!-- Redemptions Modal (keeping for backward compatibility - can be removed later) -->
        <div class="modal fade" id="redemptionsModal" tabindex="-1" aria-labelledby="redemptionsModalLabel" aria-hidden="true" runat="server" ClientIDMode="Static" data-bs-backdrop="true" data-bs-keyboard="true">
            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="redemptionsModalLabel">Reward Redemptions</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body" style="max-height: 70vh; overflow-y: auto;">
                        <asp:Label ID="lblRedemptionsStatus" runat="server" EnableViewState="false" />
                        <asp:GridView ID="gvRedemptions" runat="server"
                            AutoGenerateColumns="false"
                            DataKeyNames="RedemptionID"
                            OnRowDeleting="gvRedemptions_RowDeleting"
                            EmptyDataText="No redemptions found for this reward."
                            GridLines="None"
                            CssClass="table table-hover"
                            HeaderStyle-CssClass="table-header">
                            <Columns>
                                <asp:BoundField DataField="RedemptionID" HeaderText="ID" ReadOnly="true" ItemStyle-Width="50px" />
                                <asp:BoundField DataField="CustomerID" HeaderText="Customer ID" ReadOnly="true" />
                                <asp:BoundField DataField="PointsUsed" HeaderText="Points Used" ReadOnly="true" />
                                <asp:BoundField DataField="RedemptionDate" HeaderText="Redemption Date" 
                                    DataFormatString="{0:dd/MM/yyyy HH:mm}" ReadOnly="true" />
                                <asp:BoundField DataField="Status" HeaderText="Status" ReadOnly="true" />
                                <asp:BoundField DataField="ExpiryDate" HeaderText="Expiry Date" 
                                    DataFormatString="{0:dd/MM/yyyy}" 
                                    NullDisplayText="N/A" ReadOnly="true" />
                                <asp:CommandField ShowDeleteButton="true" ButtonType="Button"
                                    DeleteText="🗑️ Delete"
                                    ControlStyle-CssClass="btn btn-sm btn-outline-danger" />
                            </Columns>
                        </asp:GridView>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Add/Edit Reward Modal -->
        <div class="modal fade" id="rewardModal" tabindex="-1" aria-labelledby="rewardModalLabel" aria-hidden="true" runat="server" ClientIDMode="Static" data-bs-backdrop="true" data-bs-keyboard="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <asp:Label ID="lblModalTitle" runat="server" Text="Add New Reward" />
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Reward Name *</label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="200" />
                        </div>
                        <div class="form-group">
                            <label>Description</label>
                            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" 
                                TextMode="MultiLine" Rows="3" MaxLength="1000" />
                        </div>
                        <div class="form-group">
                            <label>Points Required *</label>
                            <asp:TextBox ID="txtPointsRequired" runat="server" CssClass="form-control" 
                                TextMode="Number" min="0" />
                            <small class="stock-info">Free Item can be 0, Discounts/Vouchers require minimum 1</small>
                        </div>
                        <div class="form-group">
                            <label>Category *</label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control" 
                                onchange="toggleCategoryFieldsModal();">
                                <asp:ListItem Value="">-- Select Category --</asp:ListItem>
                                <asp:ListItem Value="Discounts">Discounts</asp:ListItem>
                                <asp:ListItem Value="Vouchers">Vouchers</asp:ListItem>
                                <asp:ListItem Value="Free Items">Free Items</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-group" id="divDiscountPercentage" style="display: none;">
                            <label>Discount Percentage *</label>
                            <asp:TextBox ID="txtDiscountPercentage" runat="server" CssClass="form-control" 
                                TextMode="Number" min="0" max="100" step="0.01" />
                            <small class="stock-info">Enter the discount percentage (e.g., 10 for 10%)</small>
                        </div>
                        <div class="form-group" id="divVoucherAmount" style="display: none;">
                            <label>Voucher Amount *</label>
                            <asp:TextBox ID="txtVoucherAmount" runat="server" CssClass="form-control" 
                                TextMode="Number" min="0" step="0.01" />
                            <small class="stock-info">Enter the voucher amount (e.g., 10 for $10)</small>
                        </div>
                        <div class="form-group">
                            <label>Partnering Stores</label>
                            <asp:TextBox ID="txtPartneringStores" runat="server" CssClass="form-control" MaxLength="200" 
                                placeholder="e.g., Urban Bistro, Amy's Kitchen, Bakery 101" />
                        </div>
                        <div class="form-group">
                            <label>Stock Quantity</label>
                            <asp:TextBox ID="txtStockQuantity" runat="server" CssClass="form-control" 
                                TextMode="Number" min="0" />
                            <small class="stock-info">Leave empty for unlimited stock</small>
                        </div>
                        <div class="form-group">
                            <label>Expiry Type</label>
                            <asp:DropDownList ID="ddlExpiryType" runat="server" CssClass="form-control" 
                                AutoPostBack="true" OnSelectedIndexChanged="ddlExpiryType_SelectedIndexChanged">
                                <asp:ListItem Value="">No Expiry</asp:ListItem>
                                <asp:ListItem Value="FixedDate">Fixed Date</asp:ListItem>
                                <asp:ListItem Value="Timespan">Timespan (from redemption)</asp:ListItem>
                            </asp:DropDownList>
                            <small class="stock-info">Choose how the reward expires</small>
                        </div>
                        <div class="form-group" id="divExpiryDate" runat="server" style="display:none;">
                            <label>Expiry Date</label>
                            <asp:TextBox ID="txtExpiryDate" runat="server" CssClass="form-control" 
                                TextMode="Date" />
                            <small class="stock-info">Fixed expiry date (e.g., 31/03/2026)</small>
                        </div>
                        <div class="form-group" id="divExpiryMonths" runat="server" style="display:none;">
                            <label>Expiry Timespan</label>
                            <div style="display: flex; gap: 10px; align-items: center;">
                                <asp:TextBox ID="txtExpiryTimespanValue" runat="server" CssClass="form-control" 
                                    TextMode="Number" min="1" max="365" style="width: 100px;" placeholder="Value" />
                                <asp:DropDownList ID="ddlExpiryTimespanUnit" runat="server" CssClass="form-control" 
                                    style="width: 120px;">
                                    <asp:ListItem Value="Days" Text="Day(s)" />
                                    <asp:ListItem Value="Weeks" Text="Week(s)" Selected="True" />
                                    <asp:ListItem Value="Months" Text="Month(s)" />
                                </asp:DropDownList>
                            </div>
                            <small class="stock-info">Time from redemption date until expiry (e.g., 30 Days, 2 Weeks, 3 Months)</small>
                        </div>
                        <div class="form-group">
                            <asp:CheckBox ID="chkIsAvailable" runat="server" Checked="true" Text="Available" />
                        </div>
                        <asp:HiddenField ID="hdnRewardID" runat="server" Value="0" />
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnSaveReward" runat="server" Text="Save Reward" 
                            CssClass="btn btn-primary" OnClick="btnSaveReward_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        // Function to show modal - called from code-behind
        function showRewardModal() {
            var modalElement = document.getElementById('rewardModal');
            if (modalElement) {
                var modal = new bootstrap.Modal(modalElement, {
                    backdrop: true,
                    keyboard: true,
                    focus: true
                });
                modal.show();
                
                // Focus on first input after modal is shown
                modalElement.addEventListener('shown.bs.modal', function () {
                    var firstInput = modalElement.querySelector('input[type="text"], input[type="number"], textarea');
                    if (firstInput) {
                        firstInput.focus();
                    }
                }, { once: true });
            }
        }

        // Function to hide modal - called from code-behind
        function hideRewardModal() {
            var modalElement = document.getElementById('rewardModal');
            if (modalElement) {
                var modal = bootstrap.Modal.getInstance(modalElement);
                if (modal) {
                    modal.hide();
                }
            }
        }

        // Function to show redemptions modal - called from code-behind
        function showRedemptionsModal() {
            var modalElement = document.getElementById('redemptionsModal');
            if (modalElement) {
                // Remove any existing backdrops first
                var existingBackdrops = document.querySelectorAll('.modal-backdrop');
                existingBackdrops.forEach(function(backdrop) {
                    backdrop.remove();
                });
                
                // Remove modal-open class from body if present
                document.body.classList.remove('modal-open');
                document.body.style.overflow = '';
                document.body.style.paddingRight = '';
                
                // Check if Bootstrap is available
                if (typeof bootstrap !== 'undefined' && bootstrap.Modal) {
                    // Dispose of any existing modal instance
                    var existingModal = bootstrap.Modal.getInstance(modalElement);
                    if (existingModal) {
                        existingModal.dispose();
                    }
                    
                    var modal = new bootstrap.Modal(modalElement, {
                        backdrop: true,
                        keyboard: true,
                        focus: true
                    });
                    modal.show();
                } else {
                    // Fallback: show modal manually
                    modalElement.style.display = 'block';
                    modalElement.classList.add('show');
                    modalElement.setAttribute('aria-hidden', 'false');
                    modalElement.setAttribute('aria-modal', 'true');
                    
                    // Create backdrop
                    var backdrop = document.createElement('div');
                    backdrop.className = 'modal-backdrop fade show';
                    backdrop.style.zIndex = '1050';
                    document.body.appendChild(backdrop);
                    document.body.classList.add('modal-open');
                }
            } else {
                console.error('Redemptions modal element not found');
                alert('Modal element not found. Please refresh the page.');
            }
        }
        
        // Also make it available globally for code-behind calls
        window.showRedemptionsModal = showRedemptionsModal;
        
        // Clean up when modal is hidden
        document.addEventListener('DOMContentLoaded', function() {
            var redemptionsModal = document.getElementById('redemptionsModal');
            if (redemptionsModal) {
                redemptionsModal.addEventListener('hidden.bs.modal', function() {
                    // Clean up any lingering backdrops
                    var backdrops = document.querySelectorAll('.modal-backdrop');
                    backdrops.forEach(function(backdrop) {
                        backdrop.remove();
                    });
                    document.body.classList.remove('modal-open');
                    document.body.style.overflow = '';
                    document.body.style.paddingRight = '';
                });
            }
        });

        // Handle modal backdrop click to close
        document.addEventListener('DOMContentLoaded', function () {
            var modalElement = document.getElementById('rewardModal');
            if (modalElement) {
                modalElement.addEventListener('hidden.bs.modal', function () {
                    // Clear form when modal is closed
                    var form = modalElement.querySelector('form') || modalElement;
                    if (form) {
                        form.reset();
                    }
                });
            }
            
            // Handle expiry type change
            var ddlExpiryType = document.getElementById('<%= ddlExpiryType.ClientID %>');
            if (ddlExpiryType) {
                ddlExpiryType.addEventListener('change', function() {
                    updateExpiryFields();
                });
                updateExpiryFields(); // Initial call
            }
        });
        
        function updateExpiryFields() {
            var ddlExpiryType = document.getElementById('<%= ddlExpiryType.ClientID %>');
            var divExpiryDate = document.getElementById('<%= divExpiryDate.ClientID %>');
            var divExpiryMonths = document.getElementById('<%= divExpiryMonths.ClientID %>');
            
            if (ddlExpiryType && divExpiryDate && divExpiryMonths) {
                var selectedValue = ddlExpiryType.value;
                if (selectedValue === 'FixedDate') {
                    divExpiryDate.style.display = 'block';
                    divExpiryMonths.style.display = 'none';
                } else if (selectedValue === 'Timespan') {
                    divExpiryDate.style.display = 'none';
                    divExpiryMonths.style.display = 'block';
                } else {
                    divExpiryDate.style.display = 'none';
                    divExpiryMonths.style.display = 'none';
                }
            }
        }
        // Function to toggle expiry fields in GridView edit mode
        function toggleExpiryEditFields(ddl) {
            var row = ddl.closest('tr');
            if (!row) return;
            
            var dateField = row.querySelector('.edit-expiry-date');
            var timespanDiv = row.querySelector('.edit-expiry-timespan');
            
            if (!dateField || !timespanDiv) return;
            
            if (ddl.value === 'FixedDate') {
                dateField.style.display = 'block';
                timespanDiv.style.display = 'none';
            } else if (ddl.value === 'Timespan') {
                dateField.style.display = 'none';
                timespanDiv.style.display = 'flex';
            } else {
                dateField.style.display = 'none';
                timespanDiv.style.display = 'none';
            }
        }
        
        // Function to toggle discount/voucher fields in GridView edit mode
        function toggleDiscountVoucherEditFields(categoryDdl) {
            var row = categoryDdl.closest('tr');
            if (!row) return;
            
            var discountInput = row.querySelector('.edit-discount-percentage');
            var voucherInput = row.querySelector('.edit-voucher-amount');
            var displaySpan = row.querySelector('.edit-discount-voucher-display');
            
            if (!discountInput || !voucherInput || !displaySpan) return;
            
            var selectedCategory = categoryDdl.value;
            
            if (selectedCategory === 'Discounts') {
                discountInput.style.display = 'block';
                voucherInput.style.display = 'none';
                displaySpan.style.display = 'none';
                voucherInput.value = '';
            } else if (selectedCategory === 'Vouchers') {
                discountInput.style.display = 'none';
                voucherInput.style.display = 'block';
                displaySpan.style.display = 'none';
                discountInput.value = '';
            } else {
                discountInput.style.display = 'none';
                voucherInput.style.display = 'none';
                displaySpan.style.display = 'inline';
                discountInput.value = '';
                voucherInput.value = '';
            }
        }
        
        // Function to initialize edit mode fields (called after GridView enters edit mode)
        function initializeEditModeFields() {
            // Initialize category dropdowns for discount/voucher fields
            var categoryDdls = document.querySelectorAll('select[id*="ddlEditCategory"]');
            categoryDdls.forEach(function(categoryDdl) {
                toggleDiscountVoucherEditFields(categoryDdl);
                categoryDdl.addEventListener('change', function() {
                    toggleDiscountVoucherEditFields(categoryDdl);
                });
            });
            
            // Initialize expiry dropdowns
            var expiryDdls = document.querySelectorAll('.edit-expiry-type-ddl');
            expiryDdls.forEach(function(ddl) {
                var expiryType = ddl.getAttribute('data-expiry-type');
                if (expiryType) {
                    for (var i = 0; i < ddl.options.length; i++) {
                        if (ddl.options[i].value === expiryType) {
                            ddl.selectedIndex = i;
                            break;
                        }
                    }
                }
                toggleExpiryEditFields(ddl);
                ddl.addEventListener('change', function() {
                    toggleExpiryEditFields(ddl);
                });
            });
        }
        
        // Initialize expiry fields when GridView enters edit mode
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize all expiry dropdowns
            var expiryDdls = document.querySelectorAll('.edit-expiry-type-ddl');
            expiryDdls.forEach(function(ddl) {
                // Set initial value from data attribute
                var expiryType = ddl.getAttribute('data-expiry-type');
                if (expiryType) {
                    for (var i = 0; i < ddl.options.length; i++) {
                        if (ddl.options[i].value === expiryType) {
                            ddl.selectedIndex = i;
                            break;
                        }
                    }
                }
                
                // Set timespan unit
                var row = ddl.closest('tr');
                if (row) {
                    var unitDdl = row.querySelector('select[id*="ddlEditExpiryTimespanUnit"]');
                    if (unitDdl) {
                        var unit = unitDdl.getAttribute('data-expiry-unit');
                        if (unit) {
                            for (var j = 0; j < unitDdl.options.length; j++) {
                                if (unitDdl.options[j].value === unit) {
                                    unitDdl.selectedIndex = j;
                                    break;
                                }
                            }
                        }
                    }
                }
                
                // Toggle fields based on initial value
                toggleExpiryEditFields(ddl);
                
                // Add change event listener
                ddl.addEventListener('change', function() {
                    toggleExpiryEditFields(ddl);
                });
            });
            
            // Initialize category dropdowns for discount/voucher fields
            var categoryDdls = document.querySelectorAll('select[id*="ddlEditCategory"]');
            categoryDdls.forEach(function(categoryDdl) {
                var row = categoryDdl.closest('tr');
                if (row) {
                    // Initial toggle based on current selection
                    toggleDiscountVoucherEditFields(categoryDdl);
                    
                    // Attach change event
                    categoryDdl.addEventListener('change', function() {
                        toggleDiscountVoucherEditFields(categoryDdl);
                    });
                }
            });
        });
        
        function toggleCategoryFieldsModal() {
            var categoryDdl = document.getElementById('<%= ddlCategory.ClientID %>');
            var discountDiv = document.getElementById('divDiscountPercentage');
            var voucherDiv = document.getElementById('divVoucherAmount');
            var discountInput = document.getElementById('<%= txtDiscountPercentage.ClientID %>');
            var voucherInput = document.getElementById('<%= txtVoucherAmount.ClientID %>');
            var pointsInput = document.getElementById('<%= txtPointsRequired.ClientID %>');

            if (!categoryDdl) return;

            var selectedCategory = categoryDdl.value;

            if (selectedCategory === 'Discounts') {
                if (discountDiv) discountDiv.style.display = 'block';
                if (voucherDiv) voucherDiv.style.display = 'none';
                if (voucherInput) voucherInput.value = '';
            } else if (selectedCategory === 'Vouchers') {
                if (discountDiv) discountDiv.style.display = 'none';
                if (voucherDiv) voucherDiv.style.display = 'block';
                if (discountInput) discountInput.value = '';
            } else if (selectedCategory === 'Free Items') {
                if (discountDiv) discountDiv.style.display = 'none';
                if (voucherDiv) voucherDiv.style.display = 'none';
                if (discountInput) discountInput.value = '';
                if (voucherInput) voucherInput.value = '';
                // Free Items: points can be 0 or any value, don't force to 0
            } else {
                if (discountDiv) discountDiv.style.display = 'none';
                if (voucherDiv) voucherDiv.style.display = 'none';
                if (discountInput) discountInput.value = '';
                if (voucherInput) voucherInput.value = '';
            }
        }
        
        // Initialize category fields when modal opens
        document.addEventListener('DOMContentLoaded', function() {
            var categoryDdl = document.getElementById('<%= ddlCategory.ClientID %>');
            if (categoryDdl) {
                categoryDdl.addEventListener('change', toggleCategoryFieldsModal);
                toggleCategoryFieldsModal(); // Initial call
            }

        });

    </script>

</asp:Content>
