# Changelog

All notable changes to this project will be documented in this file.

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
