var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        var allowedOrigins = builder.Configuration.GetSection("AllowedOrigins").Get<string[]>() ?? [];
        policy.WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors();
app.UseHttpsRedirection();

app.MapGet("/api/status", () => new StatusResponse(
    "Connected! The .NET API says hello.",
    Environment.MachineName,
    DateTimeOffset.UtcNow))
    .WithName("GetStatus");

app.Run();

record StatusResponse(string Message, string Server, DateTimeOffset TimestampUtc);
