using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CulinaryPursuit
{
    public partial class AddReward : System.Web.UI.Page
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
        }

        protected void btnCancelAdd_Click(object sender, EventArgs e)
        {
            ClearAddForm();
            Response.Redirect("AdminRewards.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnSaveAddReward_Click(object sender, EventArgs e)
        {
            string name = txtAddName.Text.Trim();
            string description = txtAddDescription.Text.Trim();
            string pointsRaw = txtAddPointsRequired.Text.Trim();
            string category = ddlAddCategory.SelectedValue;
            string partneringStores = txtAddPartneringStores.Text.Trim();
            string stockRaw = txtAddStockQuantity.Text.Trim();
            string expiryType = ddlAddExpiryType.SelectedValue;
            string expiryDateRaw = txtAddExpiryDate.Text.Trim();
            string expiryTimespanValueRaw = txtAddExpiryTimespanValue.Text.Trim();
            string expiryTimespanUnit = ddlAddExpiryTimespanUnit.SelectedValue;
            string discountPercentageRaw = txtAddDiscountPercentage.Text.Trim();
            string voucherAmountRaw = txtAddVoucherAmount.Text.Trim();
            bool available = chkAddIsAvailable.Checked;

            // Validation
            if (name.Length < 2 || name.Length > 200)
            {
                ShowAddStatus("Error: Name must be 2–200 characters.", true);
                return;
            }

            if (string.IsNullOrWhiteSpace(category))
            {
                ShowAddStatus("Error: Category is required.", true);
                return;
            }

            // Validate points based on category
            if (!int.TryParse(pointsRaw, out int points) || points < 0)
            {
                ShowAddStatus("Error: Points required must be a non-negative number.", true);
                return;
            }

            // Validate category-specific fields and points requirements
            decimal? discountPercentage = null;
            decimal? voucherAmount = null;

            if (category == "Discounts")
            {
                if (points < 1)
                {
                    ShowAddStatus("Error: Points required must be at least 1 for Discounts category.", true);
                    return;
                }
                
                if (string.IsNullOrWhiteSpace(discountPercentageRaw))
                {
                    ShowAddStatus("Error: Discount percentage is required for Discounts category.", true);
                    return;
                }
                if (decimal.TryParse(discountPercentageRaw, out decimal discount) && discount >= 0 && discount <= 100)
                {
                    discountPercentage = discount;
                }
                else
                {
                    ShowAddStatus("Error: Discount percentage must be between 0 and 100.", true);
                    return;
                }
            }
            else if (category == "Vouchers")
            {
                if (points < 1)
                {
                    ShowAddStatus("Error: Points required must be at least 1 for Vouchers category.", true);
                    return;
                }
                
                if (string.IsNullOrWhiteSpace(voucherAmountRaw))
                {
                    ShowAddStatus("Error: Voucher amount is required for Vouchers category.", true);
                    return;
                }
                if (decimal.TryParse(voucherAmountRaw, out decimal amount) && amount >= 0)
                {
                    voucherAmount = amount;
                }
                else
                {
                    ShowAddStatus("Error: Voucher amount must be a non-negative number.", true);
                    return;
                }
            }

            int? stockQuantity = null;
            if (!string.IsNullOrWhiteSpace(stockRaw))
            {
                if (int.TryParse(stockRaw, out int stock) && stock >= 0)
                {
                    stockQuantity = stock;
                }
                else
                {
                    ShowAddStatus("Error: Stock quantity must be a non-negative number.", true);
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
                    ShowAddStatus("Error: Expiry date is required when Expiry Type is Fixed Date.", true);
                    return;
                }
                if (DateTime.TryParse(expiryDateRaw, out DateTime parsedDate))
                {
                    expiryDate = parsedDate;
                }
                else
                {
                    ShowAddStatus("Error: Invalid expiry date format.", true);
                    return;
                }
            }
            else if (expiryType == "Timespan")
            {
                if (string.IsNullOrWhiteSpace(expiryTimespanValueRaw))
                {
                    ShowAddStatus("Error: Expiry timespan value is required when Expiry Type is Timespan.", true);
                    return;
                }
                if (string.IsNullOrWhiteSpace(expiryTimespanUnit))
                {
                    ShowAddStatus("Error: Expiry timespan unit is required.", true);
                    return;
                }
                if (int.TryParse(expiryTimespanValueRaw, out int value) && value > 0 && value <= 365)
                {
                    expiryTimespanValue = value;
                    expiryTimespanUnitValue = expiryTimespanUnit;
                }
                else
                {
                    ShowAddStatus("Error: Expiry timespan value must be between 1 and 365.", true);
                    return;
                }
            }

            // ===============================
            // IMAGE UPLOAD
            // ===============================
            string imagePath = null;

            if (fuAddImage.HasFile)
            {
                try
                {
                    string ext = System.IO.Path.GetExtension(fuAddImage.FileName).ToLower();

                    if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
                    {
                        ShowAddStatus("Error: Only JPG, JPEG, PNG, or GIF images are allowed.", true);
                        return;
                    }

                    if (fuAddImage.PostedFile.ContentLength > 5242880) // 5MB
                    {
                        ShowAddStatus("Error: Image size must be less than 5MB.", true);
                        return;
                    }

                    string fileName = Guid.NewGuid().ToString() + ext;
                    string folder = Server.MapPath("~/Uploads/Rewards/");

                    if (!System.IO.Directory.Exists(folder))
                        System.IO.Directory.CreateDirectory(folder);

                    string fullPath = System.IO.Path.Combine(folder, fileName);
                    fuAddImage.SaveAs(fullPath);

                    // Store relative path in DB
                    imagePath = "/Uploads/Rewards/" + fileName;
                }
                catch (Exception ex)
                {
                    ShowAddStatus($"Error uploading image: {ex.Message}", true);
                    return;
                }
            }

            string connStr = ConfigurationManager
                .ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // Insert new reward
                using (SqlCommand cmd = new SqlCommand(@"
INSERT INTO dbo.Rewards (Name, Description, PointsRequired, Category, PartneringStores, StockQuantity, IsAvailable, ExpiryType, ExpiryDate, ExpiryTimespanValue, ExpiryTimespanUnit, DiscountPercentage, VoucherAmount, ImagePath)
VALUES (@Name, @Description, @PointsRequired, @Category, @PartneringStores, @StockQuantity, @IsAvailable, @ExpiryType, @ExpiryDate, @ExpiryTimespanValue, @ExpiryTimespanUnit, @DiscountPercentage, @VoucherAmount, @ImagePath);", conn))
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
                    cmd.Parameters.Add("@ImagePath", SqlDbType.NVarChar, 500).Value = 
                        string.IsNullOrWhiteSpace(imagePath) ? (object)DBNull.Value : imagePath;

                    cmd.ExecuteNonQuery();
                }
                ShowAddStatus("✅ New reward added successfully!", false);
                
                // Clear form
                ClearAddForm();
                
                // Redirect to manage view to see the new reward
                Response.Redirect("AdminRewards.aspx?added=1", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        private void ClearAddForm()
        {
            txtAddName.Text = "";
            txtAddDescription.Text = "";
            txtAddPointsRequired.Text = "";
            ddlAddCategory.SelectedIndex = 0;
            txtAddPartneringStores.Text = "";
            txtAddStockQuantity.Text = "";
            ddlAddExpiryType.SelectedIndex = 0;
            txtAddExpiryDate.Text = "";
            txtAddExpiryTimespanValue.Text = "";
            ddlAddExpiryTimespanUnit.SelectedIndex = 1;
            txtAddDiscountPercentage.Text = "";
            txtAddVoucherAmount.Text = "";
            chkAddIsAvailable.Checked = true;
        }

        private void ShowAddStatus(string message, bool isError)
        {
            string safe = HttpUtility.HtmlEncode(message);
            lblAddStatus.Text = $"<div class='{(isError ? "msg-err" : "msg-ok")}'>{safe}</div>";
        }
    }
}
