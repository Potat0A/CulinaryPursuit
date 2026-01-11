<%@ Page Title="Home" Language="C#" MasterPageFile="~/public.master" AutoEventWireup="true" CodeBehind="Landing.aspx.cs" Inherits="CulinaryPursuit.Landing" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        /* ═══════════════════════════════════════════════════════════
           🎨 HERO SECTION WITH ADVANCED ANIMATIONS
        ═══════════════════════════════════════════════════════════ */
        
        .hero-section {
            position: relative;
            min-height: 100vh;
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

        /* 🍕 Enhanced Floating Food with Multiple Animations */
        .floating-food {
            position: absolute;
            font-size: 4rem;
            opacity: 0.3;
            animation: float 8s ease-in-out infinite, rotate 15s linear infinite, pulse 3s ease-in-out infinite;
            filter: drop-shadow(0 5px 15px rgba(0,0,0,0.3));
            transition: all 0.3s ease;
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

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
        }

        .floating-food:nth-child(1) { top: 10%; left: 5%; animation-delay: 0s, 1s, 0.5s; }
        .floating-food:nth-child(2) { bottom: 15%; right: 8%; animation-delay: 1s, 2s, 1s; }
        .floating-food:nth-child(3) { top: 20%; right: 15%; animation-delay: 2s, 3s, 1.5s; }
        .floating-food:nth-child(4) { bottom: 25%; left: 10%; animation-delay: 1.5s, 0s, 2s; font-size: 3rem; }
        .floating-food:nth-child(5) { top: 40%; left: 20%; animation-delay: 2.5s, 4s, 0s; font-size: 3.5rem; }
        .floating-food:nth-child(6) { top: 50%; right: 5%; animation-delay: 3s, 1.5s, 2.5s; font-size: 3rem; }

        /* ✨ Sparkle Effects */
        .sparkle {
            position: absolute;
            width: 4px;
            height: 4px;
            background: white;
            border-radius: 50%;
            animation: sparkleFloat 4s ease-in-out infinite;
            box-shadow: 0 0 10px rgba(255,255,255,0.8);
        }

        @keyframes sparkleFloat {
            0%, 100% { transform: translateY(0) scale(0); opacity: 0; }
            50% { opacity: 1; transform: translateY(-100px) scale(1); }
        }

        /* 📝 Enhanced Text Effects */
        .hero-title {
            font-size: 4rem;
            font-weight: 900;
            text-shadow: 0 8px 30px rgba(0,0,0,0.4);
            animation: fadeInUp 1.2s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            background: linear-gradient(45deg, #fff, #ffe4b5, #fff);
            background-size: 200% auto;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            animation: fadeInUp 1.2s ease, shimmer 3s linear infinite;
        }

        @keyframes shimmer {
            to { background-position: 200% center; }
        }

        .hero-subtitle {
            font-size: 1.5rem;
            margin-top: 20px;
            opacity: 0;
            animation: fadeInUp 1.5s ease forwards;
            animation-delay: 0.3s;
            text-shadow: 0 4px 15px rgba(0,0,0,0.3);
        }

        /* 🎯 Enhanced CTA Button */
        .btn-cta {
            background: white;
            color: #ff3c00;
            font-weight: 800;
            border-radius: 50px;
            padding: 18px 50px;
            font-size: 1.3rem;
            margin-top: 40px;
            border: 3px solid white;
            opacity: 0;
            animation: fadeInUp 1.8s ease forwards, btnGlow 2s ease-in-out infinite;
            animation-delay: 0.6s, 2s;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            position: relative;
            overflow: hidden;
        }

        .btn-cta::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.5);
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }

        .btn-cta:hover::before {
            width: 300px;
            height: 300px;
        }

        .btn-cta:hover {
            transform: translateY(-5px) scale(1.05);
            box-shadow: 0 15px 50px rgba(0,0,0,0.4);
            background: #ffe4b5;
        }

        @keyframes btnGlow {
            0%, 100% { box-shadow: 0 10px 40px rgba(255,60,0,0.3); }
            50% { box-shadow: 0 10px 60px rgba(255,60,0,0.6), 0 0 30px rgba(255,255,255,0.5); }
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(50px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* 🌊 Enhanced Waves */
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
        .wave:nth-child(9) { bottom: 30px; animation-duration: 18s; opacity: 0.2; animation-delay: 4s; }

        @keyframes waveAnim {
            0% { transform: translateX(-25%) translateZ(0) scaleY(1); }
            50% { transform: translateX(-50%) translateZ(0) scaleY(0.9); }
            100% { transform: translateX(-75%) translateZ(0) scaleY(1); }
        }

        /* ═══════════════════════════════════════════════════════════
           📋 SECTIONS WITH SCROLL ANIMATIONS
        ═══════════════════════════════════════════════════════════ */
        
        section {
            padding: 100px 0;
            position: relative;
            overflow: hidden;
        }

        .scroll-reveal {
            opacity: 0;
            transform: translateY(50px);
            transition: all 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55);
        }

        .scroll-reveal.active {
            opacity: 1;
            transform: translateY(0);
        }

        .section-title {
            font-weight: 800;
            font-size: 3rem;
            color: #ff3c00;
            margin-bottom: 60px;
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
            animation: underlineGrow 2s ease infinite;
        }

        @keyframes underlineGrow {
            0%, 100% { width: 80px; }
            50% { width: 120px; }
        }

        /* 🎴 Enhanced Cards */
        .card {
            border: none;
            border-radius: 25px;
            transition: all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            background: white;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
            position: relative;
        }

        .card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            transition: left 0.5s;
        }

        .card:hover::before {
            left: 100%;
        }

        .card:hover {
            transform: translateY(-15px) scale(1.03);
            box-shadow: 0 20px 50px rgba(255,60,0,0.2);
        }

        .card img {
            transition: transform 0.4s ease;
            height: 250px;
            object-fit: cover;
        }

        .card:hover img {
            transform: scale(1.1) rotate(2deg);
        }

        .card-body {
            padding: 25px;
        }

        .card-body h5 {
            color: #ff3c00;
            font-weight: 700;
            margin-bottom: 15px;
        }

        /* 🎯 Step Cards with Number Badges */
        .step-card {
            position: relative;
            padding-top: 40px;
        }

        .step-badge {
            position: absolute;
            top: -20px;
            left: 50%;
            transform: translateX(-50%);
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #ff3c00, #ff9a3c);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 800;
            font-size: 1.5rem;
            box-shadow: 0 5px 20px rgba(255,60,0,0.4);
            animation: bounce 2s ease-in-out infinite;
        }

        @keyframes bounce {
            0%, 100% { transform: translateX(-50%) translateY(0); }
            50% { transform: translateX(-50%) translateY(-10px); }
        }

        /* 🌟 Chef Cards */
        .chef-card {
            background: linear-gradient(135deg, #fff 0%, #ffe4b5 100%);
            border: 3px solid transparent;
            background-clip: padding-box;
            position: relative;
        }

        .chef-card::after {
            content: '';
            position: absolute;
            top: 0; right: 0; bottom: 0; left: 0;
            z-index: -1;
            margin: -3px;
            border-radius: inherit;
            background: linear-gradient(135deg, #ff3c00, #ff9a3c);
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
            animation: pulse 2s ease-in-out infinite;
        }

        /* 💼 Join Section */
        .join-section {
            background: linear-gradient(135deg, #ff3c00 0%, #ff9a3c 50%, #ffb347 100%);
            background-size: 200% 200%;
            animation: gradientShift 8s ease infinite;
            color: white;
            position: relative;
            overflow: hidden;
        }

        .join-section::before {
            content: '🍳';
            position: absolute;
            font-size: 20rem;
            opacity: 0.1;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-15deg);
            animation: rotate 20s linear infinite;
        }

        .join-section h2 {
            font-size: 3rem;
            font-weight: 800;
            margin-bottom: 20px;
            text-shadow: 0 5px 20px rgba(0,0,0,0.3);
        }

        .join-section .btn {
            background: white;
            color: #ff3c00;
            font-weight: 800;
            padding: 15px 50px;
            border-radius: 50px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            transition: all 0.3s ease;
            margin-top: 20px;
        }

        .join-section .btn:hover {
            transform: translateY(-5px) scale(1.05);
            box-shadow: 0 15px 50px rgba(0,0,0,0.4);
            background: #ffe4b5;
        }

        /* 🎬 Icon Animations */
        .animated-icon {
            display: inline-block;
            animation: iconBounce 2s ease-in-out infinite;
        }

        @keyframes iconBounce {
            0%, 100% { transform: translateY(0) scale(1); }
            50% { transform: translateY(-10px) scale(1.1); }
        }

        /* ═══════════════════════════════════════════════════════════
           📱 RESPONSIVE
        ═══════════════════════════════════════════════════════════ */
        
        @media (max-width: 992px) {
            .hero-title { font-size: 3rem; }
            .hero-subtitle { font-size: 1.2rem; }
            .section-title { font-size: 2.5rem; }
            .floating-food { font-size: 3rem; opacity: 0.2; }
        }

        @media (max-width: 768px) {
            .hero-title { font-size: 2.2rem; }
            .hero-subtitle { font-size: 1rem; }
            .btn-cta { padding: 15px 35px; font-size: 1.1rem; }
            .section-title { font-size: 2rem; }
            .join-section h2 { font-size: 2rem; }
            .floating-food:nth-child(n+4) { display: none; }
        }

        @media (max-width: 576px) {
            section { padding: 60px 0; }
            .wave { height: 80px; }
            .card img { height: 200px; }
        }
    </style>

    <!-- 🌟 HERO SECTION -->
    <section class="hero-section">
        <!-- Floating Food Emojis -->
        <div class="floating-food">🍔</div>
        <div class="floating-food">🍕</div>
        <div class="floating-food">🍣</div>
        <div class="floating-food">🍜</div>
        <div class="floating-food">🥘</div>
        <div class="floating-food">🍰</div>

        <!-- Sparkles -->
        <div class="sparkle" style="top: 20%; left: 10%; animation-delay: 0s;"></div>
        <div class="sparkle" style="top: 40%; left: 80%; animation-delay: 1s;"></div>
        <div class="sparkle" style="top: 60%; left: 15%; animation-delay: 2s;"></div>
        <div class="sparkle" style="top: 30%; left: 70%; animation-delay: 1.5s;"></div>
        <div class="sparkle" style="top: 70%; left: 50%; animation-delay: 2.5s;"></div>

        <div class="container" style="position: relative; z-index: 10;">
            <h1 class="hero-title">Discover Home-Cooked Flavours 🍲</h1>
            <p class="hero-subtitle">Find, order, and enjoy authentic food from Singapore's best home chefs.</p>
            <a href="Login.aspx" class="btn btn-cta">🚀 Start Your Journey</a>
        </div>

        <div class="wave"></div>
        <div class="wave"></div>
        <div class="wave"></div>
    </section>

    <!-- 🧭 HOW IT WORKS -->
    <section class="text-center bg-white">
        <div class="container">
            <h2 class="section-title scroll-reveal">How It Works ✨</h2>
            <div class="row g-4">
                <div class="col-md-4 col-sm-12">
                    <div class="card step-card h-100 scroll-reveal" style="transition-delay: 0.1s;">
                        <div class="step-badge">1</div>
                        <div class="card-body">
                            <div class="animated-icon" style="font-size: 4rem;">🔍</div>
                            <h5 class="fw-bold mt-3">Discover</h5>
                            <p>Explore local home-based chefs nearby and find hidden gems through AI recommendations.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 col-sm-12">
                    <div class="card step-card h-100 scroll-reveal" style="transition-delay: 0.2s;">
                        <div class="step-badge">2</div>
                        <div class="card-body">
                            <div class="animated-icon" style="font-size: 4rem; animation-delay: 0.5s;">🛒</div>
                            <h5 class="fw-bold mt-3">Order</h5>
                            <p>Place your order securely, track it live, and chat directly with your chef.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 col-sm-12">
                    <div class="card step-card h-100 scroll-reveal" style="transition-delay: 0.3s;">
                        <div class="step-badge">3</div>
                        <div class="card-body">
                            <div class="animated-icon" style="font-size: 4rem; animation-delay: 1s;">🎉</div>
                            <h5 class="fw-bold mt-3">Enjoy & Earn</h5>
                            <p>Receive your meal, leave a review, and earn rewards for your next order.</p>
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 👩‍🍳 FEATURED HOME CHEFS -->
    <section class="bg-light text-center">
        <div class="container">
            <h2 class="section-title scroll-reveal">Featured Home Chefs 👨‍🍳</h2>
            <div class="row g-4">
                <div class="col-md-4 col-sm-12">
                    <div class="card chef-card scroll-reveal" style="transition-delay: 0.1s;">
                        <div class="chef-badge">⭐ Featured</div>
                        <img src="https://images.unsplash.com/photo-1551218808-94e220e084d2?w=400" class="card-img-top" alt="Laksa" />
                        <div class="card-body">
                            <h5>Auntie Mei's Laksa 🍜</h5>
                            <p>Authentic Peranakan flavours from her kitchen.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 col-sm-12">
                    <div class="card chef-card scroll-reveal" style="transition-delay: 0.2s;">
                        <div class="chef-badge">🔥 Hot</div>
                        <img src="https://images.unsplash.com/photo-1617196034796-73dfa83b9b33?w=400" class="card-img-top" alt="Curry" />
                        <div class="card-body">
                            <h5>The Curry Corner 🍛</h5>
                            <p>Spice up your day with aromatic Indian curries and roti.</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 col-sm-12">
                    <div class="card chef-card scroll-reveal" style="transition-delay: 0.3s;">
                        <div class="chef-badge">💝 Popular</div>
                        <img src="https://images.unsplash.com/photo-1565958011705-44e211a19f9a?w=400" class="card-img-top" alt="Pastry" />
                        <div class="card-body">
                            <h5>Bakeology by Sam 🧁</h5>
                            <p>Freshly baked pastries that melt in your mouth.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 💼 JOIN SECTION -->
    <section class="join-section text-center">
        <div class="container py-5 scroll-reveal">
            <h2>Are You a Home Chef? 👨‍🍳</h2>
            <p class="fs-5">Join our platform to share your passion and reach customers across Singapore.</p>
            <a href="SignupSeller.aspx" class="btn btn-lg">✨ Join as a Seller</a>
        </div>
    </section>

    <script>
        // 🎬 Scroll Reveal Animation
        const observerOptions = {
            threshold: 0.2,
            rootMargin: '0px 0px -100px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('active');
                }
            });
        }, observerOptions);

        document.querySelectorAll('.scroll-reveal').forEach(el => {
            observer.observe(el);
        });

        // 🎨 Parallax Effect
        window.addEventListener('scroll', () => {
            const scrolled = window.pageYOffset;
            const parallaxElements = document.querySelectorAll('.floating-food');
            parallaxElements.forEach((el, index) => {
                const speed = 0.5 + (index * 0.1);
                el.style.transform = `translateY(${scrolled * speed}px)`;
            });
        });

        // ✨ Add Random Sparkles
        function createSparkle() {
            const hero = document.querySelector('.hero-section');
            const sparkle = document.createElement('div');
            sparkle.className = 'sparkle';
            sparkle.style.left = Math.random() * 100 + '%';
            sparkle.style.top = Math.random() * 100 + '%';
            sparkle.style.animationDelay = Math.random() * 2 + 's';
            hero.appendChild(sparkle);

            setTimeout(() => sparkle.remove(), 4000);
        }

        setInterval(createSparkle, 800);

        // 🎯 Button Ripple Effect
        document.querySelectorAll('.btn-cta, .join-section .btn').forEach(button => {
            button.addEventListener('click', function (e) {
                const ripple = document.createElement('span');
                ripple.style.cssText = `
                    position: absolute;
                    border-radius: 50%;
                    background: rgba(255,255,255,0.6);
                    width: 100px;
                    height: 100px;
                    left: ${e.offsetX - 50}px;
                    top: ${e.offsetY - 50}px;
                    animation: ripple 0.6s ease-out;
                    pointer-events: none;
                `;
                this.appendChild(ripple);
                setTimeout(() => ripple.remove(), 600);
            });
        });

        // Add ripple animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes ripple {
                to {
                    transform: scale(4);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
    </script>
</asp:Content>