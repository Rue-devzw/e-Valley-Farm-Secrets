# Valley Farm Secrets Store (Flutter)

This project is a standalone Flutter 3.x experience that recreates the Valley
Farm Secrets web store for mobile and tablet form factors. It includes the full
product catalogue, special offers carousel, filtering controls, cart
management, and an end-to-end checkout flow.

## Features

- **Live WooCommerce integration** that fetches categories and products from
  `https://www.valleyfarmsecrets.com/store`, automatically probing both root and
  `/store` REST API paths with an offline fallback catalogue defined in
  `lib/data/store_data.dart`.
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

> **Note:** The checkout flow posts to the Valley Farm Secrets WooCommerce
> checkout endpoint configured in `lib/constants.dart`. Update
> `storeCheckoutEndpoints` if your deployment requires a different authenticated
> endpoint or additional fallbacks.

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
