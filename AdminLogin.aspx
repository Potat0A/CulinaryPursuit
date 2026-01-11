<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminLogin.aspx.cs" Inherits="CulinaryPursuit.AdminLogin" %>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Login | Culinary Pursuit</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #f76b1c, #ff9f4d);
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }

        .login-card {
            background: #fff;
            padding: 40px 50px;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            text-align: center;
            width: 400px;
        }

        h2 {
            color: #f76b1c;
            margin-bottom: 30px;
        }

        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }

        label {
            display: block;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }

        input[type=text],
        input[type=password] {
            width: 100%;
            padding: 12px 15px;
            border-radius: 10px;
            border: 2px solid #eee;
            font-size: 1rem;
        }

        input[type=submit] {
            background: linear-gradient(135deg, #f76b1c, #ff9f4d);
            border: none;
            padding: 14px;
            color: white;
            width: 100%;
            border-radius: 12px;
            font-weight: 700;
            cursor: pointer;
            font-size: 1rem;
        }

        input[type=submit]:hover {
            opacity: 0.9;
        }

        .error {
            color: #d63031;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <form runat="server">
        <div class="login-card">
            <h2>Admin Login</h2>

            <asp:Label ID="lblError" runat="server" CssClass="error" Visible="false" />

            <div class="form-group">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server" placeholder="admin@culinarypursuit.com" />
            </div>

            <div class="form-group">
                <label>Password</label>
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Enter password" />
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="Sign In" OnClick="btnLogin_Click" />
        </div>
    </form>
</body>
</html>
