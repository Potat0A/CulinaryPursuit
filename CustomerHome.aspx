<%@ Page Title="Home" Language="C#" MasterPageFile="~/customer.master" AutoEventWireup="true" CodeBehind="CustomerHome.aspx.cs" Inherits="CulinaryPursuit.CustomerHome" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        /* ═══════════════════════════════════════════════════════════
           🎨 HERO SECTION WITH ADVANCED ANIMATIONS
        ═══════════════════════════════════════════════════════════ */
        
        .hero-section {
            position: relative;
            min-height: 80vh;
            background: linear-gradient(135deg, #ff7b00, #ff3c00, #ff9a3c, #ffb347);
            background-size: 400% 400%;
            animation: gradientShift 12s ease-in-out infinite;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            overflow: hidden;
            color: white;
            padding: 0 20px;
        }

        @keyframes gradientShift {
            0%, 100% { background-position: 0% 50%; }
            25% { background-position: 50% 75%; }
            50% { background-position: 100% 50%; }
            75% { background-position: 50% 25%; }
        }

        /* 🍕 Enhanced Floating Food */
        .floating-food {
            position: absolute;
            font-size: 4rem;
            opacity: 0.3;
            animation: float 8s ease-in-out infinite, rotate 15s linear infinite;
            filter: drop-shadow(0 5px 15px rgba(0,0,0,0.3));
        }

        .floating-food:hover {
            transform: scale(1.3) rotate(15deg);
            opacity: 0.6;
            cursor: pointer;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-40px); }
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        .floating-food:nth-child(1) { top: 10%; left: 5%; animation-delay: 0s; }
        .floating-food:nth-child(2) { bottom: 15%; right: 8%; animation-delay: 1s; }
        .floating-food:nth-child(3) { top: 20%; right: 15%; animation-delay: 2s; }
        .floating-food:nth-child(4) { bottom: 25%; left: 10%; animation-delay: 1.5s; font-size: 3rem; }
        .floating-food:nth-child(5) { top: 40%; left: 20%; animation-delay: 2.5s; font-size: 3.5rem; }
        .floating-food:nth-child(6) { top: 50%; right: 5%; animation-delay: 3s; font-size: 3rem; }

        .hero-title {
            font-size: 3.5rem;
            font-weight: 900;
            text-shadow: 0 8px 30px rgba(0,0,0,0.4);
            animation: fadeInUp 1.2s ease;
            background: linear-gradient(45deg, #fff, #ffe4b5, #fff);
            background-size: 200% auto;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero-subtitle {
            font-size: 1.3rem;
            margin-top: 20px;
            animation: fadeInUp 1.5s ease;
            text-shadow: 0 4px 15px rgba(0,0,0,0.3);
        }

        .btn-cta {
            background: white;
            color: #ff3c00;
            font-weight: 800;
            border-radius: 50px;
            padding: 18px 50px;
            font-size: 1.3rem;
            margin-top: 40px;
            border: 3px solid white;
            animation: fadeInUp 1.8s ease;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            transition: all 0.3s ease;
        }

        .btn-cta:hover {
            transform: translateY(-5px) scale(1.05);
            box-shadow: 0 15px 50px rgba(0,0,0,0.4);
            background: #ffe4b5;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(50px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .wave {
            position: absolute;
            bottom: -5px;
            left: 0;
            width: 200%;
            height: 120px;
            background: rgba(255,255,255,0.15);
            border-radius: 100%;
            animation: waveAnim 12s cubic-bezier(0.36, 0.45, 0.63, 0.53) infinite;
        }

        .wave:nth-child(7) { bottom: -5px; animation-duration: 12s; opacity: 0.4; }
        .wave:nth-child(8) { bottom: 15px; animation-duration: 15s; opacity: 0.3; animation-delay: 2s; }

        @keyframes waveAnim {
            0% { transform: translateX(-25%) translateZ(0) scaleY(1); }
            50% { transform: translateX(-50%) translateZ(0) scaleY(0.9); }
            100% { transform: translateX(-75%) translateZ(0) scaleY(1); }
        }

        /* ═══════════════════════════════════════════════════════════
           📋 SECTIONS
        ═══════════════════════════════════════════════════════════ */
        
        section {
            padding: 80px 0;
        }

        .section-title {
            font-weight: 800;
            font-size: 2.5rem;
            color: #ff3c00;
            margin-bottom: 50px;
            position: relative;
            display: inline-block;
        }

        .section-title::after {
            content: '';
            position: absolute;
            bottom: -15px;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 5px;
            background: linear-gradient(90deg, #ff3c00, #ff9a3c);
            border-radius: 10px;
        }

        /* 🎴 Cards */
        .card {
            border: none;
            border-radius: 25px;
            transition: all 0.4s ease;
            background: white;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
            height: 100%;
        }

        .card:hover {
            transform: translateY(-15px);
            box-shadow: 0 20px 50px rgba(255,60,0,0.2);
        }

        .card img {
            transition: transform 0.4s ease;
            height: 250px;
            object-fit: cover;
        }

        .card:hover img {
            transform: scale(1.1);
        }

        .card-body {
            padding: 25px;
        }

        .card-body h5 {
            color: #ff3c00;
            font-weight: 700;
            margin-bottom: 15px;
        }

        .chef-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            background: #ff3c00;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
            font-weight: 700;
            box-shadow: 0 3px 10px rgba(255,60,0,0.4);
        }

        /* 📱 RESPONSIVE */
        @media (max-width: 768px) {
            .hero-title { font-size: 2.5rem; }
            .hero-subtitle { font-size: 1.1rem; }
            .section-title { font-size: 2rem; }
            .floating-food { font-size: 2.5rem; }
        }
    </style>

    <!-- 🌟 HERO SECTION -->
    <section class="hero-section">
        <div class="floating-food">🍔</div>
        <div class="floating-food">🍕</div>
        <div class="floating-food">🍣</div>
        <div class="floating-food">🍜</div>
        <div class="floating-food">🥘</div>
        <div class="floating-food">🍰</div>

        <div class="container" style="position: relative; z-index: 10;">
            <h1 class="hero-title">Welcome back, <asp:Label ID="lblCustomerName" runat="server" />! 🍲</h1>
            <p class="hero-subtitle">Ready to discover your next favorite meal?</p>
            <a href="BrowseChefs.aspx" class="btn btn-cta">🔍 Browse Chefs</a>
        </div>

        <div class="wave"></div>
        <div class="wave"></div>
    </section>

    <!-- 👩‍🍳 FEATURED HOME CHEFS -->
    <section class="bg-light text-center">
        <div class="container">
            <h2 class="section-title">Featured Home Chefs 👨‍🍳</h2>
            <div class="row g-4">
                <div class="col-md-4 col-sm-12">
                    <div class="card">
                        <div class="chef-badge">⭐ Featured</div>
                        <img src="https://images.unsplash.com/photo-1551218808-94e220e084d2?w=400" class="card-img-top" alt="Laksa" />
                        <div class="card-body">
                            <h5>Auntie Mei's Laksa 🍜</h5>
                            <p>Authentic Peranakan flavours from her kitchen.</p>
                            <a href="ChefProfile.aspx?id=1" class="btn btn-sm" style="background:#ff3c00;color:white;border-radius:20px;">View Menu</a>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 col-sm-12">
                    <div class="card">
                        <div class="chef-badge">🔥 Hot</div>
                        <img src="https://images.unsplash.com/photo-1617196034796-73dfa83b9b33?w=400" class="card-img-top" alt="Curry" />
                        <div class="card-body">
                            <h5>The Curry Corner 🍛</h5>
                            <p>Spice up your day with aromatic Indian curries.</p>
                            <a href="ChefProfile.aspx?id=2" class="btn btn-sm" style="background:#ff3c00;color:white;border-radius:20px;">View Menu</a>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 col-sm-12">
                    <div class="card">
                        <div class="chef-badge">💝 Popular</div>
                        <img src="https://images.unsplash.com/photo-1565958011705-44e211a19f9a?w=400" class="card-img-top" alt="Pastry" />
                        <div class="card-body">
                            <h5>Bakeology by Sam 🧁</h5>
                            <p>Freshly baked pastries that melt in your mouth.</p>
                            <a href="ChefProfile.aspx?id=3" class="btn btn-sm" style="background:#ff3c00;color:white;border-radius:20px;">View Menu</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 🎯 QUICK ACTIONS -->
    <section class="bg-white text-center">
        <div class="container">
            <h2 class="section-title">Quick Actions ⚡</h2>
            <div class="row g-4">
                <div class="col-md-3">
                    <a href="BrowseChefs.aspx" class="card text-decoration-none">
                        <div class="card-body">
                            <div style="font-size:3rem;">🔍</div>
                            <h5 class="mt-3">Browse Chefs</h5>
                        </div>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="MyOrders.aspx" class="card text-decoration-none">
                        <div class="card-body">
                            <div style="font-size:3rem;">📦</div>
                            <h5 class="mt-3">My Orders</h5>
                        </div>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="Favorites.aspx" class="card text-decoration-none">
                        <div class="card-body">
                            <div style="font-size:3rem;">❤️</div>
                            <h5 class="mt-3">Favorites</h5>
                        </div>
                    </a>
                </div>
                <div class="col-md-3">
                    <a href="CustomerProfile.aspx" class="card text-decoration-none">
                        <div class="card-body">
                            <div style="font-size:3rem;">👤</div>
                            <h5 class="mt-3">My Profile</h5>
                        </div>
                    </a>
                </div>
            </div>
        </div>
    </section>
</asp:Content>