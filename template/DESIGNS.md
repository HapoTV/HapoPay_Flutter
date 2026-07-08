## HapoPay Mobile Design System (Mobile-first)

This document focuses on mobile application capabilities and Flutter implementation. It consolidates color tokens, spacing, text styles, component patterns and Flutter-ready snippets so maintainers and engineers can implement a consistent, agile mobile UI.

### Goals
- Mobile-first token set for fast iteration and consistent theming.
- Small, composable Flutter widgets and ThemeData examples.
- Clear mapping from tokens → `ThemeData` / `TextStyle` / constants.

---

## 1. Core Tokens (mobile)

### Colors (stable palette optimized for accessibility)
- Primary: #E91E63 — primary CTA and interactive accents (red/magenta)
- Primary-700: #C2185B — pressed / emphasis
- Secondary: #00BFA6 — supportive actions
- Accent: #FFB020 — highlights and badges
- Success: #16A34A
- Warning: #F59E0B
- Danger: #EF4444

Neutral scale (mobile-friendly contrast):
- Neutral-900: #111827
- Neutral-700: #374151
- Neutral-500: #6B7280
- Neutral-300: #D1D5DB
- Neutral-100: #F3F4F6

Dark mode tokens (mirror with semantic names):
- surfaceDark: #0F1724
- backgroundDark: #0B1220
- textDark: #E6EEF8

### Spacing (8pt baseline)
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px

### Radii
- small: 6px
- medium: 12px
- pill: 999px

### Elevation (Material friendly)
- elevation-1: 2dp shadow
- elevation-2: 6dp shadow

---

## 2. Flutter ThemeData (example)

Use this as the starting point in `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

final Color primary = Color(0xFF0066FF);
final Color secondary = Color(0xFF00BFA6);

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: primary),
  primaryColor: primary,
  scaffoldBackgroundColor: Color(0xFFF3F4F6),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
  ),
  textTheme: TextTheme(
    bodyMedium: TextStyle(fontSize: 16, height: 1.5),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  ),
);
```

Notes:
- Keep tokens in a small constants file for easy overrides and CI-safe updates.
- Prefer `ColorScheme` and `ThemeExtensions` for custom tokens.

---

## 3. Typography (mobile sizes)
- Display / Headline: 24sp — 28sp (bold for headers)
- Title: 18sp — 20sp (semibold)
- Body: 14sp — 16sp (regular)
- Small / Caption: 12sp

Use `height` around 1.3–1.6 for better readability on small screens.

---

## 4. Components (Flutter mapping)
- Buttons: Use `ElevatedButton` with `elevatedButtonTheme` for primary CTAs. Secondary actions use `OutlinedButton`.
- Cards: Use `Card` with `margin: EdgeInsets.all(12)` and `shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))`.
- Inputs: `TextFormField` with `InputDecoration` and 12–16px vertical padding. Show inline error text using `FormField` validators.
- App Bars: `AppBar` with `centerTitle: false`, `elevation: 0`, rounded bottom when needed.
- Bottom Navigation: use `BottomNavigationBar` with 3–5 items; prefer icons + label, active color = primary.
- Modals & Sheets: prefer `showModalBottomSheet` for flows that require context retention. Use full-screen dialogs for onboarding/critical flows.
- Toasts: use `ScaffoldMessenger.of(context).showSnackBar(...)` with compact height and action buttons.

---

## 5. Dark Mode
- Mirror semantic tokens into dark variants. Use `ThemeMode.system` and test contrast with small text (14sp) at 4.5:1.

---

## 6. Accessibility & Localization
- Color contrast: aim for WCAG AA for body text; test on-device with accessibility settings.
- Font scaling: test with `MediaQuery.textScaleFactor` up to 1.5.
- RTL support: keep layout direction aware (`Directionality` widget).

---

## 7. Assets & Tokens pipeline
- Store icons and SVGs in `assets/icons/` and declare them in `pubspec.yaml`.
- Consider exporting tokens as a small JSON (src/tokens.json) and add a tiny generator to produce `lib/core/theme/tokens.dart`.

Example tokens JSON snippet:

```json
{
  "color": {"primary":"#0066FF","secondary":"#00BFA6","neutral-900":"#111827"},
  "space": {"sm":8,"md":16,"lg":24},
  "radius": {"md":12}
}
```

---

## 8. Implementation notes & best practices
- Keep tokens in `lib/core/theme/` and export a single `tokens.dart` for app code.
- Use Riverpod/Provider to expose runtime theme toggles and `ThemeMode` state.
- Prefer composition over inheritance: small widgets (e.g., `AppPrimaryButton`) wrap Material widgets and read tokens.

---

## 9. Screen Designs & Mobile Implementation

This section maps each design screen to Flutter components and explains how to build them for mobile.

### 9.1 Student Login Screen

**What it shows:**
- A clean login page for students with email and password input fields
- A large primary-colored "Sign In" button (red/magenta) at the bottom
- Helper text explaining how to get credentials
- The page fills the mobile screen with centered content

**How to build it:**
- Use a `SingleChildScrollView` to let the form scroll if the keyboard appears
- Create a form with two `TextFormField` widgets:
  - First for email with `keyboardType: TextInputType.emailAddress`
  - Second for password with `obscureText: true` to hide the password
- Both fields should have the same padding and rounded corners (use `borderRadius: BorderRadius.circular(12)`)
- Add a full-width `ElevatedButton` for sign-in below the form
- Style the button with the primary color (red/pink) and make it tall enough to tap easily on mobile
- Add helper text below the button in a smaller font

**Key spacing (use tokens, not hardcoded values):**
- `md` padding on all sides of the screen (16px)
- `md` gap between the two input fields
- `lg` gap between password field and button (24px)
- `md` gap between button and helper text

*Note: Always use token names (`md`, `lg`, etc.) in your code, not pixel values. Tokens allow easy theme updates across the entire app.*

---

### 9.2 Parent Sign-Up Screen

**What it shows:**
- A form for parents to create an account with 8 fields: first name, last name, mobile number, email, gender dropdown, province dropdown, password, and confirm password
- A checkbox for accepting terms and conditions
- A large primary-colored "Create account" button (red/magenta)
- A secondary white button with text "Continue with Google"
- The page scrolls vertically on mobile since there are many fields

**How to build it:**
- Use `SingleChildScrollView` to handle the scrolling form on small screens
- Create `TextFormField` widgets for text inputs (name, email, password)
- Use `DropdownButtonFormField` for gender and province selections to show dropdown menus
- For the mobile number field, use `keyboardType: TextInputType.phone` to show the number pad
- Add a `CheckboxListTile` for the terms agreement - this gives a larger tap target on mobile
- Stack two buttons at the bottom:
  - Primary button (red/magenta from tokens) for "Create account"
  - Outlined white button below it for "Continue with Google"
- Make sure all inputs are vertically stacked with consistent spacing

**Key spacing (use tokens, not hardcoded values):**
- `md` padding around the entire form (16px)
- `md` gap between each form field
- `sm` gap between checkbox and button area (8px)
- `sm` gap between the two buttons

*Always reference tokens in code, not pixel literals.*

---

### 9.3 Student Home (Dashboard) Screen

**What it shows:**
- A dashboard for students showing their available balance and spending for the month
- Quick action cards below (like "Scan QR to Pay", "Request Money", "Emergency Request")
- A recent activity section showing the last 3 days of transactions
- A transaction history section at the bottom
- A bottom navigation bar with 4 items: Home, Rewards, My Games, Profile

**How to build it:**
- Place an `AppBar` at the top (pink background) with the app name
- Below that, create two stat cards using `Card` widgets arranged side-by-side (use `Row`):
  - Left card shows available balance with an icon
  - Right card shows spending this month with an icon
  - Use `Padding` to add 12px margin between cards
- Create a "Quick Actions" row with 3 clickable cards arranged horizontally (use `SingleChildScrollView` with `scrollDirection: Axis.horizontal` if they don't all fit)
- Each action card should have:
  - A circular icon background (primary color from tokens)
  - An icon in the center
  - A label below
- For empty sections (Recent Activity and Transaction History), show a centered icon, a message, and explanation text
- At the bottom, add a `BottomNavigationBar` with 4 nav items - use icons + labels
- Each item in the navbar should be tappable and lead to different screens

**Key spacing (use tokens, not hardcoded values):**
- `md` padding on all sides (16px)
- `md` gaps between sections
- `sm` margin inside card containers (8px)
- Cards should have `medium` border radius (12px)

*Reference token names in your Flutter code, not pixel values.*

---

### 9.4 Parent Home (Dashboard) Screen

**What it shows:**
- Similar to student dashboard but with parent-specific information
- Family balance and this month's spending at the top
- Quick actions focused on parent tasks: Emergency Fund Transfer, Recurring Auto Payments, Wallet Top-up, Manage Spending Limits
- A recharge section with options for airtime, data, electricity, and cable TV
- A "Your Children" section showing managed child accounts with an "Add Child" button
- A safety alerts section showing spending pattern notifications
- Bottom navigation bar with: Home, Wallet, Pay, Rewards

**How to build it:**
- Use similar layout to student dashboard but with parent-specific cards
- The top stat cards (Family Balance, This Month) are the same pattern as student - two cards side-by-side
- Quick Actions is now a 2x2 grid of cards instead of a single row:
  - Use `GridView` with 2 columns
  - Each card is tappable and has an icon, title
  - Make cards equal height on mobile (around 100-120px height)
- Add a "Recharge" section as a horizontal scrolling row of 4 square icon buttons:
  - Each button has a primary-colored square background (from tokens), centered icon, and label below
  - Use `SingleChildScrollView` with `scrollDirection: Axis.horizontal`
- "Your Children" section shows child cards or empty state with "Add Child" button on the right
- Safety Alerts shows a status card with an icon and message, plus a settings button
- Use same bottom navigation pattern as student dashboard

**Key spacing (use tokens, not hardcoded values):**
- `md` padding around the screen (16px)
- `md` gaps between major sections
- `sm` gaps within grid items (8px)
- Grid items should be square (equal width and height)
- Bottom nav items spaced evenly

*Always use token names in code: `AppSpacing.md`, `AppRadii.medium`, etc.*

---

### 9.5 Website Landing Page

**What it shows:**
- Navigation header with logo, menu links, and Login/Sign Up buttons
- Hero section with:
  - Large primary-colored headline "Smart Student Finance" (red/magenta from tokens)
  - Purple subheading with the tagline
  - Gray body text explaining what the app does
  - Placeholder for a right-side hero image
- Below that, section placeholders for Features, About Us, Pricing, and Footer

**Note:** This is a web design, not mobile-specific. The mobile version would stack everything vertically.

**How to build it (if creating a web version):**
- Use a `Column` for vertical stacking on mobile, or `Row` for side-by-side on desktop
- Header: use an `AppBar` or custom `Container` with horizontal layout (logo on left, nav links in middle, buttons on right)
- Hero section: `Column` with text on the left and image on the right (or stacked on very small screens)
- Use `SingleChildScrollView` to allow scrolling when content exceeds screen height
- Section placeholders can be simple `Container` widgets with background colors and centered text

---

## 10. Mobile Screen Layout Guidelines

**Responsive design on mobile:**
- Never hardcode pixel sizes for spacing in code - always use token names (`md`, `lg`, `sm`, etc.) which map to pixel values
- Test your layouts on phones with screen widths 300px to 400px
- Make sure buttons and tappable areas are at least 48px tall for easy thumb access on mobile (define this as a token: `minTapSize: 48`)
- Keep text readable at phone distance (not too small)

**Avoiding common mobile issues:**
- Don't place important content near the edges - use `md` token padding on all sides (instead of hardcoding 16px)
- Keep form fields simple - one per line on mobile, not side-by-side
- Make sure the bottom navigation bar doesn't overlap content
- Test with the on-screen keyboard showing - leave enough space above the keyboard for users to see what they're typing

**Testing your layouts:**
- Run `flutter run` on a phone or emulator to see the actual mobile view
- Use the Flutter DevTools to check responsive behavior at different screen sizes
- Make sure all text scales properly when device text size settings are increased

---