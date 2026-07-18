# Waflo Mobile UI V3 Design Authority

This document governs **Waflo Mobile UI V3 only**. It is the shared visual foundation for the owner and staff mobile experience; it is not authority for the customer web menu, admin web, older mobile versions, or backend behavior.

This archive establishes a visual foundation, not a claim that every screen, component, or interaction in the UI system is fully locked. Exact-screen approved visuals and the screen documents in this archive carry the authority described in [README.md](README.md).

## Core semantic tokens

These values are authoritative inputs. Production components must consume them by semantic role rather than treating a raw color as a component-specific instruction.

| Semantic role | Value | Use |
| --- | --- | --- |
| Primary | `#AE3115` | Normal primary actions, active navigation, focus emphasis, and Waflo brand presence |
| Accent | `#FF6B4A` | Supporting highlights and secondary emphasis |
| Background | `#F7F9FF` | Mobile page background |
| Surface | `#FFFFFF` | Cards, navigation surfaces, and other raised containers |
| Text / on-surface | `#181C20` | Near-black semantic text color based on the existing Waflo design authority |
| Error | `#BA1A1A` | Error and destructive states only; this role is distinct from Primary |

### Primary and error are different roles

Waflo deep red (`#AE3115`) is the normal mobile primary-action color. It must not make routine primary actions read as errors. Error and destructive states use the separate semantic Error color and must also include text, an icon, or another non-color cue.

Older documentation that reserves every red tone for errors does not override Waflo Mobile UI V3.

## Product and language direction

- Arabic-first and right-to-left by default.
- Premium restaurant SaaS: warm, composed, operationally clear, and suitable for high-pressure restaurant work.
- Horizontal layout, directional icons, reading order, and control order must mirror correctly in RTL.
- Arabic labels are production content, not decorative raster text.
- Text must remain readable and accessible; final font acceptance belongs to human visual QA.

## Layout and spacing

- Use a 4px spacing grid.
- Standard mobile page margin: 16px.
- Common card padding: 24px where the available width permits it.
- Card radius: 16–24px, chosen consistently by component role.
- Use soft, restrained shadows to separate white surfaces from the page background.
- Minimum touch target: 48px in both dimensions.
- Support responsive viewport widths from approximately 360px through 430px.
- Respect top, bottom, and device-cutout safe areas.
- Pages use natural vertical scrolling; do not implement a fixed screenshot-height layout.
- Content must not scroll or rest behind the bottom navigation.

Responsive implementation preserves hierarchy and intent, not screenshot coordinates. Raster references must never be copied pixel-for-pixel or used to derive hard-coded absolute positions.

## Bottom navigation authority

Every Waflo Mobile UI V3 primary shell uses five equal tabs in this order:

1. `الرئيسية`
2. `المنيو`
3. `المسح`
4. `الولاء`
5. `الإعدادات`

The scanner tab must not float and must not be larger than the other tabs. The selected tab uses a Primary-colored icon and label plus one subtle, consistent indicator. The same selected treatment must be used on every screen; a screen may not invent a different active-tab treatment.

The navigation surface is fixed and safe-area aware. Fixed navigation never permits page content or sticky actions to be obscured.

## Disabled-state authority

A disabled control is:

- fully muted;
- not interactive;
- accompanied by helper text that explains why it is unavailable when the reason is not self-evident; and
- visually distinct from active controls.

Disabled controls must not use active shadows, active Primary fills, or other cues that imply they can be tapped. Disabled state takes precedence over loading, pressed, focus, or default styling.

## Reference and implementation constraints

- Approved PNGs are visual references, not production assets.
- Do not copy Stitch HTML, generated code, or generated asset bundles.
- Do not use remote generated assets in production.
- Do not crop illustrations, icons, or interface elements out of screenshots.
- Do not copy raster references pixel-for-pixel.
- Production illustrations require separate original assets with recorded provenance or a native Flutter composition.
- Responsive behavior, accessibility, security, tenant isolation, and honest backend state override literal screenshot details.
