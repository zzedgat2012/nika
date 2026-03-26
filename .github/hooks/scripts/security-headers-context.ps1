$payload = @{
  continue = $true
  systemMessage = "Security Header policy loaded: use hooks/security_headers.lua in after_request to set X-Frame-Options=DENY, X-Content-Type-Options=nosniff, Strict-Transport-Security and Content-Security-Policy default-src 'self'."
}

$payload | ConvertTo-Json -Compress
exit 0
