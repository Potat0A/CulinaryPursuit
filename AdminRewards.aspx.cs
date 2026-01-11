using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class AdminRewards : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check admin authentication
            if (Session["AdminID"] == null)
            {
                Response.Redirect("AdminLogin.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ValidationSettings.UnobtrusiveValidationMode = UnobtrusiveValidationMode.None;
            
            // Ensure form encoding is set for file uploads
            if (Page.Form != null)
            {
                Page.Form.Enctype = "multipart/form-data";
            }
            
            if (!IsPostBack)
            {
                BindRewards();
                
                // Show success message if redirected from AddReward
                if (Request.QueryString["added"] == "1")
                {
                    ShowStatus("✅ New reward added successfully!", false);
                }
            }
            // Note: On postback, GridView events (RowEditing, RowUpdating, etc.) will handle binding
            // Don't rebind in Page_Load on postback as it will interfere with GridView state
        }

        // --------------------
        // LOAD REWARDS
        // --------------------
        private void BindRewards()
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT RewardID, Name, Description, PointsRequired, Category, 
       IsAvailable, StockQuantity, CreatedDate, PartneringStores,
       ExpiryType, ExpiryDate, ExpiryTimespanValue, ExpiryTimespanUnit,
       DiscountPercentage, VoucherAmount, ImagePath
FROM dbo.Rewards
ORDER BY CreatedDate DESC;", conn))
            {
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvRewards.DataSource = dt;
                    gvRewards.DataBind();
                    
                    // Store DataTable in ViewState for access in RowEditing
                    ViewState["RewardsDataTable"] = dt;
                }
            }
        }

        // --------------------
        // GRIDVIEW EVENTS
        // --------------------
        protected void gvRewards_RowEditing(object sender, GridViewEditEventArgs e)
        {
            try
            {
                // Clear any previous status messages
                lblStatus.Text = "";
                
                gvRewards.EditIndex = e.NewEditIndex;
                BindRewards();
                
                // Set the selected value for category dropdown in the row being edited
                GridViewRow row = gvRewards.Rows[e.NewEditIndex];
                DropDownList ddlCategory = row.FindControl("ddlEditCategory") as DropDownList;
                if (ddlCategory != null)
                {
                    // Get the category value from ViewState
                    DataTable dt = ViewState["RewardsDataTable"] as DataTable;
                    if (dt != null && e.NewEditIndex < dt.Rows.Count)
                    {
                        object categoryValue = dt.Rows[e.NewEditIndex]["Category"];
                        if (categoryValue != null && categoryValue != DBNull.Value)
                        {
                            string category = categoryValue.ToString();
                            if (ddlCategory.Items.FindByValue(category) != null)
                            {
                                ddlCategory.SelectedValue = category;
                            }
                        }
                    }
                }
                
                // Register script to initialize edit mode fields after GridView is bound
                // Use a function call instead of inline script to avoid CSP issues
                // Use requestAnimationFrame instead of setTimeout to avoid CSP warnings
                string script = "if (typeof initializeEditModeFields === 'function') { requestAnimationFrame(function() { requestAnimationFrame(initializeEditModeFields); }); }";
                ClientScript.RegisterStartupScript(this.GetType(), "InitEditMode", script, true);
            }
            catch (Exception ex)
            {
                ShowStatus($"Error entering edit mode: {ex.Message}", true);
            }
        }

        protected void gvRewards_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvRewards.EditIndex = -1;
            BindRewards();
        }

        protected void gvRewards_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int rewardId = Convert.ToInt32(gvRewards.DataKeys[e.RowIndex].Value);
            GridViewRow row = gvRewards.Rows[e.RowIndex];

            string name = ((TextBox)row.FindControl("txtEditName"))?.Text.Trim() ?? "";
            string description = ((TextBox)row.FindControl("txtEditDescription"))?.Text.Trim() ?? "";
            string pointsRaw = ((TextBox)row.FindControl("txtEditPoints"))?.Text.Trim() ?? "";
            DropDownList ddlEditCategory = (DropDownList)row.FindControl("ddlEditCategory");
            string category = ddlEditCategory?.SelectedValue ?? "";
            TextBox txtEditDiscountPercentage = (TextBox)row.FindControl("txtEditDiscountPercentage");
            TextBox txtEditVoucherAmount = (TextBox)row.FindControl("txtEditVoucherAmount");
            string discountPercentageRaw = txtEditDiscountPercentage?.Text.Trim() ?? "";
            string voucherAmountRaw = txtEditVoucherAmount?.Text.Trim() ?? "";
            string partneringStores = ((TextBox)row.FindControl("txtEditPartneringStores"))?.Text.Trim() ?? "";
            string stockRaw = ((TextBox)row.FindControl("txtEditStock"))?.Text.Trim() ?? "";
            bool available = ((CheckBox)row.FindControl("chkEditAvailable"))?.Checked ?? true;
            
            // Get current image path from database
            string currentImagePath = GetCurrentImagePath(rewardId);
            
            // Handle image upload and removal
            FileUpload fuEditImage = (FileUpload)row.FindControl("fuEditImage");
            CheckBox chkRemoveImage = (CheckBox)row.FindControl("chkRemoveImage");
            string imagePath = currentImagePath; // Default to current image
            
            // If new file is uploaded, it takes precedence (replace the image)
            if (fuEditImage != null && fuEditImage.HasFile)
            {
                string ext = System.IO.Path.GetExtension(fuEditImage.FileName).ToLower();
                
                if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
                {
                    ShowStatus("Error: Only JPG, JPEG, PNG, or GIF images are allowed.", true);
                    return;
                }
                
                if (fuEditImage.PostedFile.ContentLength > 5242880) // 5MB
                {
                    ShowStatus("Error: Image size must be less than 5MB.", true);
                    return;
                }
                
                string fileName = Guid.NewGuid().ToString() + ext;
                string folder = Server.MapPath("~/Uploads/Rewards/");
                
                if (!System.IO.Directory.Exists(folder))
                    System.IO.Directory.CreateDirectory(folder);
                
                string fullPath = System.IO.Path.Combine(folder, fileName);
                fuEditImage.SaveAs(fullPath);
                
                // Delete old image if it exists
                if (!string.IsNullOrEmpty(currentImagePath))
                {
                    string oldImagePath = Server.MapPath(currentImagePath);
                    if (System.IO.File.Exists(oldImagePath))
                    {
                        try { System.IO.File.Delete(oldImagePath); } catch { /* ignore */ }
                    }
                }
                
                // Store relative path in DB
                imagePath = "/Uploads/Rewards/" + fileName;
            }
            // If no new file uploaded but checkbox is checked, remove the image
            else if (chkRemoveImage != null && chkRemoveImage.Checked)
            {
                // Delete the image file from server
                if (!string.IsNullOrEmpty(currentImagePath))
                {
                    string oldImagePath = Server.MapPath(currentImagePath);
                    if (System.IO.File.Exists(oldImagePath))
                    {
                        try { System.IO.File.Delete(oldImagePath); } catch { /* ignore */ }
                    }
                }
                // Set imagePath to null to remove it from database
                imagePath = null;
            }
            // If neither new file uploaded nor checkbox checked, keep current image (imagePath already set to currentImagePath)
            
            // Get expiry fields
            DropDownList ddlEditExpiryType = (DropDownList)row.FindControl("ddlEditExpiryType");
            TextBox txtEditExpiryDate = (TextBox)row.FindControl("txtEditExpiryDate");
            TextBox txtEditExpiryTimespanValue = (TextBox)row.FindControl("txtEditExpiryTimespanValue");
            DropDownList ddlEditExpiryTimespanUnit = (DropDownList)row.FindControl("ddlEditExpiryTimespanUnit");
            
            string expiryType = ddlEditExpiryType?.SelectedValue ?? "";
            string expiryDateRaw = txtEditExpiryDate?.Text.Trim() ?? "";
            string expiryTimespanValueRaw = txtEditExpiryTimespanValue?.Text.Trim() ?? "";
            string expiryTimespanUnit = ddlEditExpiryTimespanUnit?.SelectedValue ?? "";
            
            // Validate and process expiry fields
            DateTime? expiryDate = null;
            int? expiryTimespanValue = null;
            string expiryTimespanUnitValue = null;
            
            if (!string.IsNullOrWhiteSpace(expiryType))
            {
                if (expiryType == "FixedDate")
                {
                    if (!string.IsNullOrWhiteSpace(expiryDateRaw) && DateTime.TryParse(expiryDateRaw, out DateTime parsedDate))
                    {
                        expiryDate = parsedDate;
                    }
                }
                else if (expiryType == "Timespan")
                {
                    if (!string.IsNullOrWhiteSpace(expiryTimespanValueRaw) && int.TryParse(expiryTimespanValueRaw, out int value) && value > 0 && value <= 365)
                    {
                        expiryTimespanValue = value;
                        expiryTimespanUnitValue = expiryTimespanUnit;
                    }
                }
            }

            // Validation
            if (name.Length < 2 || name.Length > 200)
            {
                ShowStatus("Update failed: Name must be 2–200 characters.", true);
                return;
            }

            if (!int.TryParse(pointsRaw, out int points) || points < 0)
            {
                ShowStatus("Update failed: Points required must be a non-negative number.", true);
                return;
            }

            // Validate category-specific fields
            decimal? discountPercentage = null;
            decimal? voucherAmount = null;

            if (category == "Discounts")
            {
                if (points < 1)
                {
                    ShowStatus("Update failed: Points required must be at least 1 for Discounts category.", true);
                    return;
                }
                
                if (string.IsNullOrWhiteSpace(discountPercentageRaw))
                {
                    ShowStatus("Update failed: Discount percentage is required for Discounts category.", true);
                    return;
                }
                if (decimal.TryParse(discountPercentageRaw, out decimal discount) && discount >= 0 && discount <= 100)
                {
                    discountPercentage = discount;
                }
                else
                {
                    ShowStatus("Update failed: Discount percentage must be between 0 and 100.", true);
                    return;
                }
            }
            else if (category == "Vouchers")
            {
                if (points < 1)
                {
                    ShowStatus("Update failed: Points required must be at least 1 for Vouchers category.", true);
                    return;
                }
                
                if (string.IsNullOrWhiteSpace(voucherAmountRaw))
                {
                    ShowStatus("Update failed: Voucher amount is required for Vouchers category.", true);
                    return;
                }
                if (decimal.TryParse(voucherAmountRaw, out decimal amount) && amount >= 0)
                {
                    voucherAmount = amount;
                }
                else
                {
                    ShowStatus("Update failed: Voucher amount must be a non-negative number.", true);
                    return;
                }
            }
            // Free Item: points can be 0 or any value (no special validation needed)

            int? stockQuantity = null;
            if (!string.IsNullOrWhiteSpace(stockRaw))
            {
                if (int.TryParse(stockRaw, out int stock) && stock >= 0)
                {
                    stockQuantity = stock;
                }
                else
                {
                    ShowStatus("Update failed: Stock quantity must be a non-negative number.", true);
                    return;
                }
            }

            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
UPDATE dbo.Rewards
SET Name = @Name,
    Description = @Description,
    PointsRequired = @PointsRequired,
    Category = @Category,
    PartneringStores = @PartneringStores,
    StockQuantity = @StockQuantity,
    IsAvailable = @IsAvailable,
    ExpiryType = @ExpiryType,
    ExpiryDate = @ExpiryDate,
    ExpiryTimespanValue = @ExpiryTimespanValue,
    ExpiryTimespanUnit = @ExpiryTimespanUnit,
    DiscountPercentage = @DiscountPercentage,
    VoucherAmount = @VoucherAmount,
    ImagePath = @ImagePath,
    UpdatedDate = GETDATE()
WHERE RewardID = @RewardID;", conn))
            {
                cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = name;
                cmd.Parameters.Add("@Description", SqlDbType.NVarChar, 1000).Value = 
                    string.IsNullOrWhiteSpace(description) ? (object)DBNull.Value : description;
                cmd.Parameters.Add("@PointsRequired", SqlDbType.Int).Value = points;
                cmd.Parameters.Add("@Category", SqlDbType.NVarChar, 100).Value = 
                    string.IsNullOrWhiteSpace(category) ? (object)DBNull.Value : category;
                cmd.Parameters.Add("@PartneringStores", SqlDbType.NVarChar, 200).Value = 
                    string.IsNullOrWhiteSpace(partneringStores) ? (object)DBNull.Value : partneringStores;
                cmd.Parameters.Add("@StockQuantity", SqlDbType.Int).Value = 
                    stockQuantity.HasValue ? (object)stockQuantity.Value : DBNull.Value;
                cmd.Parameters.Add("@IsAvailable", SqlDbType.Bit).Value = available;
                cmd.Parameters.Add("@ExpiryType", SqlDbType.NVarChar, 20).Value = 
                    string.IsNullOrWhiteSpace(expiryType) ? (object)DBNull.Value : expiryType;
                cmd.Parameters.Add("@ExpiryDate", SqlDbType.DateTime).Value = 
                    expiryDate.HasValue ? (object)expiryDate.Value : DBNull.Value;
                cmd.Parameters.Add("@ExpiryTimespanValue", SqlDbType.Int).Value = 
                    expiryTimespanValue.HasValue ? (object)expiryTimespanValue.Value : DBNull.Value;
                cmd.Parameters.Add("@ExpiryTimespanUnit", SqlDbType.NVarChar, 10).Value = 
                    string.IsNullOrWhiteSpace(expiryTimespanUnitValue) ? (object)DBNull.Value : expiryTimespanUnitValue;
                cmd.Parameters.Add("@DiscountPercentage", SqlDbType.Decimal).Value = 
                    discountPercentage.HasValue ? (object)discountPercentage.Value : DBNull.Value;
                cmd.Parameters["@DiscountPercentage"].Precision = 5;
                cmd.Parameters["@DiscountPercentage"].Scale = 2;
                cmd.Parameters.Add("@VoucherAmount", SqlDbType.Decimal).Value = 
                    voucherAmount.HasValue ? (object)voucherAmount.Value : DBNull.Value;
                cmd.Parameters["@VoucherAmount"].Precision = 10;
                cmd.Parameters["@VoucherAmount"].Scale = 2;
                cmd.Parameters.Add("@ImagePath", SqlDbType.NVarChar, 500).Value = 
                    string.IsNullOrWhiteSpace(imagePath) ? (object)DBNull.Value : imagePath;
                cmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;

                conn.Open();
                cmd.ExecuteNonQuery();
            }

            gvRewards.EditIndex = -1;
            ShowStatus("✅ Reward updated successfully.", false);
            BindRewards();
        }


        protected void gvRewards_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int rewardId = Convert.ToInt32(gvRewards.DataKeys[e.RowIndex].Value);
            DeleteReward(rewardId);
        }

        private void DeleteReward(int rewardId)
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    
                    // Check if reward has any redemptions
                    using (SqlCommand checkCmd = new SqlCommand(@"
SELECT COUNT(*) FROM dbo.RewardRedemptions WHERE RewardID = @RewardID", conn))
                    {
                        checkCmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                        int redemptionCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                        
                        if (redemptionCount > 0)
                        {
                            ShowStatus($"❌ Cannot delete reward: This reward has {redemptionCount} redemption(s) associated with it. Please delete the redemptions first.", true);
                            BindRewards();
                            return;
                        }
                    }
                    
                    // Delete the reward
                    using (SqlCommand cmd = new SqlCommand(@"
DELETE FROM dbo.Rewards
WHERE RewardID = @RewardID;", conn))
                    {
                        cmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                        int rowsAffected = cmd.ExecuteNonQuery();
                        
                        if (rowsAffected > 0)
                        {
                            ShowStatus("🗑️ Reward deleted successfully.", false);
                        }
                        else
                        {
                            ShowStatus("❌ Reward not found or could not be deleted.", true);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                if (sqlEx.Number == 547) // Foreign key constraint violation
                {
                    ShowStatus("❌ Cannot delete reward: This reward is referenced by other records (e.g., redemptions). Please delete those records first.", true);
                }
                else
                {
                    ShowStatus($"❌ Error deleting reward: {sqlEx.Message}", true);
                }
            }
            catch (Exception ex)
            {
                ShowStatus($"❌ Error deleting reward: {ex.Message}", true);
            }

            BindRewards();
        }

        // --------------------
        // VIEW/DELETE REDEMPTIONS
        // --------------------
        protected void btnViewRedemptions_Click(object sender, EventArgs e)
        {
            try
            {
                Button btn = (Button)sender;
                int rewardId = Convert.ToInt32(btn.CommandArgument);
                
                // Store rewardId in ViewState for use in deletion
                ViewState["CurrentRewardID"] = rewardId;
                
                BindRedemptions(rewardId);
                
                // Show modal using JavaScript function - ensure it runs after page load
                string script = @"
                    if (typeof showRedemptionsModal === 'function') {
                        setTimeout(function() { showRedemptionsModal(); }, 200);
                    } else {
                        setTimeout(function() {
                            var modalElement = document.getElementById('redemptionsModal');
                            if (modalElement) {
                                var modal = new bootstrap.Modal(modalElement);
                                modal.show();
                            }
                        }, 200);
                    }
                ";
                ClientScript.RegisterStartupScript(this.GetType(), "ShowRedemptionsModal", script, true);
            }
            catch (Exception ex)
            {
                ShowStatus($"Error loading redemptions: {ex.Message}", true);
            }
        }

        private void BindRedemptions(int rewardId)
        {
            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(@"
SELECT rr.RedemptionID, rr.CustomerID, rr.PointsUsed, rr.RedemptionDate, 
       rr.Status, rr.ExpiryDate, r.Name AS RewardName
FROM dbo.RewardRedemptions rr
INNER JOIN dbo.Rewards r ON rr.RewardID = r.RewardID
WHERE rr.RewardID = @RewardID
ORDER BY rr.RedemptionDate DESC;", conn))
            {
                cmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvRedemptions.DataSource = dt;
                    gvRedemptions.DataBind();
                }
            }

            // Update modal title with reward name
            string rewardName = "";
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT Name FROM dbo.Rewards WHERE RewardID = @RewardID", conn))
            {
                cmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                conn.Open();
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    rewardName = result.ToString();
                }
            }

            // Update modal status label
            if (lblRedemptionsStatus != null)
            {
                lblRedemptionsStatus.Text = $"<p class='mb-3'><strong>Reward:</strong> {HttpUtility.HtmlEncode(rewardName)}</p>";
            }
        }

        protected void gvRedemptions_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int redemptionId = Convert.ToInt32(gvRedemptions.DataKeys[e.RowIndex].Value);
            int rewardId = 0;

            // Get rewardId from ViewState
            if (ViewState["CurrentRewardID"] != null)
            {
                rewardId = Convert.ToInt32(ViewState["CurrentRewardID"]);
            }

            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                using (SqlCommand cmd = new SqlCommand(@"DELETE FROM dbo.RewardRedemptions WHERE RedemptionID = @RedemptionID;", conn))
                {
                    cmd.Parameters.Add("@RedemptionID", SqlDbType.Int).Value = redemptionId;
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();
                    
                    if (rowsAffected > 0)
                    {
                        if (lblRedemptionsStatus != null)
                        {
                            lblRedemptionsStatus.Text = "<div class='msg-ok'>✅ Redemption deleted successfully.</div>";
                        }
                        if (rewardId > 0)
                        {
                            BindRedemptions(rewardId);
                        }
                    }
                    else
                    {
                        if (lblRedemptionsStatus != null)
                        {
                            lblRedemptionsStatus.Text = "<div class='msg-err'>❌ Redemption not found or could not be deleted.</div>";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (lblRedemptionsStatus != null)
                {
                    lblRedemptionsStatus.Text = $"<div class='msg-err'>❌ Error deleting redemption: {HttpUtility.HtmlEncode(ex.Message)}</div>";
                }
            }
        }

        // --------------------
        // ADD/EDIT REWARD
        // --------------------
        // Note: Add Reward functionality has been moved to AddReward.aspx

        protected void ddlExpiryType_SelectedIndexChanged(object sender, EventArgs e)
        {
            // This will be handled by JavaScript, but keeping for server-side if needed
        }

        protected void btnSaveReward_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string description = txtDescription.Text.Trim();
            string pointsRaw = txtPointsRequired.Text.Trim();
            string category = ddlCategory.SelectedValue;
            string partneringStores = txtPartneringStores.Text.Trim();
            string stockRaw = txtStockQuantity.Text.Trim();
            string expiryType = ddlExpiryType.SelectedValue;
            string expiryDateRaw = txtExpiryDate.Text.Trim();
            string expiryTimespanValueRaw = txtExpiryTimespanValue.Text.Trim();
            string expiryTimespanUnit = ddlExpiryTimespanUnit.SelectedValue;
            string discountPercentageRaw = txtDiscountPercentage.Text.Trim();
            string voucherAmountRaw = txtVoucherAmount.Text.Trim();
            bool available = chkIsAvailable.Checked;
            int rewardId = Convert.ToInt32(hdnRewardID.Value);

            // Validation
            if (name.Length < 2 || name.Length > 200)
            {
                ShowStatus("Error: Name must be 2–200 characters.", true);
                return;
            }

            if (string.IsNullOrWhiteSpace(category))
            {
                ShowStatus("Error: Category is required.", true);
                return;
            }

            // Validate points based on category
            if (!int.TryParse(pointsRaw, out int points) || points < 0)
            {
                ShowStatus("Error: Points required must be a non-negative number.", true);
                return;
            }

            // Validate category-specific fields and points requirements
            decimal? discountPercentage = null;
            decimal? voucherAmount = null;

            if (category == "Discounts")
            {
                // Discounts require minimum 1 point
                if (points < 1)
                {
                    ShowStatus("Error: Points required must be at least 1 for Discounts category.", true);
                    return;
                }
                
                if (string.IsNullOrWhiteSpace(discountPercentageRaw))
                {
                    ShowStatus("Error: Discount percentage is required for Discounts category.", true);
                    return;
                }
                if (decimal.TryParse(discountPercentageRaw, out decimal discount) && discount >= 0 && discount <= 100)
                {
                    discountPercentage = discount;
                }
                else
                {
                    ShowStatus("Error: Discount percentage must be between 0 and 100.", true);
                    return;
                }
            }
            else if (category == "Vouchers")
            {
                // Vouchers require minimum 1 point
                if (points < 1)
                {
                    ShowStatus("Error: Points required must be at least 1 for Vouchers category.", true);
                    return;
                }
                
                if (string.IsNullOrWhiteSpace(voucherAmountRaw))
                {
                    ShowStatus("Error: Voucher amount is required for Vouchers category.", true);
                    return;
                }
                if (decimal.TryParse(voucherAmountRaw, out decimal amount) && amount >= 0)
                {
                    voucherAmount = amount;
                }
                else
                {
                    ShowStatus("Error: Voucher amount must be a non-negative number.", true);
                    return;
                }
            }
            // Free Item: points can be 0 or any value (no special validation needed)

            int? stockQuantity = null;
            if (!string.IsNullOrWhiteSpace(stockRaw))
            {
                if (int.TryParse(stockRaw, out int stock) && stock >= 0)
                {
                    stockQuantity = stock;
                }
                else
                {
                    ShowStatus("Error: Stock quantity must be a non-negative number.", true);
                    return;
                }
            }

            // Validate expiry fields
            DateTime? expiryDate = null;
            int? expiryTimespanValue = null;
            string expiryTimespanUnitValue = null;
            
            if (expiryType == "FixedDate")
            {
                if (string.IsNullOrWhiteSpace(expiryDateRaw))
                {
                    ShowStatus("Error: Expiry date is required when Expiry Type is Fixed Date.", true);
                    return;
                }
                if (DateTime.TryParse(expiryDateRaw, out DateTime parsedDate))
                {
                    expiryDate = parsedDate;
                }
                else
                {
                    ShowStatus("Error: Invalid expiry date format.", true);
                    return;
                }
            }
            else if (expiryType == "Timespan")
            {
                if (string.IsNullOrWhiteSpace(expiryTimespanValueRaw))
                {
                    ShowStatus("Error: Expiry timespan value is required when Expiry Type is Timespan.", true);
                    return;
                }
                if (string.IsNullOrWhiteSpace(expiryTimespanUnit))
                {
                    ShowStatus("Error: Expiry timespan unit is required.", true);
                    return;
                }
                if (int.TryParse(expiryTimespanValueRaw, out int value) && value > 0 && value <= 365)
                {
                    expiryTimespanValue = value;
                    expiryTimespanUnitValue = expiryTimespanUnit;
                }
                else
                {
                    ShowStatus("Error: Expiry timespan value must be between 1 and 365.", true);
                    return;
                }
            }

            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                if (rewardId == 0)
                {
                    // Insert new reward
                    using (SqlCommand cmd = new SqlCommand(@"
INSERT INTO dbo.Rewards (Name, Description, PointsRequired, Category, PartneringStores, StockQuantity, IsAvailable, ExpiryType, ExpiryDate, ExpiryTimespanValue, ExpiryTimespanUnit, DiscountPercentage, VoucherAmount)
VALUES (@Name, @Description, @PointsRequired, @Category, @PartneringStores, @StockQuantity, @IsAvailable, @ExpiryType, @ExpiryDate, @ExpiryTimespanValue, @ExpiryTimespanUnit, @DiscountPercentage, @VoucherAmount);", conn))
                    {
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = name;
                        cmd.Parameters.Add("@Description", SqlDbType.NVarChar, 1000).Value = 
                            string.IsNullOrWhiteSpace(description) ? (object)DBNull.Value : description;
                        cmd.Parameters.Add("@PointsRequired", SqlDbType.Int).Value = points;
                        cmd.Parameters.Add("@Category", SqlDbType.NVarChar, 100).Value = category;
                        cmd.Parameters.Add("@PartneringStores", SqlDbType.NVarChar, 200).Value = 
                            string.IsNullOrWhiteSpace(partneringStores) ? (object)DBNull.Value : partneringStores;
                        cmd.Parameters.Add("@StockQuantity", SqlDbType.Int).Value = 
                            stockQuantity.HasValue ? (object)stockQuantity.Value : DBNull.Value;
                        cmd.Parameters.Add("@IsAvailable", SqlDbType.Bit).Value = available;
                        cmd.Parameters.Add("@ExpiryType", SqlDbType.NVarChar, 20).Value = 
                            string.IsNullOrWhiteSpace(expiryType) ? (object)DBNull.Value : expiryType;
                        cmd.Parameters.Add("@ExpiryDate", SqlDbType.DateTime).Value = 
                            expiryDate.HasValue ? (object)expiryDate.Value : DBNull.Value;
                        cmd.Parameters.Add("@ExpiryTimespanValue", SqlDbType.Int).Value = 
                            expiryTimespanValue.HasValue ? (object)expiryTimespanValue.Value : DBNull.Value;
                        cmd.Parameters.Add("@ExpiryTimespanUnit", SqlDbType.NVarChar, 10).Value = 
                            string.IsNullOrWhiteSpace(expiryTimespanUnitValue) ? (object)DBNull.Value : expiryTimespanUnitValue;
                        cmd.Parameters.Add("@DiscountPercentage", SqlDbType.Decimal).Value = 
                            discountPercentage.HasValue ? (object)discountPercentage.Value : DBNull.Value;
                        cmd.Parameters["@DiscountPercentage"].Precision = 5;
                        cmd.Parameters["@DiscountPercentage"].Scale = 2;
                        cmd.Parameters.Add("@VoucherAmount", SqlDbType.Decimal).Value = 
                            voucherAmount.HasValue ? (object)voucherAmount.Value : DBNull.Value;
                        cmd.Parameters["@VoucherAmount"].Precision = 10;
                        cmd.Parameters["@VoucherAmount"].Scale = 2;

                        cmd.ExecuteNonQuery();
                    }
                    ShowStatus("✅ New reward added successfully.", false);
                }
                else
                {
                    // Update existing reward
                    using (SqlCommand cmd = new SqlCommand(@"
UPDATE dbo.Rewards
SET Name = @Name,
    Description = @Description,
    PointsRequired = @PointsRequired,
    Category = @Category,
    PartneringStores = @PartneringStores,
    StockQuantity = @StockQuantity,
    IsAvailable = @IsAvailable,
    ExpiryType = @ExpiryType,
    ExpiryDate = @ExpiryDate,
    ExpiryTimespanValue = @ExpiryTimespanValue,
    ExpiryTimespanUnit = @ExpiryTimespanUnit,
    DiscountPercentage = @DiscountPercentage,
    VoucherAmount = @VoucherAmount,
    UpdatedDate = GETDATE()
WHERE RewardID = @RewardID;", conn))
                    {
                        cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 200).Value = name;
                        cmd.Parameters.Add("@Description", SqlDbType.NVarChar, 1000).Value = 
                            string.IsNullOrWhiteSpace(description) ? (object)DBNull.Value : description;
                        cmd.Parameters.Add("@PointsRequired", SqlDbType.Int).Value = points;
                        cmd.Parameters.Add("@Category", SqlDbType.NVarChar, 100).Value = category;
                        cmd.Parameters.Add("@PartneringStores", SqlDbType.NVarChar, 200).Value = 
                            string.IsNullOrWhiteSpace(partneringStores) ? (object)DBNull.Value : partneringStores;
                        cmd.Parameters.Add("@StockQuantity", SqlDbType.Int).Value = 
                            stockQuantity.HasValue ? (object)stockQuantity.Value : DBNull.Value;
                        cmd.Parameters.Add("@IsAvailable", SqlDbType.Bit).Value = available;
                        cmd.Parameters.Add("@ExpiryType", SqlDbType.NVarChar, 20).Value = 
                            string.IsNullOrWhiteSpace(expiryType) ? (object)DBNull.Value : expiryType;
                        cmd.Parameters.Add("@ExpiryDate", SqlDbType.DateTime).Value = 
                            expiryDate.HasValue ? (object)expiryDate.Value : DBNull.Value;
                        cmd.Parameters.Add("@ExpiryTimespanValue", SqlDbType.Int).Value = 
                            expiryTimespanValue.HasValue ? (object)expiryTimespanValue.Value : DBNull.Value;
                        cmd.Parameters.Add("@ExpiryTimespanUnit", SqlDbType.NVarChar, 10).Value = 
                            string.IsNullOrWhiteSpace(expiryTimespanUnitValue) ? (object)DBNull.Value : expiryTimespanUnitValue;
                        cmd.Parameters.Add("@DiscountPercentage", SqlDbType.Decimal).Value = 
                            discountPercentage.HasValue ? (object)discountPercentage.Value : DBNull.Value;
                        cmd.Parameters["@DiscountPercentage"].Precision = 5;
                        cmd.Parameters["@DiscountPercentage"].Scale = 2;
                        cmd.Parameters.Add("@VoucherAmount", SqlDbType.Decimal).Value = 
                            voucherAmount.HasValue ? (object)voucherAmount.Value : DBNull.Value;
                        cmd.Parameters["@VoucherAmount"].Precision = 10;
                        cmd.Parameters["@VoucherAmount"].Scale = 2;
                        cmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;

                        cmd.ExecuteNonQuery();
                    }
                    ShowStatus("✅ Reward updated successfully.", false);
                }
            }

            BindRewards();

            // Hide modal
            ClientScript.RegisterStartupScript(this.GetType(), "HideModal", 
                "setTimeout(function() { if(typeof hideRewardModal === 'function') { hideRewardModal(); } }, 100);", true);
        }

        // --------------------
        // UI HELPERS
        // --------------------
        protected string GetImageDisplay(object imagePath)
        {
            if (imagePath == null || imagePath == DBNull.Value || string.IsNullOrWhiteSpace(imagePath.ToString()))
            {
                return "<span style='color: #999; font-size: 0.85em;'>No image</span>";
            }
            
            string path = imagePath.ToString();
            if (path.StartsWith("~/"))
            {
                path = path.Replace("~/", "/");
            }
            
            return $"<img src='{path}' alt='Reward Image' style='max-width: 80px; max-height: 80px; border-radius: 4px; object-fit: cover;' />";
        }
        
        private string GetCurrentImagePath(int rewardId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand("SELECT ImagePath FROM dbo.Rewards WHERE RewardID = @RewardID", conn))
            {
                cmd.Parameters.Add("@RewardID", SqlDbType.Int).Value = rewardId;
                conn.Open();
                object result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? result.ToString() : null;
            }
        }
        
        protected string FormatExpiryInfo(object expiryType, object expiryDate, object expiryTimespanValue, object expiryTimespanUnit)
        {
            if (expiryType == null || expiryType == DBNull.Value || string.IsNullOrWhiteSpace(expiryType.ToString()))
            {
                return "No expiry";
            }

            string type = expiryType.ToString();
            if (type == "FixedDate")
            {
                if (expiryDate != null && expiryDate != DBNull.Value)
                {
                    try
                    {
                        DateTime date = Convert.ToDateTime(expiryDate);
                        return date.ToString("dd/MM/yyyy");
                    }
                    catch
                    {
                        return "Invalid date";
                    }
                }
                return "Date not set";
            }
            else if (type == "Timespan")
            {
                if (expiryTimespanValue != null && expiryTimespanValue != DBNull.Value && 
                    expiryTimespanUnit != null && expiryTimespanUnit != DBNull.Value)
                {
                    try
                    {
                        int value = Convert.ToInt32(expiryTimespanValue);
                        string unit = expiryTimespanUnit.ToString();
                        string unitText = unit.ToLower();
                        if (value > 1 && unit == "Days") unitText = "days";
                        else if (value > 1 && unit == "Weeks") unitText = "weeks";
                        else if (value > 1 && unit == "Months") unitText = "months";
                        return $"{value} {unitText} from redemption";
                    }
                    catch
                    {
                        return "Invalid timespan";
                    }
                }
                return "Timespan not set";
            }

            return "No expiry";
        }

        protected string FormatDiscountVoucherInfo(object category, object discountPercentage, object voucherAmount)
        {
            if (category == null || category == DBNull.Value || string.IsNullOrWhiteSpace(category.ToString()))
            {
                return "—";
            }

            string cat = category.ToString();
            
            if (cat == "Discounts")
            {
                if (discountPercentage != null && discountPercentage != DBNull.Value)
                {
                    try
                    {
                        decimal percentage = Convert.ToDecimal(discountPercentage);
                        return $"{percentage}%";
                    }
                    catch { return "Invalid %"; }
                }
                return "—";
            }
            else if (cat == "Vouchers")
            {
                if (voucherAmount != null && voucherAmount != DBNull.Value)
                {
                    try
                    {
                        decimal amount = Convert.ToDecimal(voucherAmount);
                        return $"${amount:F2}";
                    }
                    catch { return "Invalid $"; }
                }
                return "—";
            }
            
            return "—"; // For Free Item or other categories
        }


        private void ShowStatus(string message, bool isError)
        {
            string safe = HttpUtility.HtmlEncode(message);
            lblStatus.Text = $"<div class='{(isError ? "msg-err" : "msg-ok")}'>{safe}</div>";
        }
    }
}