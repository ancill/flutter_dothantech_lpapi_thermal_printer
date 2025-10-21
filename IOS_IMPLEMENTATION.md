# iOS Implementation Guide

## Overview

This document describes the iOS implementation for the Flutter Dothantech LPAPI Thermal Printer plugin.

## Architecture

The iOS implementation follows the same architecture as the Android version, providing feature parity across both platforms.

### Files Structure

```
ios/
├── Classes/
│   ├── FlutterDothantechLpapiThermalPrinterPlugin.h  # Plugin header
│   └── FlutterDothantechLpapiThermalPrinterPlugin.m  # Plugin implementation
├── Frameworks/
│   ├── LPAPI-Device.a        # Static library for physical devices
│   ├── LPAPI-Simulator.a     # Static library for iOS simulator
│   └── LPAPI.h               # LPAPI header file
└── flutter_dothantech_lpapi_thermal_printer.podspec  # CocoaPods specification
```

## Implementation Details

### 1. Method Channel

The plugin uses a method channel named `lpapi_thermal_printer` to communicate between Dart and native iOS code.

### 2. LPAPI Integration

The iOS LPAPI SDK provides the following key APIs that we've integrated:

- **scanPrinters**: Discover available Bluetooth printers
- **openPrinter**: Connect to a specific printer
- **closePrinter**: Disconnect from printer
- **startDraw/endDraw**: Begin and end a print job
- **drawText**: Print text
- **drawBarcode**: Print 1D barcodes
- **drawQRCode**: Print QR codes
- **printImage**: Print images
- **setPrintDarkness**: Set print density (0-15 on iOS, mapped from 0-20)
- **setPrintSpeed**: Set print speed (1-5)

### 3. Supported Features

All features from the Android implementation are supported on iOS:

- ✅ Bluetooth printer discovery
- ✅ Connect to specific printer
- ✅ Connect to first available printer
- ✅ Print text
- ✅ Print 1D barcodes with optional text
- ✅ Print QR codes
- ✅ Print images from base64
- ✅ Adjust print density (darkness)
- ✅ Adjust print speed
- ✅ Connection status monitoring

### 4. Platform Differences

#### Printer Identification
- **Android**: Uses MAC address (e.g., "00:11:22:33:44:55")
- **iOS**: Uses printer name (e.g., "P1-12345")

#### Bluetooth Discovery
- **Android**: Can discover unpaired devices via Bluetooth discovery
- **iOS**: Discovers both paired and available Bluetooth printers via LPAPI's scanPrinters

#### Print Density Range
- **Android**: LPAPI uses 0-20 range
- **iOS**: LPAPI uses 0-15 range (automatically mapped from 0-20)

### 5. Static Libraries

The iOS SDK includes two static libraries stored separately:
- **Frameworks/device/libLPAPI.a**: For physical iOS devices (arm64)
- **Frameworks/simulator/libLPAPI.a**: For iOS simulator (x86_64/arm64)

Both libraries contain arm64 architecture, so they cannot be combined into a single fat binary. Instead, the podspec uses conditional linking based on the target SDK:
- Device builds (`sdk=iphoneos*`) link against `device/libLPAPI.a`
- Simulator builds (`sdk=iphonesimulator*`) link against `simulator/libLPAPI.a`

This approach ensures compatibility with both M1/M2 Macs (arm64 simulator) and Intel Macs (x86_64 simulator), as well as all iOS devices.

## Permissions

iOS requires the following permissions in Info.plist:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access to connect to thermal printers</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth access to connect to thermal printers</string>
```

## Deployment

### Minimum Requirements
- iOS 12.0 or later
- Xcode 12.0 or later
- CocoaPods for dependency management

### Installation

When a Flutter app includes this plugin:

1. Flutter will automatically register the iOS platform code
2. CocoaPods will integrate the LPAPI static library
3. The plugin will be available through the same Dart API as Android

## Testing

To test the iOS implementation:

1. Connect an iOS device or start the simulator
2. Navigate to the example directory: `cd example`
3. Run the example app: `flutter run -d ios`
4. The app will display a platform indicator showing "Running on iOS"
5. Use the UI to discover printers and test printing features

## Example Usage

The example app (`example/lib/main.dart`) demonstrates:
- Platform detection (shows "Running on iOS" with iOS icon)
- Printer discovery
- Connection management
- All printing operations (text, barcodes, QR codes)
- Print settings adjustment

## Troubleshooting

### Common Issues

1. **Library not found**: Ensure CocoaPods is properly installed and run `pod install` in the ios directory
2. **Bluetooth permissions denied**: Check Info.plist has the correct permission keys
3. **Printer not found**: Ensure printer is powered on and in discoverable mode
4. **Connection fails**: Try restarting both the app and the printer

### Debug Logging

The plugin includes NSLog statements for debugging:
- `[iOS] searchPrinters called`
- `[iOS] connectPrinter called with address: ...`
- `[iOS] printText called: ...`
- etc.

Enable console logging in Xcode to see these messages.

## Future Enhancements

Possible improvements for future versions:
- Background printing support
- Printer firmware updates
- Advanced barcode encoding options
- Custom font support
- Print job queuing
