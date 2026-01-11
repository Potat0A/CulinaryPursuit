<%@ Page Title="Sign Up" Language="C#" MasterPageFile="~/public.master" AutoEventWireup="true" CodeBehind="Signup.aspx.cs" Inherits="CulinaryPursuit.Signup" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<style>
    .signup-container {min-height: 90vh; display:flex; justify-content:center; align-items:center; padding:40px 20px;}
    .signup-card {max-width:850px;width:100%;background:white;border-radius:25px;box-shadow:0 20px 50px rgba(0,0,0,0.1);padding:50px;}
    .signup-title{text-align:center;font-weight:800;font-size:2rem;color:#f76b1c;margin-bottom:10px;}
    .signup-subtitle{text-align:center;color:#6c757d;margin-bottom:30px;}
    .form-group{margin-bottom:20px;}
    .form-label{display:block;font-weight:600;margin-bottom:8px;color:#333;}
    .form-control{width:100%;padding:14px 16px;border-radius:10px;border:2px solid #e0e0e0;background:#f8f9fa;font-size:1rem;}
    .form-control:focus{border-color:#f76b1c;outline:none;background:white;box-shadow:0 0 0 4px rgba(247,107,28,0.1);}
    .form-row{display:grid;grid-template-columns:1fr 1fr;gap:20px;}
    .btn-submit{width:100%;padding:15px;background:linear-gradient(135deg,#f76b1c,#ff9f4d);color:white;font-weight:700;border:none;border-radius:12px;font-size:1.1rem;cursor:pointer;transition:all 0.3s ease;box-shadow:0 6px 20px rgba(247,107,28,0.3);}
    .btn-submit:hover{transform:translateY(-3px);box-shadow:0 10px 30px rgba(247,107,28,0.5);}
    .switch-link{text-align:center;margin-top:20px;color:#6c757d;}
    .switch-link a{color:#f76b1c;font-weight:600;text-decoration:none;}
    .switch-link a:hover{text-decoration:underline;}
    .story-section{background:#fff9f0;border:2px dashed #f76b1c;border-radius:15px;padding:20px;margin:20px 0;}
    .story-title{font-weight:700;color:#f76b1c;margin-bottom:10px;display:flex;align-items:center;gap:8px;}
    .char-counter{text-align:right;font-size:0.85rem;color:#6c757d;margin-top:5px;}
    @media (max-width:768px){.form-row{grid-template-columns:1fr;}}
</style>

<div class="signup-container">
    <div class="signup-card">
        <% if (Request.QueryString["type"] == "restaurant") { %>
            <!-- 👨‍🍳 RESTAURANT SIGNUP -->
            <h2 class="signup-title">Register Your Kitchen 👨‍🍳</h2>
            <p class="signup-subtitle">Join our home-chef community and start earning!</p>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Restaurant / Brand Name *</label>
                    <asp:TextBox ID="txtRestaurantName" runat="server" CssClass="form-control" placeholder="The Cozy Spoon" required />
                </div>

                <div class="form-group">
                    <label class="form-label">Chef Name *</label>
                    <asp:TextBox ID="txtChefName" runat="server" CssClass="form-control" placeholder="Your full name" required />
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Business Email *</label>
                    <asp:TextBox ID="txtChefEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="chef@kitchen.com" required />
                </div>

                <div class="form-group">
                    <label class="form-label">Phone Number *</label>
                    <asp:TextBox ID="txtChefPhone" runat="server" CssClass="form-control" placeholder="+65 9123 4567" required />
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Kitchen Address *</label>
                <asp:TextBox ID="txtChefAddress" runat="server" CssClass="form-control" placeholder="123 Food Street, #01-23, Singapore 123456" required />
            </div>

            <div class="form-group">
                <label class="form-label">Cuisine Type *</label>
                <asp:TextBox ID="txtCuisine" runat="server" CssClass="form-control" placeholder="e.g. Malay, Italian, Fusion, Chinese" required />
            </div>

            <!-- Chef Story Section -->
            <div class="story-section">
                <div class="story-title">
                    <span>📖</span>
                    <span>Tell Us Your Story *</span>
                </div>
                <div class="form-group" style="margin-bottom:0;">
                    <label class="form-label" style="font-weight:400;color:#6c757d;">
                        Share your culinary journey, what inspires your cooking, and why you want to join our platform. 
                        This helps us understand your passion and helps customers connect with you!
                    </label>
                    <asp:TextBox ID="txtChefStory" runat="server" CssClass="form-control" 
                                 TextMode="MultiLine" Rows="6" 
                                 placeholder="Example: I've been cooking traditional Malay dishes for my family for 20 years. My grandmother taught me her secret recipes, and I want to share this authentic taste with more people..."
                                 MaxLength="1000" 
                                 onkeyup="updateCharCount(this)" 
                                 required />
                    <div class="char-counter">
                        <span id="charCount">0</span> / 1000 characters
                    </div>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Password *</label>
                    <asp:TextBox ID="txtChefPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Min. 8 characters" required />
                </div>

                <div class="form-group">
                    <label class="form-label">Confirm Password *</label>
                    <asp:TextBox ID="txtChefConfirm" runat="server" CssClass="form-control" TextMode="Password" placeholder="Confirm password" required />
                </div>
            </div>

            <asp:Button ID="btnChefSignup" runat="server" Text="🚀 Register Kitchen" CssClass="btn-submit" OnClick="btnChefSignup_Click" />

            <div class="switch-link">
                Already registered? <a href="Login.aspx">Sign In</a>
            </div>

        <% } else { %>
            <!-- 👤 CUSTOMER SIGNUP -->
            <h2 class="signup-title">Create Your Account 🍽️</h2>
            <p class="signup-subtitle">Order delicious home-cooked meals near you.</p>

            <div class="form-group">
                <label class="form-label">Full Name *</label>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="John Tan" required />
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Email *</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="you@example.com" required />
                </div>

                <div class="form-group">
                    <label class="form-label">Phone Number *</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="+65 8123 4567" required />
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Delivery Address *</label>
                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" placeholder="123 Street Name, #12-34, Singapore 123456" required />
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Password *</label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Min. 8 characters" required />
                </div>

                <div class="form-group">
                    <label class="form-label">Confirm Password *</label>
                    <asp:TextBox ID="txtConfirm" runat="server" CssClass="form-control" TextMode="Password" placeholder="Confirm password" required />
                </div>
            </div>

            <asp:Button ID="btnCustomerSignup" runat="server" Text="🎉 Sign Up" CssClass="btn-submit" OnClick="btnCustomerSignup_Click" />
            
            <div class="switch-link">
                Already have an account? <a href="Login.aspx">Sign In</a>
            </div>
        <% } %>
    </div>
</div>

<script>
    function updateCharCount(textarea) {
        const count = textarea.value.length;
        document.getElementById('charCount').textContent = count;
        
        // Change color based on length
        const counter = document.getElementById('charCount');
        if (count > 900) {
            counter.style.color = '#dc3545'; // Red when near limit
        } else if (count > 700) {
            counter.style.color = '#ffc107'; // Yellow warning
        } else {
            counter.style.color = '#6c757d'; // Gray default
        }
    }

    // Initialize character count on page load
    window.onload = function() {
        const storyField = document.getElementById('<%= txtChefStory.ClientID %>');
        if (storyField) {
            updateCharCount(storyField);
        }
    };
</script>
</asp:Content>