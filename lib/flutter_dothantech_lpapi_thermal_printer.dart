import 'flutter_dothantech_lpapi_thermal_printer_platform_interface.dart';

/// Printer information model
class PrinterInfo {
  final String name;
  final String address;
  final String type;

  PrinterInfo({required this.name, required this.address, required this.type});

  factory PrinterInfo.fromMap(Map<String, dynamic> map) {
    return PrinterInfo(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      type: map['type'] ?? '',
    );
  }
}

/// Main plugin class for LPAPI Thermal Printer
class LpapiThermalPrinter {
  /// Get platform version
  Future<String?> getPlatformVersion() {
    return LpapiThermalPrinterPlatform.instance.getPlatformVersion();
  }

  /// Search for available printers (paired devices)
  /// Returns a list of found printers with their information
  Future<List<PrinterInfo>> searchPrinters() async {
    final result = await LpapiThermalPrinterPlatform.instance.searchPrinters();
    return result.map((map) => PrinterInfo.fromMap(map)).toList();
  }

  /// Discover printers using Bluetooth discovery (finds unpaired printers too)
  /// Returns a list of discovered printers
  Future<List<PrinterInfo>> discoverPrinters() async {
    final result = await LpapiThermalPrinterPlatform.instance
        .discoverPrinters();
    return result.map((map) => PrinterInfo.fromMap(map)).toList();
  }

  /// Connect to a printer using its MAC address
  /// Returns true if connection is successful
  Future<bool> connectPrinter(String address) {
    return LpapiThermalPrinterPlatform.instance.connectPrinter(address);
  }

  /// Connect to the first available paired printer
  /// Returns true if connection is successful
  Future<bool> connectFirstPrinter() {
    return LpapiThermalPrinterPlatform.instance.connectFirstPrinter();
  }

  /// Disconnect from the currently connected printer
  /// Returns true if disconnection is successful
  Future<bool> disconnectPrinter() {
    return LpapiThermalPrinterPlatform.instance.disconnectPrinter();
  }

  /// Get the current printer connection status
  /// Returns: 'connected', 'connecting', 'disconnected', or 'unknown'
  Future<String> getPrinterStatus() {
    return LpapiThermalPrinterPlatform.instance.getPrinterStatus();
  }

  /// Print plain text
  /// [text] - The text to print
  /// [width] - Label width in mm (default: 48)
  /// [height] - Label height in mm (default: 50)
  Future<bool> printText(String text, {int width = 48, int height = 50}) {
    return LpapiThermalPrinterPlatform.instance.printText(
      text,
      width: width,
      height: height,
    );
  }

  /// Print 1D barcode with optional text
  /// [barcode] - The barcode data to encode
  /// [text] - Optional text to print above the barcode
  /// [width] - Label width in mm (default: 48)
  /// [height] - Label height in mm (default: 50)
  Future<bool> print1DBarcode(
    String barcode, {
    String text = '',
    int width = 48,
    int height = 50,
  }) {
    return LpapiThermalPrinterPlatform.instance.print1DBarcode(
      barcode,
      text: text,
      width: width,
      height: height,
    );
  }

  /// Print 2D QR code
  /// [barcode] - The data to encode in the QR code
  /// [width] - Label width in mm (default: 48)
  /// [height] - Label height in mm (default: 50)
  Future<bool> print2DBarcode(
    String barcode, {
    int width = 48,
    int height = 50,
  }) {
    return LpapiThermalPrinterPlatform.instance.print2DBarcode(
      barcode,
      width: width,
      height: height,
    );
  }

  /// Print an inventory lot label with QR code and text
  ///
  /// Layout (50x30mm):
  /// - Left: QR code (~24x24mm) encoding [lotId]
  /// - Right (stacked):
  ///   - SKU (largest font)
  ///   - EXP YYYY-MM-DD (if provided)
  ///   - LOC ABC-12 (if provided)
  ///   - LOT {last 10 chars of lotId} (smallest font)
  ///
  /// [lotId] - Unique lot identifier (encoded in QR)
  /// [sku] - Product SKU code (displayed largest)
  /// [expiryDate] - Optional expiry date string (e.g., "2025-03-15")
  /// [locationCode] - Optional location code (e.g., "A-01-02")
  /// [width] - Label width in mm (default: 50)
  /// [height] - Label height in mm (default: 30)
  Future<bool> printLotLabel({
    required String lotId,
    required String sku,
    String? expiryDate,
    String? locationCode,
    int width = 50,
    int height = 30,
  }) {
    return LpapiThermalPrinterPlatform.instance.printLotLabel(
      lotId: lotId,
      sku: sku,
      expiryDate: expiryDate,
      locationCode: locationCode,
      width: width,
      height: height,
    );
  }

  /// Print an image from base64 encoded data
  /// [base64Image] - Base64 encoded image data
  Future<bool> printImage(String base64Image) {
    return LpapiThermalPrinterPlatform.instance.printImage(base64Image);
  }

  /// Set print density (darkness)
  /// [density] - Value from 0 (lightest) to 20 (darkest), default is 6
  Future<bool> setPrintDensity(int density) {
    if (density < 0 || density > 20) {
      throw ArgumentError('Density must be between 0 and 20');
    }
    return LpapiThermalPrinterPlatform.instance.setPrintDensity(density);
  }

  /// Set print speed
  /// [speed] - Value from 1 (slowest) to 5 (fastest), default is 3
  Future<bool> setPrintSpeed(int speed) {
    if (speed < 1 || speed > 5) {
      throw ArgumentError('Speed must be between 1 and 5');
    }
    return LpapiThermalPrinterPlatform.instance.setPrintSpeed(speed);
  }
}
