# Changelog

All notable changes to this project will be documented in this file.

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
