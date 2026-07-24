#!/usr/bin/env bash
# One-command setup for the Serokell document template plugin.
#
#   curl -fsSL https://raw.githubusercontent.com/alexander-rukin/serokell-doc-template/main/install.sh | bash
#
# Registers the marketplace, installs the plugin, and turns on autoUpdate so
# later releases arrive on their own. The Claude CLI has no flag for that last
# part, so it is written into ~/.claude/settings.json here instead. Safe to run
# again: every step is idempotent and the settings file is backed up first.
set -euo pipefail

REPO="alexander-rukin/serokell-doc-template"
MARKET="serokell-docs"
PLUGIN="serokell-docs@serokell-docs"
SETTINGS="$HOME/.claude/settings.json"

say() { printf '\n%s\n' "$*"; }

# --- prerequisites ----------------------------------------------------------
command -v claude >/dev/null 2>&1 || {
  echo "error: the claude CLI is not on your PATH." >&2
  echo "  Install Claude Code first, then run this again." >&2
  exit 1
}

if ! command -v typst >/dev/null 2>&1; then
  say "note: Typst is not installed. The plugin needs it to build PDFs."
  echo "  macOS:  brew install typst"
  echo "  other:  https://github.com/typst/typst#installation"
fi

# --- marketplace ------------------------------------------------------------
say "Registering the marketplace..."
if claude plugin marketplace list 2>/dev/null | grep -q "$MARKET"; then
  claude plugin marketplace update "$MARKET" >/dev/null 2>&1 || true
  echo "  already registered, refreshed it"
else
  claude plugin marketplace add "$REPO" >/dev/null
  echo "  added"
fi

# --- plugin -----------------------------------------------------------------
say "Installing the plugin..."
# Reinstall rather than update: refreshing the marketplace manifest does not
# always pull down new plugin files.
claude plugin uninstall "$PLUGIN" >/dev/null 2>&1 || true
claude plugin install "$PLUGIN" >/dev/null
echo "  installed"

# --- autoUpdate -------------------------------------------------------------
say "Turning on automatic updates..."
if ! command -v python3 >/dev/null 2>&1; then
  echo "  skipped: python3 not found. Add \"autoUpdate\": true by hand under"
  echo "  extraKnownMarketplaces.$MARKET in $SETTINGS"
else
  MARKET="$MARKET" REPO="$REPO" SETTINGS="$SETTINGS" python3 <<'PY'
import json, os, shutil

settings = os.environ["SETTINGS"]
market = os.environ["MARKET"]
repo = os.environ["REPO"]

os.makedirs(os.path.dirname(settings), exist_ok=True)
try:
    with open(settings, encoding="utf-8") as fh:
        data = json.load(fh)
except FileNotFoundError:
    data = {}
except json.JSONDecodeError:
    raise SystemExit(f"  settings file is not valid JSON, leaving it alone: {settings}")

# Back up before touching anything the user owns.
if os.path.exists(settings):
    shutil.copy(settings, settings + ".bak")

entry = data.setdefault("extraKnownMarketplaces", {}).setdefault(market, {})
# Only fill in the source if it is missing; the CLI may have written its own
# form and that one should win.
entry.setdefault("source", {"source": "github", "repo": repo})
already = entry.get("autoUpdate") is True
entry["autoUpdate"] = True

with open(settings, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2, ensure_ascii=False)
    fh.write("\n")

print("  already on" if already else "  enabled")
PY
fi

say "Done. From any folder, ask for a document:"
echo '  "make a PDF from proposal.md"'
echo '  "нужно резюме, вот заметки: notes.txt"'
echo
claude plugin list 2>/dev/null | grep -A1 "$PLUGIN" || true
