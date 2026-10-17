# Read-only connectivity test. Usage: powershell.exe -NoProfile -File .\windows\check-tunnel.ps1
$ErrorActionPreference = 'Stop'
$cpath = Join-Path $PSScriptRoot 'config.local.ps1'
if (-not (Test-Path $cpath)) { throw 'Copy config.example.ps1 to config.local.ps1 first.' }
$c = & $cpath
foreach ($port in @($c.SSHPort, $c.SOCKSPort)) {
    $result = Test-NetConnection -ComputerName '127.0.0.1' -Port ([int]$port) -WarningAction SilentlyContinue
    Write-Host "127.0.0.1:$port TCP = $($result.TcpTestSucceeded)"
}
Write-Host "Checking SOC HTTPS via SOCKS 127.0.0.1:$($c.SOCKSPort) ..."
& curl.exe -k -sS -I --max-time 15 --socks5-hostname "127.0.0.1:$($c.SOCKSPort)" "https://$($c.GuestSocIp)/"
Write-Host "curl exit code: $LASTEXITCODE"
