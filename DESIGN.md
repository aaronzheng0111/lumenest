---
version: alpha
name: 孕育小家 · Liquid Glass
description: >
  Pregnancy companion Android app (Flutter-first) with Apple-inspired frosted glass.
  Warm maternal peach/rose/cream; translucent layers, soft springs, no purple neon or dark mode.
colors:
  primary: "#E8A598"
  primary-deep: "#C97B6E"
  secondary: "#F5D5C8"
  tertiary: "#5BB98A"
  neutral: "#F7F1EA"
  blush: "#F3E4DC"
  atmosphere-bottom: "#EBD5CB"
  on-surface: "#4A3728"
  on-surface-variant: "#8A7A6C"
  on-primary: "#FFFFFF"
  locked: "#B5A89C"
  divider: "rgba(74, 55, 40, 0.08)"
  glass-light: "rgba(255, 255, 255, 0.55)"
  glass-medium: "rgba(255, 255, 255, 0.40)"
  glass-heavy: "rgba(255, 255, 255, 0.72)"
  glass-rose: "rgba(232, 165, 152, 0.45)"
  glass-rose-soft: "rgba(245, 213, 200, 0.35)"
  glass-locked: "rgba(255, 255, 255, 0.32)"
  glass-stroke: "rgba(255, 255, 255, 0.65)"
  glass-stroke-soft: "rgba(255, 255, 255, 0.35)"
  scrim: "rgba(74, 55, 40, 0.28)"
typography:
  display:
    fontFamily: "PingFang SC"
    fontSize: 30px
    fontWeight: 600
    lineHeight: 1.25
  headline-md:
    fontFamily: "PingFang SC"
    fontSize: 20px
    fontWeight: 600
    lineHeight: 1.25
  title-md:
    fontFamily: "PingFang SC"
    fontSize: 18px
    fontWeight: 600
    lineHeight: 1.25
  body-md:
    fontFamily: "PingFang SC"
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.45
  body-sm:
    fontFamily: "PingFang SC"
    fontSize: 15px
    fontWeight: 400
    lineHeight: 1.45
  label-md:
    fontFamily: "PingFang SC"
    fontSize: 13px
    fontWeight: 500
    lineHeight: 1.3
  caption:
    fontFamily: "PingFang SC"
    fontSize: 12px
    fontWeight: 400
    lineHeight: 1.35
rounded:
  sm: 8px
  md: 14px
  lg: 20px
  xl: 24px
  sheet: 28px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  xxl: 32px
  page-margin: 20px
  section-gap: 24px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.md}"
    padding: 14px
    height: 48px
  button-primary-pressed:
    backgroundColor: "{colors.primary-deep}"
    textColor: "{colors.on-primary}"
  glass-card:
    backgroundColor: "{colors.glass-light}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    padding: 16px
  glass-card-hero:
    backgroundColor: "{colors.glass-medium}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.xl}"
    padding: 20px
  glass-card-active:
    backgroundColor: "{colors.glass-rose}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
  glass-card-locked:
    backgroundColor: "{colors.glass-locked}"
    textColor: "{colors.locked}"
    rounded: "{rounded.lg}"
  glass-app-bar:
    backgroundColor: "{colors.glass-medium}"
    textColor: "{colors.on-surface}"
    height: 56px
  glass-tab-bar:
    backgroundColor: "{colors.glass-medium}"
    textColor: "{colors.on-surface-variant}"
    rounded: "{rounded.full}"
    height: 64px
  glass-tab-selected:
    backgroundColor: "{colors.glass-rose}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.full}"
  chat-bubble-user:
    backgroundColor: "{colors.glass-rose}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.lg}"
    padding: 12px
  chat-bubble-assistant:
    backgroundColor: "{colors.glass-light}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.lg}"
    padding: 12px
  input-pill:
    backgroundColor: "{colors.glass-medium}"
    textColor: "{colors.on-surface-variant}"
    rounded: "{rounded.full}"
    height: 48px
    padding: 12px
  sheet-privacy:
    backgroundColor: "{colors.glass-heavy}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.sheet}"
    padding: 24px
  chip-stage:
    backgroundColor: "{colors.glass-rose-soft}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.full}"
    padding: 8px
  list-settings:
    backgroundColor: "{colors.glass-heavy}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.xl}"
    height: 56px
---

# 孕育小家 · DESIGN.md

> Claude Design / Google Stitch compatible.  
> Visual refs: `mockups/glass/p1-*-glass.png` · regenerated from this file: `mockups/glass/from-design-md/`.  
> Flutter Android first. Upload to [Claude Design](https://claude.ai/design) → Create design system → Add assets → this `DESIGN.md`.

## Overview

**孕育小家** is an 18-month pregnancy companion (备孕 → 孕期 → 产后). The product feeling is *warm companionship*, not clinical tooling: soft, calm, premium—Apple **Liquid Glass** language on Android.

Personality: nurturing, quiet confidence, breathable space. Hierarchy comes from **frosted layers** (atmosphere → glass content → floating chrome), not heavy Material cards. Information architecture stays fixed: Home / Chat / Me; four AI roles (小暖 active; 林医生 / 苏心 / 阿嬷 locked in P1).

Motion is springy and short—float, press, sheet blur—not decorative noise.

## Colors

Palette is maternal warmth: peach atmosphere, dusty rose interaction, cream canvas, warm-brown ink.

- **Primary / Dusty Rose (`#E8A598`):** Primary actions, user bubbles, selected glass tint. Pressed → **Primary Deep (`#C97B6E`)**.
- **Secondary / Peach (`#F5D5C8`):** Atmosphere orbs, soft fills, selected accents.
- **Tertiary / Soft Green (`#5BB98A`):** Online status only—not a second brand accent for chrome.
- **Neutral / Cream (`#F7F1EA`) → Blush (`#F3E4DC`) → Atmosphere Bottom (`#EBD5CB`):** Page backgrounds as a soft vertical gradient with peach/rose blurred orbs. Never a flat solid fill as the only background.
- **On-Surface (`#4A3728`) / Variant (`#8A7A6C`):** Body and metadata. No pure black.
- **Glass fills:** Light / Medium / Heavy white translucency; Rose / Rose-Soft / Locked variants for state. Always pair with backdrop blur and a luminous white stroke.

## Typography

Chinese UI uses **PingFang SC** (SF Pro Text as Latin fallback). Few weights: Regular 400, Medium 500, Semibold 600.

- **Display:** 孕周 heroes (“孕16周”)—Semibold ~30px.
- **Headline / Title:** Screen and section titles—Semibold 18–20px.
- **Body:** Chat and paragraphs—Regular 15–16px, line-height 1.45.
- **Label / Caption:** Tabs, chips, citations—Medium/Regular 12–13px.

## Layout

Mobile-first single column. **Page margin 20px**, **section gap 24px**, 4px base rhythm (`xs`…`xxl`).

Bottom **floating pill tab bar** clears content (`tab height + 16px`). Chat composer is a floating pill above the safe area. Prefer airy vertical rhythm over dense dashboards—one job per section.

## Elevation & Depth

Depth = **glass stacks**, not Material elevation numbers.

1. Atmosphere gradient + soft orbs  
2. Content glass (`blur sigma 24`, 1px `glass-stroke`)  
3. Floating chrome (tab bar, input) with soft dual shadows  
4. Sheets (`blur 32`, heavier shadow, scrim `rgba(74,55,40,0.28)`)

Shadows (warm brown alpha, never pure black):

- Card: `0 8px 24px rgba(74,55,40,0.10)`, `0 2px 6px rgba(74,55,40,0.06)`
- Float: `0 12px 32px rgba(74,55,40,0.14)`, `0 4px 8px rgba(74,55,40,0.08)`
- Sheet: `0 24px 48px rgba(74,55,40,0.18)`
- Rose glow (selected only, restrained): `0 0 20px rgba(232,165,152,0.35)`

## Shapes

Continuous soft curves. Cards `lg`/`xl` (20–24px); sheets `28px`; inputs, tab bar, chips `full` pill. Icon wells ~`md` (14px). SF Symbols–like strokes ~1.5px.

## Components

- **Buttons:** Primary rose glass/solid with white label, height 48, radius `md`. Secondary = text-only on-surface-variant.
- **Glass cards:** Default light glass; hero = medium + peach sheen; active role = rose glass + online green; locked = colder glass + lock + “后续版本开放”.
- **App bar:** Translucent medium glass, height 56, hairline bottom stroke.
- **Tab bar:** Floating pill, three tabs 首页 / 对话 / 我的; selected = rose glass pill (no thick underline).
- **Chat:** User = rose glass bubble; assistant = light glass + stroke; citation caption below; avatar with thin glass ring.
- **Input pill:** Medium glass capsule; send = rose control (“发送” or paper plane).
- **Settings list:** Heavy glass group; row ~56; rose icon wells; hairline dividers inset to text.
- **Privacy sheet:** Heavy glass, blur 32; primary “同意并继续”; text “关闭”.

**Motion:** standard ease-out 280–320ms; sheet scale 0.94→1 + fade 320–380ms; press scale 0.97 / 100ms; list stagger +12px / 40ms; bubbles slide 8px from their side.

## Do's and Don'ts

**Do**

- Default interactive surfaces to frosted glass (translucency + blur + luminous stroke)
- Keep warm peach/rose/cream and warm-brown text
- Preserve IA: three tabs, four roles, Chinese copy from product mockups
- Use glass PNG refs under `mockups/glass/` as visual acceptance

**Don't**

- Purple–indigo gradients, neon strokes, default dark mode
- Opaque white cards pretending to be glass
- Heavy black shadows or stacked loud glows
- Hero clutter (stat strips, promo badges, sticker chips)
- Change product structure under the guise of a visual upgrade
