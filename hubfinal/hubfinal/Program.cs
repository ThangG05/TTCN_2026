using hubfinal.Data;
using hubfinal.Helpers;
using hubfinal.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.StaticFiles;
using System.Text;
using System.Text.Json.Serialization; // Thêm thư viện này

var builder = WebApplication.CreateBuilder(args);

// 1. Cấu hình DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// 2. Cấu hình Controllers + Fix lỗi Vòng lặp JSON (QUAN TRỌNG)
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        // Chặn lỗi vòng lặp dữ liệu khi nạp dữ liệu quan hệ (Posts, Friends)
        options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
        // Đảm bảo trả về camelCase (ví dụ: avatarUrl) để đồng bộ với Flutter
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    });

// 3. Cấu hình CORS để Flutter có thể kết nối (QUAN TRỌNG)
builder.Services.AddCors(options => {
    options.AddPolicy("AllowAll", policy => {
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});

builder.Services.AddScoped<JwtService>();
builder.Services.AddScoped<EmailService>();
builder.Services.AddScoped<CurrentUser>();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<UserService>();

// 4. Cấu hình Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options => {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!)
            )
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Sử dụng CORS đã cấu hình ở trên
app.UseCors("AllowAll");

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection(); // Tạm tắt nếu bạn test localhost không có SSL cho dễ

var provider = new FileExtensionContentTypeProvider();
provider.Mappings[".heif"] = "image/heif";
provider.Mappings[".heic"] = "image/heic";
provider.Mappings[".jpg"] = "image/jpeg";
provider.Mappings[".png"] = "image/png";

app.UseStaticFiles(new StaticFileOptions
{
    ContentTypeProvider = provider
});

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();