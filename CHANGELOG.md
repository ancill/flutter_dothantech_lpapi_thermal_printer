# Changelog

All notable changes to this project will be documented in this file.

## [2.6.4] - 2025-01-04

### Changed

- **1D Barcode Label Format**: Updated to landscape 50×40mm with compact proportions
  - Product text: 5mm font at top
  - Barcode: 15mm height (compact but scannable)
  - Barcode text: 3.5mm font at bottom
  - Consistent 2mm margins matching portrait lot labels
  - Default dimensions: `width=50`, `height=40`

## [2.6.3] - 2025-01-04

### Changed

- **Left-aligned QR**: QR code now left-aligned to match text below

## [2.6.2] - 2025-01-04

### Changed

- **Compact Label Size**: Reduced label height from 55mm to 50mm
  - QR code reduced from 27mm to 22mm (still easily scannable)
  - LOT font reduced from 7mm to 6mm
  - Tighter spacing for more compact layout
  - Default dimensions: `width=40`, `height=50`

## [2.6.1] - 2025-01-04

### Fixed

- **Portrait Mode Rotation**: Added 90° rotation to `printLotLabel` so physical 55×40mm labels print correctly in portrait orientation
  - Labels now print with QR on top and text below as intended
  - Physical label feeds as 55×40mm landscape but content is rotated for portrait display

## [2.6.0] - 2025-01-04

### Changed

- **Portrait Lot Label Format** (`printLotLabel`): Updated to 40×55mm portrait format
  - Label size changed from 55×30mm landscape to 40×55mm portrait
  - QR code (~27mm) centered on top half for easy scanning
  - LOT ID with large font (7mm) below QR
  - SKU with large font (5mm) below LOT
  - Bottom info line: shortened date (MM-DD), location code, zone badge
  - Default dimensions updated: `width=40`, `height=55`

### Layout

```
┌────────────────────────┐
│                        │
│      ┌────────┐        │
│      │   QR   │        │
│      │  CODE  │        │
│      └────────┘        │
│                        │
│  LOT 584               │
│  SKU-12345             │
│  01-05  A-03-01  FRZ   │
└────────────────────────┘
```

## [2.5.0] - 2025-01-04

### Changed

- **Compact Lot Label Format** (`printLotLabel`): Updated to 55×30mm landscape format for smaller labels
  - Label size changed from 70×50mm to 55×30mm (compact landscape orientation)
  - QR code reduced from 40mm to 22mm to fit smaller label
  - LOT ID displayed with large font (6mm) on right side of QR
  - SKU displayed with large font (5mm) below LOT ID
  - Bottom info (EXP, LOC, Zone) now dynamically spreads based on available items
  - No divider line - cleaner layout
  - Default dimensions updated: `width=55`, `height=30`

### Layout

```
┌─────────────────────────────────────────────────────┐
│ ┌──────────┐  LOT 584                               │
│ │          │                                        │
│ │  QR CODE │  SKU-12345                             │
│ │          │                                        │
│ └──────────┘                                        │
│ EXP 2025-01-05    LOC A-03-01    * FRZ              │
└─────────────────────────────────────────────────────┘
```

## [2.4.0] - 2025-01-04

### Changed

- **New Lot Label Format** (`printLotLabel`): Updated to 70×50mm landscape format for better readability
  - Label size changed from 50×30mm to 70×50mm (landscape orientation)
  - QR code enlarged from 22mm to 40mm for easier scanning
  - LOT ID displayed with large font (8mm) for quick visual identification
  - SKU displayed with large font (6mm) below LOT ID
  - Bottom section with EXP date, LOC code, and Zone badge separated by divider line
  - Default dimensions updated: `width=70`, `height=50`

### Layout

```
┌──────────────────────────────────────────────────────────────┐
│ ┌─────────────────┐                                          │
│ │                 │    LOT 584                               │
│ │    QR CODE      │                                          │
│ │                 │    SKU-12345                             │
│ └─────────────────┘                                          │
│──────────────────────────────────────────────────────────────│
│ EXP 2025-01-05      │  LOC A-03-01      │  [* FRZ]           │
└──────────────────────────────────────────────────────────────┘
```

## [2.3.0] - 2025-01-03

### Added

- **Temperature Zone Support for Lot Labels** (`printLotLabel`): Added `zone` parameter to display storage requirements
  - Supports three zones: `ambient`, `chill`, `frozen`
  - Zone badge displayed prominently at top of text area: `[* FRZ]`, `[+ CHL]`, `[o AMB]`
  - Visual icons approximated for thermal printer compatibility (❄→*, ❊→+, ☀→o)

### Changed

- **Redesigned Lot Label Layout** for better visual hierarchy and space utilization
  - QR code reduced from 24mm to 22mm for more text space
  - Zone badge shown first when provided
  - SKU/product name allows 2-line wrapping
  - Location code and LOT ID now share bottom row for better space efficiency
  - Improved text sizing and spacing throughout

### Features

- `printLotLabel({lotId, sku, expiryDate?, locationCode?, zone?, width?, height?})` - Now accepts optional `zone` parameter ("ambient", "chill", or "frozen")

## [2.2.0] - 2024-12-30

### Added

- **Weighted Item Label Printing** (`printWeightedItemLabel`): New method for printing pick/pack weighted item labels
  - 50×30mm label format optimized for items sold by weight (apples, cheese, etc.)
  - Left side: QR code (~24×24mm) encoding "PKG:{orderId}:{weight}" for verification
  - Right side: Stacked text fields (product name, weight in kg, total price, order reference)
  - Used during picking workflow - label is attached to plastic bag with weighed product
  - Configurable currency symbol (default: ₽)

### Features

- `printWeightedItemLabel({productName, weightKg, totalPrice, orderId, currencySymbol?, width?, height?})` - Print weighted item labels for q-commerce pick/pack workflows

## [2.1.0] - 2024-12-29

### Added

- **Inventory Lot Label Printing** (`printLotLabel`): New method for printing darkstore/warehouse inventory labels
  - 50×30mm label format optimized for thermal printers @203dpi
  - Left side: QR code (~24×24mm) encoding the lot ID for 2D scanner pickup
  - Right side: Stacked text fields (SKU, expiry date, location code, lot ID)
  - Configurable label dimensions via `width` and `height` parameters
  - Optional fields: `expiryDate` and `locationCode`

### Features

- `printLotLabel({lotId, sku, expiryDate?, locationCode?, width?, height?})` - Print compound labels with QR code and text for inventory management and pick/pack workflows

## [2.0.1] - 2024-10-21

### Changed

- Optimized package description to be within the recommended 60-180 character range for better search engine display

## [2.0.0] - 2024-10-21

### Added

- **iOS Support**: Full iOS implementation with feature parity to Android
  - Bluetooth printer discovery using LPAPI SDK
  - Direct connection to printers by name
  - Print text, 1D barcodes, 2D QR codes, and images
  - Adjustable print density (0-20, auto-mapped to iOS range 0-15)
  - Adjustable print speed (1-5)
  - Connection status monitoring and event callbacks
  - All features available on both iOS and Android platforms

### Changed

- Updated README with comprehensive iOS setup instructions
- Enhanced example app with platform detection indicator (shows "Running on iOS" or "Running on Android")
- Improved documentation with iOS-specific troubleshooting guide
- Added `IOS_IMPLEMENTATION.md` technical documentation
- Updated package description to highlight cross-platform support

### Technical Details

- Added Objective-C implementation (`FlutterDothantechLpapiThermalPrinterPlugin.m`)
- Integrated LPAPI SDK for iOS (supports iOS 12.0+)
- Implemented conditional library linking for device and simulator builds
- Added proper CocoaPods configuration with separate libraries for device/simulator
- Updated pubspec.yaml to include iOS platform registration

### Platform Support

- Android: Full support (unchanged)
- iOS: **NEW** - Full support added

### Breaking Changes

- Version bumped to 2.0.0 to indicate major feature addition (iOS support)
- No API changes - existing Android code remains fully compatible

## [1.0.0] - 2024-10-01

### Added

- Initial release of LPAPI Thermal Printer Plugin
- Bluetooth printer discovery without requiring manual pairing
- Direct connection to Dothantech thermal label printers
- Text printing with customizable label dimensions
- 1D barcode printing with optional text labels
- QR code (2D barcode) printing support
- Image printing from base64 encoded data
- Adjustable print density (darkness) settings
- Adjustable print speed settings
- Real-time printer connection status monitoring
- Support for both paired and unpaired printer discovery
- Comprehensive example application
- Full API documentation

### Features

- `searchPrinters()` - Find already paired printers
- `discoverPrinters()` - Discover all nearby printers (paired and unpaired)
- `connectPrinter(address)` - Connect to specific printer by MAC address
- `connectFirstPrinter()` - Quick connect to first available printer
- `disconnectPrinter()` - Disconnect from current printer
- `getPrinterStatus()` - Get current connection status
- `printText()` - Print plain text
- `print1DBarcode()` - Print 1D barcodes with optional labels
- `print2DBarcode()` - Print QR codes
- `printImage()` - Print images from base64 data
- `setPrintDensity()` - Adjust print darkness (0-20)
- `setPrintSpeed()` - Adjust print speed (1-5)

### Platform Support

- Android: Full support with LPAPI SDK integration
- iOS: Not yet implemented

### Dependencies

- Flutter SDK >=3.3.0
- Dart SDK >=3.9.2
- Dothantech LPAPI SDK (included)

## [0.0.1] - 2024-09-30

### Added

- Initial project setup
- Basic plugin structure
- Android platform configuration
