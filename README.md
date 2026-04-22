# Kapitec Proposal Template

Reusable proposal site template for Kapitec Soluciones client engagements. Every Kapitec client-facing proposal deployed to `kapitec.pro/{slug}/` uses this template as its starting point.

**Live reference**: https://kapitec.pro/phx/ (prepared for Dayanara, Phoenix heavy freight).

## Who uses this

- **Javier (local Claude sessions)** — via `/Users/jenriquez/kapitec-proposal-template/`, iterated on Mac.
- **bot-01 (openclaw)** — clones this repo into `/root/.openclaw/workspace/kapitec-proposals/{slug}/` when generating proposals for a new prospect.

Both share the same Stitch (claude.ai/design) design system asset — see `STITCH_ASSET_ID.txt`.

## Hard rules (non-negotiable, for every Kapitec proposal)

1. **No prices** in the v1 client-facing output. Pricing is added later in a v2 after the client validates scope.
2. **Roadmap durations are commercial, not engineering time.** Phases are labeled in **months** (typically Month 1 / Month 2 / Month 3 for a three-month end-to-end engagement). AI-accelerated engineering compresses the *build* itself to days — the commercial window includes client-side onboarding, regulatory validation, pilot ramp-up, and operational calm-down. Never quote the raw build time in days to the client.
3. **No emojis.** Material Symbols Outlined (filled variant) or lucide icons at 20–24px with 1.5px stroke.
4. **Dark theme default**, matching kapitec.pro: canvas `#070E1D`, surface tiers `#0A1428` → `#233D66`, ghost borders `rgba(255,255,255,0.06)`.
5. **Kapitec signature gradient** `linear-gradient(135deg, #2367FB 0%, #2DD2A1 100%)` used sparingly — hero one-word accent, primary CTA, roadmap phase numbers, credentials "Live" links. Nowhere else.
6. **Industry accent** swappable per client: amber `#F59E0B` for PHX; green for logistics; navy+amber for real estate. Used only on industry badge, problem-card left borders, one high-impact stat, and roadmap duration pills.
7. **Client name in hero eyebrow** — always `// 00 · Prepared for {CLIENT_NAME} · {CLIENT_LOCATION}`.
8. **Credentials section is confidentiality-preserving, not confidentiality-first.** Never name specific client projects. NEVER write the phrase "we keep client engagements confidential" — it reads as evasive. Preferred framing: "most of what we build sits inside our clients' operations, not in their marketing — the systems run every day but rarely carry a logo." Default format: narrative paragraphs on 20-year track record + 3 stat cards (years operating, geographic reach, stack ownership) + a small row of public-facing Kapitec URLs (kapi.mx · kapitec.pro · arivey.com · loveaxel.com · aili.mx). Clients sometimes press for credentials — reply verbally.
9. **Footer** is Kapitec's own — no "Powered by X" auto-credits.
10. **Typography**: Plus Jakarta Sans 800 (H1 80px, H2 48px, -0.02em tracking), Inter 400/500 (body 17px, 1.65 line-height), JetBrains Mono 700 (stats, durations, weights).
11. **Logo**: real Kapi wordmark SVG (`template/assets/kapi-logo.svg`) in nav + footer — never render `kapi.` as text.
12. **Primary CTA = WhatsApp to Javi** (+52 662 105 0329). Hero uses the WhatsApp-green brand glyph, a gradient-filled button, and the direct wa.me link with a pre-filled message. A green WhatsApp floating-action-button sits bottom-right on every screen so the CTA is reachable from any scroll position.
13. **Open Graph image** (`site/assets/og.png`, 1200×630 PNG) is mandatory. Every Kapitec proposal URL gets pasted into WhatsApp, email, Slack, etc. — a blank unfurl looks unprofessional. The template ships `template/og.html` which the bootstrap script renders to PNG via headless Chrome; the PNG shows the Kapi logo, industry badge, proposal title, client name, and Javier's contact line on the Kapitec gradient backdrop.
14. **Named technology stack.** The Architecture section ends with a "named primitives" grid listing the real stack (Mapbox · AWS Textract · Stripe Connect · Twilio · Postgres/RDS · React Native · Next.js · AWS/Vercel by default). Hand-wavy "AI-powered platform" language is not acceptable — clients who can read the stack trust the team that picked it.
15. **Market & Comparables section** is required whenever the prospect's mental model is "Uber for X" (construction freight, cleaning, notary, handyman, etc.) or whenever there is a visible competitor. Format: 4-card grid — 1 competitor that does NOT fit (e.g. Uber Freight for construction), 2 precedents that DO fit and prove the thesis (e.g. Iron Sheepdog, Trux), and the gradient-bordered "this proposal" card positioning Kapitec. Closes with a one-paragraph "why the window is open" callout. Acknowledging the competition is credibility, not surrender.
16. **Default language is Spanish.** `template/index.html` ships in Spanish because the majority of Kapitec engagements are with Mexican clients. The PHX engagement for Dayanara is kept in `examples/phx-dayanara/index.html` in English as the reference for US-market proposals. For a new English-language proposal, start from `examples/phx-dayanara/index.html` instead of `template/index.html` (the structure and classes are identical; only the copy differs).
17. **Mobile responsive is non-negotiable.** `html, body { overflow-x: hidden; max-width: 100vw; }` is baked into the template. All H1/H2 use responsive text sizes (`text-[40px] sm:text-5xl md:text-[80px]` for hero, `text-3xl sm:text-4xl md:text-[48px]` for section titles). Wide decorative elements (`w-[600px]`, `w-[800px]` glows) are clamped to viewport on mobile via media query. Always test at 375×667 (iPhone SE) before deploying — horizontal scroll on mobile is an instant credibility loss when the client opens the link from WhatsApp on their phone.

## Structure of this repo

```
kapitec-proposal-template/
├── template/
│   ├── index.html          ← the skeleton with __PLACEHOLDER__ markers
│   ├── og.html             ← Open Graph image template (1200×630) — rendered to site/assets/og.png
│   └── assets/
│       └── kapi-logo.svg   ← official Kapi wordmark (from /workspace/brand/)
├── examples/
│   └── phx-dayanara/
│       ├── index.html      ← live reference (kapitec.pro/phx/)
│       └── mockups/        ← Stitch-generated product screens
├── scripts/
│   └── new-proposal.sh     ← bootstrap a new proposal from the template
├── STITCH_ASSET_ID.txt     ← 6542439205125624117 (shared design system)
└── README.md
```

## Placeholders in `template/index.html`

Simple string replacement (no templating engine). `scripts/new-proposal.sh` handles these.

| Placeholder | Example (PHX) | Notes |
|---|---|---|
| `__CLIENT_NAME__` | `Dayanara` | Appears in hero eyebrow and contact H2 |
| `__CLIENT_LOCATION__` | `Phoenix, Arizona` | Hero eyebrow subtitle |
| `__PROPOSAL_SLUG__` | `phx` | URL path under kapitec.pro |
| `__PROPOSAL_TITLE__` | `Phoenix Heavy Freight Marketplace` | `<title>` + OG meta |
| `__META_DESCRIPTION__` | `Compliance-first platform...` | OG description |
| `__INDUSTRY_BADGE__` | `PHOENIX` | Uppercase industry pill in nav + footer |
| `__WA_BODY_ENCODED__` | `Hola%20Javi%2C%20vi%20la%20propuesta%20de%20Phoenix...` | URL-encoded WhatsApp message body |
| `__EMAIL_SUBJECT_ENCODED__` | `Phoenix%20Freight%20Proposal%20%E2%80%94%20Dayanara` | URL-encoded email subject |

**Industry accent color** is not a simple placeholder — it appears as `#F59E0B` hex in multiple places AND as `rgba(245,158,11,X)` in tints. The bootstrap script does two sed passes with the new hex + rgb triplet.

## Workflow for a new prospect

### 1. Bootstrap

```bash
./scripts/new-proposal.sh {slug} "{Client Name}" "{Location}" "{Proposal Title}" "{Industry Badge}" "{#HEX}" "{R,G,B}"

# Example:
./scripts/new-proposal.sh logistics-acme "Acme Corp" "Chicago, Illinois" \
    "Chicago Logistics Automation" "LOGISTICS" "#10B981" "16,185,129"
```

This creates a new sibling directory `../{slug}-proposal/` with:
- `site/index.html` — fully substituted
- `site/mockups/` — empty, populate via Stitch next

### 2. Regenerate product mockups via Stitch

Using the shared design system asset (`6542439205125624117`):

```python
# via mcp__stitch__generate_screen_from_text, deviceType=DESKTOP or MOBILE
# Prompts: describe the new client's Web Console / Mobile App / Admin Portal
# Save screenshots to site/mockups/{webconsole,mobile,admin}.png
```

Stitch regenerations often rename the internal design-system display name (e.g., "Phoenix Nocturne", "Kinetic Command"). **Always sed-replace that name back to `kapi.`** in the generated mockup HTML before taking headless screenshots. See `examples/phx-dayanara/` for the expected look.

### 3. Rewrite narrative copy

The placeholders don't touch the PHX-specific narrative (problem cards, roadmap bullets, architecture timeline text, etc.). For each new client you must rewrite these manually or via a Stitch regeneration targeted at the new client's industry.

Keep:
- The 9-section structure (// 00 Hero → // 09 Conclusion + Contact)
- The eyebrow format `// NN · SECTION NAME`
- The credentials strip (5 tiles for R136 / SafeTravel / Emmental / SmartClose / Kapi)

### 4. Deploy

From **local Mac** (EC2 is banned by DreamHost fail2ban):

```bash
SSH_KEY=/tmp/dh_9mpifb_key  # copied once from bot-01 /root/.openclaw/workspace/.ssh/id_ed25519
DH_HOST=pdx1-shared-a1-46.dreamhost.com
DH_USER=dh_9mpifb
SLUG=logistics-acme

# Backup existing folder if any
ssh -i $SSH_KEY $DH_USER@$DH_HOST "test -d /home/$DH_USER/kapitec.pro/$SLUG && cp -r /home/$DH_USER/kapitec.pro/$SLUG /home/$DH_USER/kapitec.pro/$SLUG-$(date +%Y-%m-%d)-backup"

# Deploy
ssh -i $SSH_KEY $DH_USER@$DH_HOST "mkdir -p /home/$DH_USER/kapitec.pro/$SLUG/mockups"
scp -i $SSH_KEY site/index.html $DH_USER@$DH_HOST:/home/$DH_USER/kapitec.pro/$SLUG/
scp -i $SSH_KEY site/mockups/*.png $DH_USER@$DH_HOST:/home/$DH_USER/kapitec.pro/$SLUG/mockups/
```

From **bot-01** (openclaw): same steps but using the in-workspace `~/.ssh/id_ed25519` key and the `kapitec.pro` SSH host alias (configured in `/root/.openclaw/workspace/.ssh/config`).

## Critical pitfall

Tailwind CDN does **not** resolve `theme('...')` references inside `<style>` tags. Use direct CSS for the signature gradient:

```css
.btn-gradient {
    background: linear-gradient(135deg, #2367FB 0%, #2DD2A1 100%);
}
.text-gradient {
    background: linear-gradient(135deg, #2367FB 0%, #2DD2A1 100%);
    -webkit-background-clip: text;
    background-clip: text;
    color: transparent;
}
```

If you see the gradient word rendering as a gap in the hero, or the primary CTA showing as plain text on a dark button, this is why.

## Update cadence

This template is source-controlled in `github.com/kapitecsoluciones/kapitec-proposal-template`. When a real client engagement uncovers improvements (better section order, new eyebrow pattern, stronger credentials tile, etc.), update `template/index.html` here and push — both Claude and bot-01 pull the latest on their next proposal.
