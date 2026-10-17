# Windows PowerShell 5.1+ — SSH dynamic forwarding with auto-reconnect.
# Usage: powershell.exe -NoProfile -File .\windows\auto-tunnel.ps1
# Purpose: connects only to 127.0.0.1 VirtualBox NAT forwarding; not a VM launcher.
$ErrorActionPreference = 'Stop'
$configPath = Join-Path $PSScriptRoot 'config.local.ps1'
if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Missing config.local.ps1; copy config.example.ps1 and edit SSHUser."
}
$c = & $configPath
if ($c.SSHUser -eq 'YOUR_SO_USER' -or [string]::IsNullOrWhiteSpace($c.SSHUser)) {
    throw "Edit SSHUser in config.local.ps1 before starting."
}
if (-not (Test-Path -LiteralPath $c.PrivateKey)) {
    throw "SSH key not found at $($c.PrivateKey)"
}
if (-not (Get-Command ssh.exe -ErrorAction SilentlyContinue)) {
    throw 'OpenSSH Client (ssh.exe) is not available.'
}
$target = "$($c.SSHUser)@$($c.SSHHost)"
$sshArgs = @(
    '-N','-T','-q',
    '-i', [string]$c.PrivateKey,
    '-o','BatchMode=yes',
    '-o','IdentitiesOnly=yes',
    '-o','StrictHostKeyChecking=yes',
    '-o','ExitOnForwardFailure=yes',
    '-o','ConnectTimeout=5',
    '-o','ConnectionAttempts=1',
    '-o','ServerAliveInterval=15',
    '-o','ServerAliveCountMax=3',
    '-D', "127.0.0.1:$($c.SOCKSPort)",
    '-p', [string]$c.SSHPort,
    $target
)
Write-Host "SO SOCKS auto-connect: localhost:$($c.SOCKSPort) -> ${target}:$($c.SSHPort)"
Write-Host 'Waiting for Security Onion VM and SSH; Ctrl+C to stop.'
while ($true) {
    & ssh.exe @sshArgs
    $exitCode = $LASTEXITCODE
    Write-Host "SSH disconnected/failed (exit=$exitCode). Reconnecting in $($c.RetrySeconds)s."
    Start-Sleep -Seconds ([int]$c.RetrySeconds)
}
