# Servidor estático mínimo para pré-visualizar o site sem instalar nada.
# Uso: powershell -File .claude/serve.ps1   (depois abra http://localhost:4173/)
param(
  [int]$Port = 4173,
  [string]$Root = (Join-Path $PSScriptRoot "..\linkwave-tcc-reformulado")
)

$root = (Resolve-Path $Root).Path
$mime = @{
  ".html" = "text/html; charset=utf-8"
  ".css" = "text/css; charset=utf-8"
  ".js" = "text/javascript; charset=utf-8"
  ".json" = "application/json"
  ".svg" = "image/svg+xml"
  ".png" = "image/png"
  ".webp" = "image/webp"
  ".ico" = "image/x-icon"
  ".woff2" = "font/woff2"
  ".txt" = "text/plain; charset=utf-8"
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Servindo $root em http://localhost:$Port/"

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $relative = [Uri]::UnescapeDataString($context.Request.Url.AbsolutePath).TrimStart("/")
    if ($relative -eq "" -or $relative.EndsWith("/")) { $relative += "index.html" }
    $path = [IO.Path]::GetFullPath((Join-Path $root $relative))

    # Só entrega arquivos de dentro da pasta do site.
    if ($path.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $path -PathType Leaf)) {
      $bytes = [IO.File]::ReadAllBytes($path)
      $extension = [IO.Path]::GetExtension($path).ToLower()
      $context.Response.ContentType = if ($mime.ContainsKey($extension)) { $mime[$extension] } else { "application/octet-stream" }
      $context.Response.Headers["Cache-Control"] = "no-store"
      $context.Response.ContentLength64 = $bytes.Length
      if ($context.Request.HttpMethod -ne "HEAD") { $context.Response.OutputStream.Write($bytes, 0, $bytes.Length) }
    } else {
      $context.Response.StatusCode = 404
    }

    Write-Host "$($context.Response.StatusCode) $($context.Request.HttpMethod) /$relative"
    $context.Response.Close()
  }
} finally {
  $listener.Stop()
}
