#!/usr/bin/env bash
# Read-only Security Onion lab diagnostic helper.
# Run inside Security Onion guest. Verify/redact output before sharing.
set -u

section(){ printf '\n========== %s ==========\n' "$1"; }
run(){ printf '\n$'; printf ' %q' "$@"; printf '\n'; "$@" 2>&1 || printf '[WARN] command returned non-zero: %s\n' "$1"; }

section "HOSTNAME / DATE"
run hostname
run date -Is
section "RESOURCES"
run nproc
run free -h
run df -h
run df -i
section "NETWORK"
run ip -br addr
run ip route
section "DNS"
run getent hosts sigs.securityonion.net
run getent hosts ghcr.io
section "HTTPS CONNECTIVITY"
run curl -Iv --connect-timeout 10 --max-time 20 https://ghcr.io/v2/
section "SETUP LOG TAIL"
if [ -r /root/sosetup.log ] || [ -r "$HOME/sosetup.log" ]; then
  if [ -r /root/sosetup.log ]; then
    run tail -n 100 /root/sosetup.log
  else
    run tail -n 100 "$HOME/sosetup.log"
  fi
else
  echo "Log unavailable to current user. For root log, run: sudo tail -n 100 /root/sosetup.log"
fi
section "SO STATUS"
if command -v so-status >/dev/null 2>&1; then
  run so-status
else
  echo "so-status is not installed or not in PATH"
fi
section "PRIVACY REMINDER"
echo "Redact tokens, passwords, cookies, private addresses before posting output."
