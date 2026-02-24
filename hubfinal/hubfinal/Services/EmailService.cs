using System.Net;
using System.Net.Mail;
using Microsoft.Extensions.Configuration;

namespace hubfinal.Services;

public class EmailService
{
    private readonly IConfiguration _config;

    public EmailService(IConfiguration config)
    {
        _config = config;
    }

    public async Task SendOtpAsync(string email, string otp)
    {
        var client = new SmtpClient(_config["Email:SmtpServer"])
        {
            Port = int.Parse(_config["Email:Port"]!),
            Credentials = new NetworkCredential(
                _config["Email:SenderEmail"],
                _config["Email:Password"]
            ),
            EnableSsl = true
        };

        var message = new MailMessage
        {
            From = new MailAddress(_config["Email:SenderEmail"]!, "HVNH HUB"),
            Subject = "OTP Verification",
            Body = $"Your OTP code is: {otp}"
        };

        message.To.Add(email);

        await client.SendMailAsync(message);
    }
}
