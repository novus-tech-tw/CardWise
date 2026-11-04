<div align="center">

# CardWise

### Maximize Your Credit Card Rewards

<p>
  <a href="https://swift.org/"><img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift"></a>
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/Platform-iOS%2017+-blue.svg" alt="Platform"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License"></a>
  <a href="https://github.com/tmj-studio/CardWise/stargazers"><img src="https://img.shields.io/github/stars/tmj-studio/CardWise?style=social" alt="Stars"></a>
</p>

<p>
  <a href="docs/README_EN.md"><strong>Documentation</strong></a>
</p>

<p>
  <img src="Screenshots/home.png" width="180" alt="Home">
  <img src="Screenshots/recommend.png" width="180" alt="Recommend">
  <img src="Screenshots/cards.png" width="180" alt="Cards">
  <img src="Screenshots/spending.png" width="180" alt="Spending">
</p>

</div>

---

## What is CardWise?

An iOS app that recommends the best credit card for every purchase. Supports 60+ US credit cards with accurate reward tracking for fixed, rotating, and selectable categories.

---

## Key Features

| Feature | Description |
|---------|-------------|
| Smart Recommendations | Get the best card for each purchase |
| 60+ Credit Cards | Comprehensive US credit card database |
| Rotating Categories | Track quarterly bonus activations |
| Spending Analytics | Visualize spending with charts |
| Receipt Scanning | OCR-powered expense logging |
| Bonus Tracker | Never miss sign-up bonus deadlines |
| Home Widget | Use a custom purchase, your last checked purchase, or a favorite |
| Benefit Reminders | Optional alerts before unused statement credits reset |
| Siri & Shortcuts | Find a card by merchant or category and purchase amount |
| Favorites & Pins | Save frequent purchases and pin wallet cards |
| Merchant Offers | Track issuer offers and received savings manually |
| Annual Card Value | Compare recorded rewards and credit usage against fees you enter |
| Coming Up | Open upcoming credit resets, offers, sign-up goals, and activation checks from Home |
| Saved Merchant Categories | Remember your own category choice across searches, Shortcuts, and widgets |
| Purchase Comparison | Compare estimated rewards, cap effects, and one eligible saved offer per card |
| Purchase Conditions | Confirm specific card and booking terms before including special rates |
| Private by Design | Your data stays on-device and syncs via your own iCloud |

---

## Using Purchase Tools

- On **Home**, tap a **Coming Up** action to update credit usage, check quarterly activation, review a sign-up goal, or edit an offer.
- On **Recommend**, change a merchant's category and tap **Remember** to use it next time. Manage or forget these device-local choices in **Settings → Saved Merchant Categories**.
- **Compare this purchase** shows purchase rewards separately from sign-up goals. Including an offer requires your confirmation that it can accompany those rewards; multiple offers on the same card are not added together. Actual received savings remain separate records.
- Expand **Purchase conditions** to confirm the specific rate terms that apply. Unconfirmed special rates are excluded.
- In **Settings → Ranking, Point Values & Widgets**, choose a custom purchase, the last checked purchase, or a favorite. Tapping a widget opens that purchase in Recommend, where special rate terms can be confirmed again.

## Quick Start

```bash
git clone https://github.com/tmj-studio/CardWise.git
cd CardWise
open CardWise.xcodeproj
# Press Cmd + R to build and run
```

**Requirements:** iOS 17+ · Xcode 15+ · Swift 5.9+

---

## Documentation

- [Full Documentation](docs/README_EN.md)
- [Contributing Guide](CONTRIBUTING.md)

---

## Tech Stack

```
SwiftUI · MVVM · SwiftData · CloudKit · WidgetKit · Vision (OCR)
```

---

## Community

- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)
- [Changelog](CHANGELOG.md)

---

## Support

- [Report Bug](https://github.com/tmj-studio/CardWise/issues)
- [Request Feature](https://github.com/tmj-studio/CardWise/issues)
- [Discussions](https://github.com/tmj-studio/CardWise/discussions)

---

<div align="center">

**If this project helps you, please give it a star!**

<a href="https://github.com/tmj-studio/CardWise/stargazers">
  <img src="https://img.shields.io/github/stars/tmj-studio/CardWise?style=for-the-badge&logo=github" alt="GitHub Stars">
</a>

</div>
