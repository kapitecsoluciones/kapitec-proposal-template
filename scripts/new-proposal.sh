#!/usr/bin/env bash
#
# new-proposal.sh — bootstrap a new Kapitec proposal site from the template.
#
# Usage:
#   ./scripts/new-proposal.sh {slug} "{Client Name}" "{Location}" \
#       "{Proposal Title}" "{INDUSTRY_BADGE}" "{#HEX}" "{R,G,B}"
#
# Example:
#   ./scripts/new-proposal.sh logistics-acme "Acme Corp" "Chicago, Illinois" \
#       "Chicago Logistics Automation" "LOGISTICS" "#10B981" "16,185,129"
#
# Output: ../{slug}-proposal/site/index.html  (fully substituted, ready for mockup gen)

set -euo pipefail

if [ $# -lt 7 ]; then
    echo "Usage: $0 {slug} \"{Client Name}\" \"{Location}\" \"{Proposal Title}\" \"{INDUSTRY_BADGE}\" \"{#HEX}\" \"{R,G,B}\"" >&2
    echo "" >&2
    echo "Example:" >&2
    echo "  $0 logistics-acme \"Acme Corp\" \"Chicago, Illinois\" \\" >&2
    echo "     \"Chicago Logistics Automation\" \"LOGISTICS\" \"#10B981\" \"16,185,129\"" >&2
    exit 2
fi

SLUG="$1"
CLIENT_NAME="$2"
CLIENT_LOCATION="$3"
PROPOSAL_TITLE="$4"
INDUSTRY_BADGE="$5"
INDUSTRY_HEX="$6"      # e.g. "#10B981"
INDUSTRY_RGB="$7"      # e.g. "16,185,129"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$(cd "$TEMPLATE_ROOT/.." && pwd)/${SLUG}-proposal"

if [ -e "$OUT_DIR" ]; then
    echo "refusing to overwrite existing $OUT_DIR" >&2
    exit 1
fi

mkdir -p "$OUT_DIR/site/mockups" "$OUT_DIR/site/assets"
cp "$TEMPLATE_ROOT/template/index.html" "$OUT_DIR/site/index.html"
cp "$TEMPLATE_ROOT/template/og.html"    "$OUT_DIR/site/og.html"
cp "$TEMPLATE_ROOT/template/assets/kapi-logo.svg" "$OUT_DIR/site/assets/kapi-logo.svg"

# Helper: url-encode
urlencode() {
    python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$1"
}

WA_BODY_ENCODED=$(urlencode "Hola Javi, vi la propuesta de ${PROPOSAL_TITLE} y me gustaría agendar una sesión")
EMAIL_SUBJECT_ENCODED=$(urlencode "${PROPOSAL_TITLE} — ${CLIENT_NAME}")
META_DESCRIPTION="Kapitec strategic proposal — ${PROPOSAL_TITLE}. Prepared for ${CLIENT_NAME}, ${CLIENT_LOCATION}."

# Substitute placeholders in both index.html and og.html.
python3 - "$OUT_DIR/site/index.html" "$OUT_DIR/site/og.html" <<PYEOF
import sys, pathlib
mapping = {
    "__CLIENT_NAME__": """${CLIENT_NAME}""",
    "__CLIENT_LOCATION__": """${CLIENT_LOCATION}""",
    "__PROPOSAL_SLUG__": """${SLUG}""",
    "__PROPOSAL_TITLE__": """${PROPOSAL_TITLE}""",
    "__META_DESCRIPTION__": """${META_DESCRIPTION}""",
    "__INDUSTRY_BADGE__": """${INDUSTRY_BADGE}""",
    "__WA_BODY_ENCODED__": """${WA_BODY_ENCODED}""",
    "__EMAIL_SUBJECT_ENCODED__": """${EMAIL_SUBJECT_ENCODED}""",
    # Industry color — swap amber hex and rgb triplet
    "#F59E0B": """${INDUSTRY_HEX}""",
    "245,158,11": """${INDUSTRY_RGB}""",
}
for argv in sys.argv[1:]:
    p = pathlib.Path(argv)
    text = p.read_text()
    for k, v in mapping.items():
        text = text.replace(k, v)
    p.write_text(text)
    print(f"wrote {p} ({len(text)} bytes)")
PYEOF

# Render og.png from og.html (1200x630). Try playwright CLI, then fall back to headless Chrome.
OG_HTML="$OUT_DIR/site/og.html"
OG_PNG="$OUT_DIR/site/assets/og.png"
echo ""
echo "→ rendering og.png (1200x630) from og.html"

render_ok=0
if command -v npx >/dev/null 2>&1; then
    # Try node + playwright
    if npx --yes playwright --version >/dev/null 2>&1; then
        npx --yes playwright chromium --headless=true "file://$OG_HTML" --screenshot="$OG_PNG" --viewport-size=1200,630 2>/dev/null && render_ok=1 || true
    fi
fi

if [ "$render_ok" = "0" ]; then
    # macOS
    if [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --no-sandbox --hide-scrollbars --window-size=1200,630 --force-device-scale-factor=1 --virtual-time-budget=3000 --screenshot="$OG_PNG" "file://$OG_HTML" 2>/dev/null && render_ok=1 || true
    # Linux (google-chrome / chromium)
    elif command -v google-chrome >/dev/null 2>&1; then
        google-chrome --headless=new --disable-gpu --no-sandbox --hide-scrollbars --window-size=1200,630 --force-device-scale-factor=1 --virtual-time-budget=3000 --screenshot="$OG_PNG" "file://$OG_HTML" 2>/dev/null && render_ok=1 || true
    elif command -v chromium >/dev/null 2>&1; then
        chromium --headless=new --disable-gpu --no-sandbox --hide-scrollbars --window-size=1200,630 --force-device-scale-factor=1 --virtual-time-budget=3000 --screenshot="$OG_PNG" "file://$OG_HTML" 2>/dev/null && render_ok=1 || true
    fi
fi

if [ "$render_ok" = "1" ] && [ -f "$OG_PNG" ]; then
    echo "  ✓ og.png → $OG_PNG ($(wc -c < "$OG_PNG") bytes)"
else
    echo "  ⚠ could not auto-render og.png — open $OG_HTML in a browser, screenshot 1200×630, save as $OG_PNG"
fi

cat > "$OUT_DIR/README.md" <<EOM
# ${PROPOSAL_TITLE}

Kapitec proposal for **${CLIENT_NAME}** (${CLIENT_LOCATION}).

## Next steps

1. Regenerate product mockups with Stitch (design system asset \`$(cat "$TEMPLATE_ROOT/STITCH_ASSET_ID.txt")\`) and drop screenshots in \`site/mockups/{webconsole,mobile,admin}.png\`.
2. Rewrite the narrative copy in \`site/index.html\` (problem cards, roadmap bullets, architecture timeline text, conclusion) to reflect ${CLIENT_NAME}'s industry.
3. Deploy to kapitec.pro/${SLUG}/ from local Mac (EC2 blocked by DreamHost fail2ban).

See the template repo README for the full checklist.
EOM

echo ""
echo "✓ bootstrapped new proposal at: $OUT_DIR"
echo "  slug:     $SLUG"
echo "  client:   $CLIENT_NAME"
echo "  location: $CLIENT_LOCATION"
echo "  accent:   $INDUSTRY_HEX  ($INDUSTRY_RGB)"
echo ""
echo "next: regenerate mockups via Stitch + rewrite narrative copy, then deploy."
