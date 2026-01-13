<%@ Page Title="Contact Us" Language="C#" MasterPageFile="~/public.master"
AutoEventWireup="true" CodeBehind="Contact.aspx.cs"
Inherits="CulinaryPursuit.Contact" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <style>
    .contact-hero {
        padding: 100px 20px;
    }

    .contact-card {
        background: white;
        border-radius: 25px;
        padding: 40px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
    }

    .contact-icon {
        font-size: 2rem;
        margin-right: 10px;
        color: #f76b1c;
    }
</style>

    <section class="contact-hero">
        <div class="container">
            <h1 class="section-title text-center">Get in Touch 📬</h1>
            <p class="text-center fs-5 mb-5">
                Have a question or feedback? We’d love to hear from you.
            </p>

            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="contact-card">

                        <p>
                            <span class="contact-icon">📍</span>
                            <strong>Address:</strong> Singapore
                        </p>

                        <p>
                            <span class="contact-icon">📧</span>
                            <strong>Email:</strong> support@culinarypursuit.sg
                        </p>

                        <p>
                            <span class="contact-icon">📞</span>
                            <strong>Phone:</strong> +65 6123 4567
                        </p>

                        <hr />

                        <p class="fw-semibold">
                            Business Hours
                        </p>
                        <p>
                            Monday – Friday: 9:00 AM – 6:00 PM<br />
                            Saturday – Sunday: 10:00 AM – 4:00 PM
                        </p>

                    </div>
                </div>
            </div>
        </div>
    </section>

</asp:Content>