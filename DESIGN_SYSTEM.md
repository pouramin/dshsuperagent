# TunnelLab Web Design System — v1

Derived from actual repository UI review of `pouramin/Mercury`, `pouramin/REA-Codex`, `pouramin/AWCT`, `pouramin/FindSkill`, `pouramin/AiVideo`, `pouramin/JEVArena` and `pouramin/Kling4` (November 2026).

## Shared foundation
- Off-white background `#f7f9fd`; white cards `#ffffff`
- Navy foreground `#18253e`; muted ink `#718198`
- Subtle borders `#dfe6f1`
- Main blue `#4265d6`; accent orange `#f47c48`
- Rounded cards (18px); restrained shadows and roomy 1200px desktop content width
- DM Sans for Latin copy; Vazirmatn for all Persian content
- English default, optional Persian RTL translation. Technical expressions, paths, commands and product/menu names stay in their original form and remain LTR.
- TunnelLab topbar, simple text nav, GitHub CTA, accessible focus styles
- Responsive stacked cards on small screens; no faces, robots or generic AI imagery
- Commands in high-contrast dark code panels with one-click copy

## Reuse across sibling project pages
The audited sites are not fully identical: older AiVideo/Kling4 pages use a stronger coral palette, while newer Mercury pages favor blue and soft orange. This guide intentionally follows the newer Mercury palette and doesn't overwrite sibling repositories. Align older pages gradually using these tokens without replacing their project-specific content.

## Maintainability
For future sites, extract these tokens into a shared versioned CSS asset after the existing sites are migrated; changing remote CSS across older sites without testing risks regressions. Keep this document as the visual baseline.
