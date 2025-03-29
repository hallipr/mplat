var platform = Environment.OSVersion.Platform.ToString().ToLowerInvariant();

Console.WriteLine($"Hello {platform}!");

foreach (var arg in args)
{
    await Task.Delay(1000);
    Console.WriteLine($"  '{arg}'");
}
