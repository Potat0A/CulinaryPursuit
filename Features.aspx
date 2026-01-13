<%@ Page Title="Features" Language="C#" MasterPageFile="~/public.master"
    AutoEventWireup="true" CodeBehind="Features.aspx.cs"
    Inherits="CulinaryPursuit.Features" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

<style>
    .features-hero {
        padding: 100px 20px;
        text-align: center;
    }

    .feature-card {
        border-radius: 25px;
        background: white;
        padding: 35px 25px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        transition: all 0.4s ease;
        height: 100%;
    }

    .feature-card:hover {
        transform: translateY(-12px);
        box-shadow: 0 20px 50px rgba(247,107,28,0.3);
    }

    .feature-icon {
        font-size: 3.5rem;
        margin-bottom: 20px;
    }
</style>

<section class="features-hero">
    <div class="container">
        <h1 class="section-title">Why Culinary Pursuit? ✨</h1>
        <p class="fs-5 mb-5">
            We connect food lovers with passionate home chefs, making every meal personal.
        </p>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">🍳</div>
                    <h5>Authentic Home Cooking</h5>
                    <p>
                        Discover real, home-cooked meals prepared by verified local chefs.
                    </p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">📦</div>
                    <h5>Easy Ordering</h5>
                    <p>
                        Browse menus, customize dishes, and order in just a few clicks.
                    </p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">⭐</div>
                    <h5>Ratings & Reviews</h5>
                    <p>
                        Make confident choices using real customer reviews and chef replies.
                    </p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">💬</div>
                    <h5>Direct Chef Interaction</h5>
                    <p>
                        Communicate directly with chefs for special requests and clarity.
                    </p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">🎁</div>
                    <h5>Rewards System</h5>
                    <p>
                        Earn reward points with every order and redeem exciting perks.
                    </p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="feature-card">
                    <div class="feature-icon">🔐</div>
                    <h5>Secure & Trusted</h5>
                    <p>
                        Secure payments, verified chefs, and trusted user accounts.
                    </p>
                </div>
            </div>
        </div>
    </div>
</section>

</asp:Content>
