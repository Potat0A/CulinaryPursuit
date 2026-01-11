<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/customer.master" AutoEventWireup="true" CodeBehind="CustomerProfile.aspx.cs" Inherits="CulinaryPursuit.CustomerProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        .profile-container {
            padding: 60px 0;
            background: #f8f9fa;
        }

        .profile-card {
            background: white;
            border-radius: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 30px;
        }

        .profile-header {
            background: linear-gradient(135deg, #ff3c00, #ff9a3c);
            padding: 40px;
            text-align: center;
            color: white;
            position: relative;
        }

        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            border: 5px solid white;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 4rem;
            margin: 0 auto 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }

        .profile-name {
            font-size: 2rem;
            font-weight: 800;
            margin-bottom: 10px;
        }

        .profile-email {
            font-size: 1.1rem;
            opacity: 0.9;
        }

        .profile-body {
            padding: 40px;
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #ff3c00;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-label {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            display: block;
        }

        .form-control {
            width: 100%;
            padding: 15px 20px;
            border: 2px solid #e0e0e0;
            border-radius: 15px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: #f8f9fa;
        }

        .form-control:focus {
            outline: none;
            border-color: #ff3c00;
            background: white;
            box-shadow: 0 0 0 4px rgba(255,60,0,0.1);
        }

        .btn-save {
            background: linear-gradient(135deg, #ff3c00, #ff9a3c);
            color: white;
            font-weight: 700;
            padding: 15px 50px;
            border-radius: 50px;
            border: none;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            box-shadow: 0 6px 20px rgba(255,60,0,0.3);
        }

        .btn-save:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(255,60,0,0.5);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: linear-gradient(135deg, #fff, #f8f9fa);
            padding: 25px;
            border-radius: 20px;
            text-align: center;
            border: 2px solid #e0e0e0;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            border-color: #ff3c00;
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: 800;
            color: #ff3c00;
            display: block;
        }

        .stat-label {
            color: #666;
            font-weight: 600;
            margin-top: 10px;
        }

        .success-message {
            background: #d4edda;
            border: 2px solid #c3e6cb;
            color: #155724;
            padding: 15px 20px;
            border-radius: 15px;
            margin-bottom: 25px;
            display: none;
            animation: slideDown 0.5s ease;
        }

        .success-message.show {
            display: block;
        }

        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 768px) {
            .profile-body {
                padding: 25px;
            }
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="profile-container">
        <div class="container">
            <!-- PROFILE HEADER CARD -->
            <div class="profile-card">
                <div class="profile-header">
                    <div class="profile-avatar">👤</div>
                    <h1 class="profile-name"><asp:Label ID="lblProfileName" runat="server" /></h1>
                    <p class="profile-email"><asp:Label ID="lblProfileEmail" runat="server" /></p>
                </div>

                <div class="profile-body">
                    <!-- STATISTICS -->
                    <div class="stats-grid">
                        <div class="stat-card">
                            <span class="stat-number"><asp:Label ID="lblTotalOrders" runat="server" Text="0" /></span>
                            <div class="stat-label">Total Orders</div>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number"><asp:Label ID="lblRewardPoints" runat="server" Text="0" /></span>
                            <div class="stat-label">Reward Points</div>
                        </div>
                        <div class="stat-card">
                            <span class="stat-number"><asp:Label ID="lblFavorites" runat="server" Text="0" /></span>
                            <div class="stat-label">Favorite Chefs</div>
                        </div>
                    </div>

                    <!-- SUCCESS MESSAGE -->
                    <div class="success-message" id="successMessage">
                        ✅ Profile updated successfully!
                    </div>

                    <!-- PERSONAL INFORMATION -->
                    <h3 class="section-title">📋 Personal Information</h3>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">Full Name</label>
                                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Your full name" />
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">Phone Number</label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="+65 XXXX XXXX" />
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Delivery Address</label>
                        <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Your delivery address" />
                    </div>

                    <!-- PREFERENCES -->
                    <h3 class="section-title mt-5">🍽️ Food Preferences</h3>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">Preferred Cuisine</label>
                                <asp:TextBox ID="txtPreferredCuisine" runat="server" CssClass="form-control" placeholder="e.g., Chinese, Indian, Western" />
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label class="form-label">Dietary Restrictions</label>
                                <asp:TextBox ID="txtDietaryRestrictions" runat="server" CssClass="form-control" placeholder="e.g., Vegetarian, Halal, No Nuts" />
                            </div>
                        </div>
                    </div>

                    <!-- SAVE BUTTON -->
                    <div class="text-center mt-4">
                        <asp:Button ID="btnSaveProfile" runat="server" CssClass="btn-save" Text="💾 Save Changes" OnClick="btnSaveProfile_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Clear success message on input
        document.addEventListener('DOMContentLoaded', () => {
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('input', () => {
                    document.getElementById('successMessage').classList.remove('show');
                });
            });
        });
    </script>
</asp:Content>