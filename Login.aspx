<%@ Page Title="Login" Language="C#" MasterPageFile="~/public.master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="CulinaryPursuit.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        /* ═══════════════════════════════════════════════════════════
           🎨 LOGIN PAGE STYLES
        ═══════════════════════════════════════════════════════════ */
        
        .login-container {
            min-height: 90vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            position: relative;
        }

        /* 🎴 Login Card */
        .login-card {
            background: white;
            border-radius: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            overflow: hidden;
            max-width: 900px;
            width: 100%;
            animation: slideUp 0.6s cubic-bezier(0.68, -0.55, 0.265, 1.55);
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(50px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .login-split {
            display: grid;
            grid-template-columns: 1fr 1fr;
            min-height: 600px;
        }

        /* 🎯 Tab Selector */
        .login-tabs {
            display: flex;
            background: #f8f9fa;
            border-radius: 20px 20px 0 0;
            overflow: hidden;
        }

        .tab-btn {
            flex: 1;
            padding: 20px;
            background: transparent;
            border: none;
            font-size: 1.1rem;
            font-weight: 700;
            color: #6c757d;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .tab-btn.active {
            background: white;
            color: #f76b1c;
        }

        .tab-btn.active::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, #f76b1c, #ff9f4d);
        }

        .tab-btn:hover:not(.active) {
            background: rgba(247, 107, 28, 0.1);
            color: #f76b1c;
        }

        .tab-icon {
            font-size: 1.3rem;
            animation: bounce 2s ease-in-out infinite;
        }

        /* 🍽️ Customer Side (Left) */
        .login-side {
            padding: 50px 40px;
            display: none;
        }

        .login-side.active {
            display: block;
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .login-header {
            text-align: center;
            margin-bottom: 35px;
        }

        .login-icon {
            font-size: 4rem;
            margin-bottom: 15px;
            animation: float 3s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .login-title {
            font-size: 2rem;
            font-weight: 800;
            color: #f76b1c;
            margin-bottom: 10px;
        }

        .login-subtitle {
            color: #6c757d;
            font-size: 1rem;
        }

        /* 📝 Form Styles */
        .form-group {
            margin-bottom: 25px;
        }

        .form-label {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            display: block;
            font-size: 0.95rem;
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
            border-color: #f76b1c;
            background: white;
            box-shadow: 0 0 0 4px rgba(247, 107, 28, 0.1);
            transform: translateY(-2px);
        }

        .form-control::placeholder {
            color: #adb5bd;
        }

        /* 🔘 Submit Button */
        .btn-submit {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #f76b1c, #ff9f4d);
            color: white;
            border: none;
            border-radius: 15px;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 6px 20px rgba(247, 107, 28, 0.3);
            margin-top: 10px;
        }

        .btn-submit:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(247, 107, 28, 0.5);
        }

        .btn-submit:active {
            transform: translateY(0);
        }

        /* 🔗 Alternative Login Options */
        .divider {
            text-align: center;
            margin: 25px 0;
            position: relative;
        }

        .divider::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 0;
            width: 100%;
            height: 1px;
            background: #e0e0e0;
        }

        .divider span {
            background: white;
            padding: 0 15px;
            color: #6c757d;
            font-size: 0.9rem;
            position: relative;
            z-index: 1;
        }

        .social-login {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 25px;
        }

        .btn-social {
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            background: white;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-social:hover {
            border-color: #f76b1c;
            background: rgba(247, 107, 28, 0.05);
            transform: translateY(-3px);
        }

        /* 📱 Switch Link */
        .switch-link {
            text-align: center;
            margin-top: 20px;
            color: #6c757d;
        }

        .switch-link a {
            color: #f76b1c;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .switch-link a:hover {
            color: #ff9f4d;
            text-decoration: underline;
        }

        /* 🖼️ Info Side (Right) */
        .info-side {
            background: linear-gradient(135deg, #f76b1c, #ff9f4d);
            padding: 50px 40px;
            color: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }

        .info-side::before {
            content: '🍽️';
            position: absolute;
            font-size: 20rem;
            opacity: 0.1;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-15deg);
            animation: rotate 30s linear infinite;
        }

        @keyframes rotate {
            from { transform: translate(-50%, -50%) rotate(-15deg); }
            to { transform: translate(-50%, -50%) rotate(345deg); }
        }

        .info-content {
            position: relative;
            z-index: 1;
        }

        .info-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 20px;
            text-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }

        .info-features {
            list-style: none;
            margin-top: 30px;
        }

        .info-features li {
            padding: 15px 0;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideInRight 0.6s ease backwards;
        }

        .info-features li:nth-child(1) { animation-delay: 0.2s; }
        .info-features li:nth-child(2) { animation-delay: 0.4s; }
        .info-features li:nth-child(3) { animation-delay: 0.6s; }
        .info-features li:nth-child(4) { animation-delay: 0.8s; }

        @keyframes slideInRight {
            from { opacity: 0; transform: translateX(-30px); }
            to { opacity: 1; transform: translateX(0); }
        }

        .feature-icon {
            font-size: 1.5rem;
            background: rgba(255,255,255,0.2);
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        /* ⚠️ Error Message */
        .error-message {
            background: #fff0f0;
            border: 2px solid #ff6b6b;
            border-radius: 12px;
            padding: 12px 15px;
            color: #d63031;
            margin-bottom: 20px;
            display: none;
            animation: shake 0.5s ease;
        }

        .error-message.show {
            display: block;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }

        /* 📱 RESPONSIVE */
        @media (max-width: 768px) {
            .login-split {
                grid-template-columns: 1fr;
            }

            .info-side {
                display: none;
            }

            .login-side {
                padding: 40px 25px;
            }

            .login-title {
                font-size: 1.6rem;
            }

            .social-login {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <div class="login-container">
        <div class="login-card">
            <!-- Tab Selector -->
            <div class="login-tabs">
                <button type="button" class="tab-btn active" onclick="switchTab('customer')" id="customerTab">
                    <span class="tab-icon">🍽️</span>
                    <span>Customer Login</span>
                </button>
                <button type="button" class="tab-btn" onclick="switchTab('restaurant')" id="restaurantTab">
                    <span class="tab-icon">👨‍🍳</span>
                    <span>Chef Login</span>
                </button>
            </div>

            <div class="login-split">
                <!-- 🍽️ CUSTOMER LOGIN -->
                <div class="login-side active" id="customerLogin">
                    <div class="login-header">
                        <div class="login-icon">🍽️</div>
                        <h2 class="login-title">Welcome Back!</h2>
                        <p class="login-subtitle">Sign in to discover amazing home-cooked meals</p>
                    </div>

                    <div class="error-message" id="customerError">
                        <strong>⚠️ Error:</strong> <span id="customerErrorText"></span>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Email Address</label>
                        <asp:TextBox ID="txtCustomerEmail" runat="server" CssClass="form-control" 
                                     placeholder="you@example.com" TextMode="Email" />
                    </div>

                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <asp:TextBox ID="txtCustomerPassword" runat="server" CssClass="form-control" 
                                     placeholder="Enter your password" TextMode="Password" />
                    </div>

                    <asp:Button ID="btnCustomerLogin" runat="server" CssClass="btn-submit" 
                                Text="🚀 Sign In" OnClick="btnCustomerLogin_Click" />

                    <div class="divider"><span>or continue with</span></div>

                    <div class="social-login">
                        <button type="button" class="btn-social" onclick="socialLogin('google')">
                            <span>📧</span> Google
                        </button>
                        <button type="button" class="btn-social" onclick="socialLogin('facebook')">
                            <span>📘</span> Facebook
                        </button>
                    </div>

                    <div class="switch-link">
                        Don't have an account? <a href="Signup.aspx?type=customer">Sign Up as Customer</a>
                    </div>
                </div>

                <!-- 👨‍🍳 RESTAURANT/CHEF LOGIN -->
                <div class="login-side" id="restaurantLogin">
                    <div class="login-header">
                        <div class="login-icon">👨‍🍳</div>
                        <h2 class="login-title">Chef Portal</h2>
                        <p class="login-subtitle">Access your kitchen dashboard</p>
                    </div>

                    <div class="error-message" id="restaurantError">
                        <strong>⚠️ Error:</strong> <span id="restaurantErrorText"></span>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Business Email</label>
                        <asp:TextBox ID="txtRestaurantEmail" runat="server" CssClass="form-control" 
                                     placeholder="chef@kitchen.com" TextMode="Email" />
                    </div>

                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <asp:TextBox ID="txtRestaurantPassword" runat="server" CssClass="form-control" 
                                     placeholder="Enter your password" TextMode="Password" />
                    </div>

                    <asp:Button ID="btnRestaurantLogin" runat="server" CssClass="btn-submit" 
                                Text="👨‍🍳 Sign In to Dashboard" OnClick="btnRestaurantLogin_Click" />

                    <div class="switch-link" style="margin-top: 30px;">
                        New chef? <a href="Signup.aspx?type=restaurant">Register Your Kitchen</a>
                    </div>
                </div>

                <!-- INFO SIDE -->
                <div class="info-side">
                    <div class="info-content">
                        <h3 class="info-title" id="infoTitle">Discover Home-Cooked Magic ✨</h3>
                        <ul class="info-features" id="infoFeatures">
                            <li><span class="feature-icon">🔍</span> Browse 500+ home chefs</li>
                            <li><span class="feature-icon">🌤️</span> Smart weather-based recommendations</li>
                            <li><span class="feature-icon">🏆</span> Earn rewards with every order</li>
                            <li><span class="feature-icon">💬</span> Chat directly with chefs</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function switchTab(type) {
            // Update tabs
            document.getElementById('customerTab').classList.remove('active');
            document.getElementById('restaurantTab').classList.remove('active');
            
            // Update content
            document.getElementById('customerLogin').classList.remove('active');
            document.getElementById('restaurantLogin').classList.remove('active');

            if (type === 'customer') {
                document.getElementById('customerTab').classList.add('active');
                document.getElementById('customerLogin').classList.add('active');
                updateInfoSide('customer');
            } else {
                document.getElementById('restaurantTab').classList.add('active');
                document.getElementById('restaurantLogin').classList.add('active');
                updateInfoSide('restaurant');
            }
        }

        function updateInfoSide(type) {
            const title = document.getElementById('infoTitle');
            const features = document.getElementById('infoFeatures');

            if (type === 'customer') {
                title.textContent = 'Discover Home-Cooked Magic ✨';
                features.innerHTML = `
                    <li><span class="feature-icon">🔍</span> Browse 500+ home chefs</li>
                    <li><span class="feature-icon">🌤️</span> Smart weather-based recommendations</li>
                    <li><span class="feature-icon">🏆</span> Earn rewards with every order</li>
                    <li><span class="feature-icon">💬</span> Chat directly with chefs</li>
                `;
            } else {
                title.textContent = 'Grow Your Kitchen Business 🚀';
                features.innerHTML = `
                    <li><span class="feature-icon">📊</span> Advanced analytics dashboard</li>
                    <li><span class="feature-icon">💰</span> Secure payment processing</li>
                    <li><span class="feature-icon">📱</span> Easy order management</li>
                    <li><span class="feature-icon">⭐</span> Build your reputation</li>
                `;
            }
        }

        function socialLogin(provider) {
            if (provider === 'google') {
                window.location.href = 'GoogleLogin.aspx';
            }
        }


        // Clear errors on input
        document.addEventListener('DOMContentLoaded', () => {
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('input', () => {
                    document.querySelectorAll('.error-message').forEach(err => {
                        err.classList.remove('show');
                    });
                });
            });
        });
    </script>
</asp:Content>