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

mkdir -p "$OUT_DIR/site/mockups"
cp "$TEMPLATE_ROOT/template/index.html" "$OUT_DIR/site/index.html"

# Helper: url-encode
urlencode() {
    python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$1"
}

WA_BODY_ENCODED=$(urlencode "Hola Javi, vi la propuesta de ${PROPOSAL_TITLE} y me gustaría agendar una sesión")
EMAIL_SUBJECT_ENCODED=$(urlencode "${PROPOSAL_TITLE} — ${CLIENT_NAME}")
META_DESCRIPTION="Kapitec strategic proposal — ${PROPOSAL_TITLE}. Prepared for ${CLIENT_NAME}, ${CLIENT_LOCATION}."

# Substitute placeholders. Use a delimiter unlikely to appear in values.
python3 - "$OUT_DIR/site/index.html" <<PYEOF
import sys, pathlib
p = pathlib.Path(sys.argv[1])
text = p.read_text()
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
for k, v in mapping.items():
    text = text.replace(k, v)
p.write_text(text)
print(f"wrote {p} ({len(text)} bytes)")
PYEOF

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
