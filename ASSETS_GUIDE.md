# Assets Guide

## Required Assets

### App Icon
Place your app icon files in `assets/icons/`:
- `app_icon.png` — 1024×1024px main app icon
- `app_icon_foreground.png` — 1024×1024px foreground for adaptive icons (Android)

> **Generate icons:** After placing the images, run:
> ```bash
> flutter pub get
> flutter pub run flutter_launcher_icons:main
> ```

### Onboarding Images
Place 4 onboarding illustrations in `assets/images/`:
- `onboarding_1.png` — Welcome / Hero illustration
- `onboarding_2.png` — Design tools illustration
- `onboarding_3.png` — Business management illustration
- `onboarding_4.png` — Cloud sync / Offline illustration

**Recommended specs:**
- Resolution: 800×800px or higher
- Style: Flat illustration, warm earthy tones (browns, creams, golds)
- Background: Transparent or matching `AppColors.backgroundCream` (#FAF3E8)

### Screenshots
Place captured app screenshots in `screenshots/` for README:
- `screenshot_onboarding.png`
- `screenshot_module_selection.png`
- `screenshot_design_dashboard.png`
- `screenshot_finance_ledger.png`
- `screenshot_ai_generation.png`
- `screenshot_client_details.png`

## Free Illustration Resources
- [unDraw](https://undraw.co/)
- [Storyset](https://storyset.com/)
- [Humaaans](https://www.humaaans.com/)
