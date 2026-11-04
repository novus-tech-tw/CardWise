# CardWise

> Maximize your credit card rewards with smart recommendations.

An iOS app that helps you choose the best credit card for every purchase, so you never miss out on rewards.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](../LICENSE)

---

## Screenshots

<p align="center">
  <img src="../Screenshots/home.png" width="200" alt="Home Screen">
  <img src="../Screenshots/recommend.png" width="200" alt="Recommendations">
  <img src="../Screenshots/cards.png" width="200" alt="Card Management">
  <img src="../Screenshots/spending.png" width="200" alt="Spending Analytics">
</p>

---

## Features

| Feature | Description |
|---------|-------------|
| **Smart Recommendations** | Get the best card suggestion based on merchant or category |
| **60+ Credit Cards** | Comprehensive database of major US credit cards with accurate reward data |
| **Reward Tracking** | Track fixed, rotating, and selectable category bonuses |
| **Spending Analytics** | Visualize spending patterns with interactive charts |
| **Receipt Scanning** | OCR-powered receipt scanning for quick expense logging |
| **Sign-Up Bonus Tracker** | Never miss a sign-up bonus deadline |
| **Home Screen Widget** | Quick access to recommendations without opening the app |
| **Benefit Expiry Reminders** | Optional notifications 7, 3 and 1 days before unused credits reset |
| **Siri & Shortcuts** | Query your saved wallet by merchant or category and purchase amount |
| **Favorites & Pins** | Save frequent merchants/categories on this device; pin cards in your synced wallet |
| **Manual Merchant Offers** | Record offer conditions, activation confirmation and savings received |
| **Annual Card Value** | Separate recorded rewards and credit usage from potential catalog value; enter actual fees to calculate net value |
| **Privacy First** | Data lives on-device and syncs via your own iCloud — no accounts, no CardWise servers (only read-only card-data and app-update checks) |

### Using Rewards Tools

- **Benefit reminders:** Enable **Settings → Benefit Expiry Reminders** and allow iOS notifications. Alerts use your recorded credit usage. Opening CardWise refreshes the nearest upcoming alerts; iOS controls delivery. Fully used credits and removed cards are excluded.
- **Shortcuts:** Add **Best Card for a Merchant** or **Best Card for a Category** in Shortcuts, or use **Settings → Siri & Shortcuts**. Choose an amount. Actions require an unlocked device and use the same saved spending caps, point values and ranking preference as the app. Unknown merchants ask for another value; the category action allows an explicit choice.
- **Favorites and pins:** Tap the star on **Recommend** to save the current merchant/category. Manage favorites with the list icon. Use the pin beside a card in **My Cards** to move it to the top of the wallet; reward ranking is unchanged.
- **Merchant offers:** Open **Home → Offers** or a card's **Merchant Offers**. Enter the exact merchant name, reward, purchase minimum and final eligible day. Confirm activation yourself. Matching merchant searches show estimated offer savings separately from reward rankings. Record posted savings only, without duplicating rewards or statement credits already tracked elsewhere. Archive old offers to hide them from recommendations while retaining their received savings in annual history; restore them from the archived list.
- **Annual value:** Open **Home → Annual Value**, select a calendar year and enter each card's actual fee total, including 0 for waived fees. Save the fee total to calculate net recorded value. Purchase rewards remain saved estimates; statement credit usage is assigned to its credit period. Unrecorded amounts and redemptions are not inferred.

Wallet pins, manual offers and fee totals use the existing private iCloud wallet sync. Favorites and notification preferences remain device-specific. No bank connection or additional network service is required.

### Supported Cards

**60+ cards from major US issuers:**
- **Chase** - Sapphire Preferred/Reserve, Freedom Flex/Unlimited, Ink Business, Amazon Prime, United, Southwest, Marriott
- **American Express** - Gold, Platinum, Blue Cash Preferred/Everyday, Delta SkyMiles, Hilton Honors
- **Citi** - Double Cash, Custom Cash, Premier, Strata Premier, Costco Anywhere, AAdvantage
- **Capital One** - Savor/SavorOne, Venture X/Venture, Quicksilver
- **Discover** - it Cash Back, Chrome, Miles, Student
- **Bank of America** - Customized Cash, Premium Rewards, Travel Rewards, Alaska Airlines
- **US Bank** - Cash+, Altitude Go/Connect/Reserve
- **Wells Fargo** - Active Cash, Autograph/Journey
- **Others** - Apple Card, Bilt, PayPal, Venmo, Target RedCard, Walmart

### Supported Card Types

| Type | Example | How It Works |
|------|---------|--------------|
| **Fixed Categories** | Amex Gold 4x Dining | Always earns bonus rate |
| **Rotating Categories** | Chase Freedom Flex 5% | Quarterly bonuses, activation required |
| **Selectable Categories** | BoA Customized Cash 3% | Choose your own bonus category |

---

## Demo

**Try it out:** [Join TestFlight Beta](#) *(coming soon)*

---

## Quick Start

### Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

### Installation

```bash
# Clone the repository
git clone https://github.com/tmj-studio/CardWise.git

# Open in Xcode
cd CardWise
open CardWise.xcodeproj

# Build and run (Cmd + R)
```

---

## How It Works

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Enter Merchant │ ──▶ │ Category Mapping │ ──▶ │  Recommendation │
│  or Category    │     │    Database      │     │     Engine      │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                                          │
                                                          ▼
                                                 ┌─────────────────┐
                                                 │   Best Card +   │
                                                 │  Reward Amount  │
                                                 └─────────────────┘
```

The **RecommendationEngine** evaluates all your cards considering:
- Fixed category bonus multipliers
- Current quarter's rotating categories (activation status)
- User-selected bonus categories
- Spending caps and remaining limits
- Point/mile valuations

---

## Architecture

```
CardWise/
├── App/                    # App entry point
├── Models/                 # Data models
│   ├── CreditCard.swift    # Card definitions & reward configs
│   ├── Spending.swift      # Transaction records
│   ├── Merchant.swift      # Merchant → category mapping
│   └── SpendingCategory.swift
├── Views/                  # SwiftUI views (MVVM)
│   ├── Home/               # Dashboard
│   ├── Cards/              # Card management
│   ├── Spending/           # Expense tracking & charts
│   ├── Recommend/          # Card recommendations
│   └── Settings/           # App settings
├── ViewModels/             # State management
├── Services/               # Business logic
│   ├── CloudStore.swift        # SwiftData + CloudKit persistence (local fallback)
│   ├── CardCatalog.swift       # Cache-first card catalog with bundled fallback
│   ├── RemoteCatalogService.swift # Read-only cards.json refresh from GitHub
│   ├── RecommendationEngine.swift
│   ├── SpendingCapTracker.swift
│   ├── OCRService.swift
│   ├── NotificationService.swift
│   ├── AppUpdateChecker.swift
│   ├── WidgetDataManager.swift
│   └── … (SearchHistoryManager, KeychainHelper)
├── Resources/
│   └── cards.json          # Bundled read-only reward database
└── Utils/                  # Extensions & helpers
```

---

## Tech Stack

| Category | Technology |
|----------|------------|
| UI | SwiftUI |
| Architecture | MVVM |
| Persistence | SwiftData + CloudKit private database (local fallback) |
| Widget | WidgetKit |
| OCR | Vision Framework |
| Backend | None operated by CardWise — read-only card-data & update checks only |
| Card data | Bundled `cards.json`, refreshed weekly via the `Scripts/` pipeline |

---

## Testing

```bash
# Run all tests (Cmd + U in Xcode)

# Or via command line
xcodebuild test -project CardWise.xcodeproj -scheme CardWise \
  -destination 'platform=iOS Simulator,name=iPhone 16' CODE_SIGNING_ALLOWED=NO
```

**Test Coverage** (15 suites in `CardWiseTests/`), including:
- `RecommendationEngineTests` - Card recommendation logic
- `MerchantDatabaseTests` - Merchant to category mapping
- `ModelTests` / `CreditModelTests` - Data model encoding/decoding
- `RemoteCatalogServiceTests` / `CardCatalogTests` - Catalog refresh & caching
- `CloudStoreTests`, `CreditPeriodTests`, `CreditUsage*Tests`, `AppUpdateCheckerTests`, and more

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

### Quick Contribution Guide

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

This project is licensed under the [MIT License](../LICENSE).

---

## Support

- [Report Bug](https://github.com/tmj-studio/CardWise/issues)
- [Request Feature](https://github.com/tmj-studio/CardWise/issues)
- Star this repo if you find it useful!

---

## Acknowledgments

- Credit card data sourced from public issuer information
- Icons from SF Symbols

---

<p align="center">
  Made with love for credit card enthusiasts
</p>
