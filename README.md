# Valley Farm Secrets Store (Flutter)

This project is a standalone Flutter 3.x experience that recreates the Valley
Farm Secrets web store for mobile and tablet form factors. It includes the full
product catalogue, special offers carousel, filtering controls, cart
management, and an end-to-end checkout flow.

## Features

- **Seeded catalogue** with the Valley Farm Secrets categories, subcategories,
  and products defined in `lib/data/store_data.dart`.
- **Responsive layout** that presents sidebar filters on wide screens and a
  drawer-based experience on smaller devices.
- **Special offers carousel** that highlights products currently on promotion.
- **Filtering & sorting** by search query, category, specials, and multiple
  sort orders.
- **Reusable product card** widget with pricing, special badges, and cart
  actions.
- **Provider-based cart state** with add, update, remove, and clear
  operations.
- **Cart bottom sheet** accessed from a floating action button or the app bar,
  including inline quantity controls and subtotals.
- **Checkout dialog** supporting gifts, delivery/collection options, payment
  method selection, and a simulated POST to `/api/orders`.

## Getting started

```sh
flutter pub get
flutter run
```

> **Note:** The checkout flow sends a demo POST request to
> `https://example.com/api/orders`. Update `ordersEndpoint` in
> `lib/constants.dart` to point to a real backend before shipping to
> production.

## Project structure

```
lib/
├── constants.dart          # Shared colours and constants
├── data/                   # Static category and product seed data
├── models/                 # Category, sub-category, product, and cart models
├── providers/              # Cart provider using ChangeNotifier
├── screens/                # Main store screen
├── services/               # Order submission service
└── widgets/                # Reusable UI components (product cards, filters, etc.)
```

## Assets & theming

- Placeholder marketing imagery uses a royalty-free produce photo served from
  Unsplash so the repository stays free of binary assets.
- The Material 3 theme uses the Valley Farm colour palette defined in
  `lib/constants.dart`.

## Tests & linting

Run the standard Flutter tooling to analyse and test the project:

```sh
flutter analyze
flutter test
```
