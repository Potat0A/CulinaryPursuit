<%@ Page Language="C#" AutoEventWireup="true"
    MasterPageFile="~/admin.Master"
    CodeBehind="AddReward.aspx.cs"
    Inherits="CulinaryPursuit.AddReward" %>

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
        }

        .header-section {
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }

        .header-section h2 {
            margin: 0;
            color: #333;
            font-weight: 700;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            font-weight: 600;
            margin-bottom: 6px;
            display: block;
            color: #333;
        }

        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.95rem;
        }

        .validation {
            color: #d93025;
            font-size: 12px;
        }

        .actions {
            margin-top: 25px;
            display: flex;
            gap: 10px;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background-color: #ff6b35;
            color: white;
        }

        .btn-primary:hover {
            background-color: #e55a2b;
        }

        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #5a6268;
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

        .stock-info {
            font-size: 0.9rem;
            color: #666;
            font-style: italic;
            display: block;
            margin-top: 5px;
        }

        /* Pill Button Navigation - matching AdminRewards style */
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
    </style>

    <script type="text/javascript">
        function toggleCategoryFieldsAdd() {
            var categoryDdl = document.getElementById('<%= ddlAddCategory.ClientID %>');
            var discountDiv = document.getElementById('divAddDiscountPercentage');
            var voucherDiv = document.getElementById('divAddVoucherAmount');
            var discountInput = document.getElementById('<%= txtAddDiscountPercentage.ClientID %>');
            var voucherInput = document.getElementById('<%= txtAddVoucherAmount.ClientID %>');

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
            } else {
                if (discountDiv) discountDiv.style.display = 'none';
                if (voucherDiv) voucherDiv.style.display = 'none';
                if (discountInput) discountInput.value = '';
                if (voucherInput) voucherInput.value = '';
            }
        }

        function toggleExpiryFieldsAdd() {
            var expiryDdl = document.getElementById('<%= ddlAddExpiryType.ClientID %>');
            var dateDiv = document.getElementById('divAddExpiryDate');
            var timespanDiv = document.getElementById('divAddExpiryTimespan');

            if (!expiryDdl || !dateDiv || !timespanDiv) return;

            var selectedValue = expiryDdl.value;
            if (selectedValue === 'FixedDate') {
                dateDiv.style.display = 'block';
                timespanDiv.style.display = 'none';
            } else if (selectedValue === 'Timespan') {
                dateDiv.style.display = 'none';
                timespanDiv.style.display = 'block';
            } else {
                dateDiv.style.display = 'none';
                timespanDiv.style.display = 'none';
            }
        }

        // Image preview function
        function previewImageAdd(input) {
            var preview = document.getElementById('imagePreviewAdd');
            var previewImg = document.getElementById('previewImgAdd');
            
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                
                reader.onload = function(e) {
                    previewImg.src = e.target.result;
                    preview.style.display = 'block';
                };
                
                reader.readAsDataURL(input.files[0]);
            } else {
                preview.style.display = 'none';
                previewImg.src = '';
            }
        }

        // Initialize fields on page load
        document.addEventListener('DOMContentLoaded', function() {
            var addCategoryDdl = document.getElementById('<%= ddlAddCategory.ClientID %>');
            if (addCategoryDdl) {
                addCategoryDdl.addEventListener('change', toggleCategoryFieldsAdd);
                toggleCategoryFieldsAdd(); // Initial call
            }

            var addExpiryDdl = document.getElementById('<%= ddlAddExpiryType.ClientID %>');
            if (addExpiryDdl) {
                addExpiryDdl.addEventListener('change', toggleExpiryFieldsAdd);
                toggleExpiryFieldsAdd(); // Initial call
            }
        });
    </script>

    <div class="rewards-container">
        <!-- Pill Button Navigation -->
        <nav class="nav-tabs-pill">
            <a href="AdminRewards.aspx" class="pill-item inactive" id="tabManage">
                Manage Rewards Store
            </a>
            <a href="AddReward.aspx" class="pill-item active" id="tabAdd">
                Add New Reward
            </a>
            <a href="AdminViewRedemptions.aspx" class="pill-item inactive" id="tabRedemptions">
                View All Redemptions
            </a>
        </nav>

        <!-- Add New Reward Section -->
        <div class="card">
            <div class="header-section">
                <h2>Add New Reward</h2>
            </div>

            <asp:Label ID="lblAddStatus" runat="server" EnableViewState="false" />

            <div class="form-group">
                <label>Reward Name *</label>
                <asp:TextBox ID="txtAddName" runat="server" CssClass="form-control" MaxLength="200" />
                <asp:RequiredFieldValidator ID="rfvAddName" runat="server" 
                    ControlToValidate="txtAddName" 
                    ErrorMessage="Reward name is required" 
                    CssClass="validation" 
                    Display="Dynamic" />
            </div>

            <div class="form-group">
                <label>Description</label>
                <asp:TextBox ID="txtAddDescription" runat="server" CssClass="form-control" 
                    TextMode="MultiLine" Rows="3" MaxLength="1000" />
            </div>

            <div class="form-group">
                <label>Points Required *</label>
                <asp:TextBox ID="txtAddPointsRequired" runat="server" CssClass="form-control" 
                    TextMode="Number" min="0" />
                <small class="stock-info">Free Item can be 0, Discounts/Vouchers require minimum 1</small>
                <asp:RequiredFieldValidator ID="rfvAddPoints" runat="server" 
                    ControlToValidate="txtAddPointsRequired" 
                    ErrorMessage="Points required is needed" 
                    CssClass="validation" 
                    Display="Dynamic" />
            </div>

            <div class="form-group">
                <label>Category *</label>
                <asp:DropDownList ID="ddlAddCategory" runat="server" CssClass="form-control" 
                    onchange="toggleCategoryFieldsAdd();">
                    <asp:ListItem Value="">-- Select Category --</asp:ListItem>
                    <asp:ListItem Value="Discounts">Discounts</asp:ListItem>
                    <asp:ListItem Value="Vouchers">Vouchers</asp:ListItem>
                    <asp:ListItem Value="Free Items">Free Items</asp:ListItem>
                </asp:DropDownList>
                <asp:RequiredFieldValidator ID="rfvAddCategory" runat="server" 
                    ControlToValidate="ddlAddCategory" 
                    ErrorMessage="Category is required" 
                    CssClass="validation" 
                    Display="Dynamic" 
                    InitialValue="" />
            </div>

            <div class="form-group" id="divAddDiscountPercentage" style="display: none;">
                <label>Discount Percentage *</label>
                <asp:TextBox ID="txtAddDiscountPercentage" runat="server" CssClass="form-control" 
                    TextMode="Number" min="0" max="100" step="0.01" />
                <small class="stock-info">Enter the discount percentage (e.g., 10 for 10%)</small>
            </div>

            <div class="form-group" id="divAddVoucherAmount" style="display: none;">
                <label>Voucher Amount *</label>
                <asp:TextBox ID="txtAddVoucherAmount" runat="server" CssClass="form-control" 
                    TextMode="Number" min="0" step="0.01" />
                <small class="stock-info">Enter the voucher amount (e.g., 10 for $10)</small>
            </div>

            <div class="form-group">
                <label>Partnering Stores</label>
                <asp:TextBox ID="txtAddPartneringStores" runat="server" CssClass="form-control" MaxLength="200" 
                    placeholder="e.g., Urban Bistro, Amy's Kitchen, Bakery 101" />
            </div>

            <div class="form-group">
                <label style="color: #ff6b35; font-weight: 700; font-size: 1.1rem;">Reward Image (optional)</label>
                <div style="border: 3px dashed #ff6b35; border-radius: 12px; padding: 20px; background: #fff5f0; margin-top: 10px;">
                    <asp:FileUpload ID="fuAddImage" runat="server" CssClass="form-control" 
                        accept="image/jpeg,image/jpg,image/png,image/gif"
                        onchange="previewImageAdd(this);"
                        style="padding: 12px; border: 2px solid #ff6b35; border-radius: 6px; background: white; width: 100%; cursor: pointer; font-size: 1rem; margin-bottom: 10px; display: block !important;" />
                    <small class="stock-info" style="display: block; margin-top: 8px; color: #666;">
                        Accepted formats: JPG, JPEG, PNG, GIF (max 5MB). Leave empty if no image needed.
                    </small>
                    <div id="imagePreviewAdd" style="margin-top: 15px; display: none;">
                        <p style="margin: 10px 0 5px 0; font-weight: 600; color: #333; font-size: 0.95rem;">Preview:</p>
                        <img id="previewImgAdd" src="" alt="Image preview" style="max-width: 200px; max-height: 200px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" />
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label>Stock Quantity</label>
                <asp:TextBox ID="txtAddStockQuantity" runat="server" CssClass="form-control" 
                    TextMode="Number" min="0" />
                <small class="stock-info">Leave empty for unlimited stock</small>
            </div>

            <div class="form-group">
                <label>Expiry Type</label>
                <asp:DropDownList ID="ddlAddExpiryType" runat="server" CssClass="form-control" 
                    onchange="toggleExpiryFieldsAdd();">
                    <asp:ListItem Value="">No Expiry</asp:ListItem>
                    <asp:ListItem Value="FixedDate">Fixed Date</asp:ListItem>
                    <asp:ListItem Value="Timespan">Timespan (from redemption)</asp:ListItem>
                </asp:DropDownList>
                <small class="stock-info">Choose how the reward expires</small>
            </div>

            <div class="form-group" id="divAddExpiryDate" style="display:none;">
                <label>Expiry Date</label>
                <asp:TextBox ID="txtAddExpiryDate" runat="server" CssClass="form-control" 
                    TextMode="Date" />
                <small class="stock-info">Fixed expiry date (e.g., 31/03/2026)</small>
            </div>

            <div class="form-group" id="divAddExpiryTimespan" style="display:none;">
                <label>Expiry Timespan</label>
                <div style="display: flex; gap: 10px; align-items: center;">
                    <asp:TextBox ID="txtAddExpiryTimespanValue" runat="server" CssClass="form-control" 
                        TextMode="Number" min="1" max="365" style="width: 100px;" placeholder="Value" />
                    <asp:DropDownList ID="ddlAddExpiryTimespanUnit" runat="server" CssClass="form-control" 
                        style="width: 120px;">
                        <asp:ListItem Value="Days" Text="Day(s)" />
                        <asp:ListItem Value="Weeks" Text="Week(s)" Selected="True" />
                        <asp:ListItem Value="Months" Text="Month(s)" />
                    </asp:DropDownList>
                </div>
                <small class="stock-info">Time from redemption date until expiry (e.g., 30 Days, 2 Weeks, 3 Months)</small>
            </div>

            <div class="form-group">
                <asp:CheckBox ID="chkAddIsAvailable" runat="server" Checked="true" Text="Available" />
            </div>

            <div class="actions">
                <asp:Button ID="btnSaveAddReward" runat="server" Text="Save Reward" 
                    CssClass="btn btn-primary" OnClick="btnSaveAddReward_Click" />
                <asp:Button ID="btnCancelAdd" runat="server" Text="Cancel" 
                    CssClass="btn btn-secondary" OnClick="btnCancelAdd_Click" CausesValidation="false" />
            </div>
        </div>
    </div>

</asp:Content>
