# Copy to config.local.ps1 (gitignored); edit SSHUser before use.
@{
  SSHUser = 'YOUR_SO_USER'
  SSHHost = '127.0.0.1'
  SSHPort = 2222
  SOCKSPort = 1080
  GuestSocIp = '10.0.2.15'
  PrivateKey = "$env:USERPROFILE\.ssh\so_lab_ed25519"
  RetrySeconds = 10
}
