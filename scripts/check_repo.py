#!/usr/bin/env python3
"""Validate repository completeness and local Markdown links; no external deps."""
from pathlib import Path
from urllib.parse import unquote
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "README.md", "PROJECT_STATUS.md", "SECURITY.md", ".gitignore", "CHANGELOG.md",
    "docs/01-overview.md", "docs/02-architecture.md", "docs/03-installation.md",
    "docs/04-network-validation.md", "docs/05-demo-runbook.md",
    "docs/06-troubleshooting.md", "docs/07-ecosystem.md",
    "docs/08-scope-limitations.md", "docs/09-references.md",
    "docs/10-verified-setup.md", "docs/11-windows-ssh-socks.md",
    "docs/12-monitoring-next.md", "docs/13-daily-workflow.md",
    "scenarios/README.md", "report/outline.md", "report/results-template.csv",
    ".github/workflows/docs-check.yml", "diagrams/network-topology.mmd",
    "windows/README.md", "windows/auto-tunnel.ps1",
    "windows/config.example.ps1", "windows/check-tunnel.ps1",
    "report/setup-evidence-template.md",
]
errors=[]
for name in REQUIRED:
    if not (ROOT/name).is_file():
        errors.append(f"Missing required file: {name}")

# Identify conventional Markdown inline links; skip https, mailto, document anchors.
rx = re.compile(r'(?<!!)\[[^\]]+\]\(([^)]+)\)')
for doc in sorted(ROOT.rglob('*.md')):
    if '.git' in doc.parts:
        continue
    for url in rx.findall(doc.read_text(encoding='utf-8')):
        target=url.split(' ',1)[0].strip('<>')
        if target.startswith(('http://','https://','mailto:','#','data:')):
            continue
        path=unquote(target.split('#',1)[0])
        if not path:
            continue
        resolved=(doc.parent/path).resolve()
        if not resolved.is_relative_to(ROOT.resolve()) or not resolved.exists():
            errors.append(f"Broken local link: {doc.relative_to(ROOT)} -> {url}")

if errors:
    print('\n'.join('ERROR: '+e for e in errors))
    sys.exit(1)
print(f"OK: {len(REQUIRED)} required files, local links in {len(list(ROOT.rglob('*.md')))} Markdown files.")
