import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'lpapi_thermal_printer_method_channel.dart';

abstract class LpapiThermalPrinterPlatform extends PlatformInterface {
  /// Constructs a LpapiThermalPrinterPlatform.
  LpapiThermalPrinterPlatform() : super(token: _token);

  static final Object _token = Object();

  static LpapiThermalPrinterPlatform _instance =
      MethodChannelLpapiThermalPrinter() as LpapiThermalPrinterPlatform;

  /// The default instance of [LpapiThermalPrinterPlatform] to use.
  ///
  /// Defaults to [MethodChannelLpapiThermalPrinter].
  static LpapiThermalPrinterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LpapiThermalPrinterPlatform] when
  /// they register themselves.
  static set instance(LpapiThermalPrinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<Map<String, dynamic>>> searchPrinters() {
    throw UnimplementedError('searchPrinters() has not been implemented.');
  }

  Future<List<Map<String, dynamic>>> discoverPrinters() {
    throw UnimplementedError('discoverPrinters() has not been implemented.');
  }

  Future<bool> connectPrinter(String address) {
    throw UnimplementedError('connectPrinter() has not been implemented.');
  }

  Future<bool> connectFirstPrinter() {
    throw UnimplementedError('connectFirstPrinter() has not been implemented.');
  }

  Future<bool> disconnectPrinter() {
    throw UnimplementedError('disconnectPrinter() has not been implemented.');
  }

  Future<String> getPrinterStatus() {
    throw UnimplementedError('getPrinterStatus() has not been implemented.');
  }

  Future<bool> printText(String text, {int width = 48, int height = 50}) {
    throw UnimplementedError('printText() has not been implemented.');
  }

  Future<bool> print1DBarcode(
    String barcode, {
    String text = '',
    int width = 48,
    int height = 50,
  }) {
    throw UnimplementedError('print1DBarcode() has not been implemented.');
  }

  Future<bool> print2DBarcode(
    String barcode, {
    int width = 48,
    int height = 50,
  }) {
    throw UnimplementedError('print2DBarcode() has not been implemented.');
  }

  Future<bool> printImage(String base64Image) {
    throw UnimplementedError('printImage() has not been implemented.');
  }

  Future<bool> setPrintDensity(int density) {
    throw UnimplementedError('setPrintDensity() has not been implemented.');
  }

  Future<bool> setPrintSpeed(int speed) {
    throw UnimplementedError('setPrintSpeed() has not been implemented.');
  }
}
