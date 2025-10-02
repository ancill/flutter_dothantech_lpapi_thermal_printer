import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dothantech_lpapi_thermal_printer/flutter_dothantech_lpapi_thermal_printer.dart';
import 'package:flutter_dothantech_lpapi_thermal_printer/flutter_dothantech_lpapi_thermal_printer_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLpapiThermalPrinterPlatform
    with MockPlatformInterfaceMixin
    implements LpapiThermalPrinterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<Map<String, dynamic>>> searchPrinters() => Future.value([]);

  @override
  Future<List<Map<String, dynamic>>> discoverPrinters() => Future.value([]);

  @override
  Future<bool> connectPrinter(String address) => Future.value(true);

  @override
  Future<bool> connectFirstPrinter() => Future.value(true);

  @override
  Future<bool> disconnectPrinter() => Future.value(true);

  @override
  Future<String> getPrinterStatus() => Future.value('connected');

  @override
  Future<bool> printText(String text, {int width = 48, int height = 50}) =>
      Future.value(true);

  @override
  Future<bool> print1DBarcode(
    String barcode, {
    String text = '',
    int width = 48,
    int height = 50,
  }) => Future.value(true);

  @override
  Future<bool> print2DBarcode(
    String barcode, {
    int width = 48,
    int height = 50,
  }) => Future.value(true);

  @override
  Future<bool> printImage(String base64Image) => Future.value(true);

  @override
  Future<bool> setPrintDensity(int density) => Future.value(true);

  @override
  Future<bool> setPrintSpeed(int speed) => Future.value(true);
}

void main() {
  test('getPlatformVersion', () async {
    LpapiThermalPrinter lpapiThermalPrinterPlugin = LpapiThermalPrinter();
    MockLpapiThermalPrinterPlatform fakePlatform = MockLpapiThermalPrinterPlatform();
    LpapiThermalPrinterPlatform.instance = fakePlatform;

    expect(await lpapiThermalPrinterPlugin.getPlatformVersion(), '42');
  });

  test('searchPrinters returns empty list from mock', () async {
    LpapiThermalPrinter lpapiThermalPrinterPlugin = LpapiThermalPrinter();
    MockLpapiThermalPrinterPlatform fakePlatform = MockLpapiThermalPrinterPlatform();
    LpapiThermalPrinterPlatform.instance = fakePlatform;

    expect(await lpapiThermalPrinterPlugin.searchPrinters(), isEmpty);
  });

  test('connectPrinter returns true from mock', () async {
    LpapiThermalPrinter lpapiThermalPrinterPlugin = LpapiThermalPrinter();
    MockLpapiThermalPrinterPlatform fakePlatform = MockLpapiThermalPrinterPlatform();
    LpapiThermalPrinterPlatform.instance = fakePlatform;

    expect(await lpapiThermalPrinterPlugin.connectPrinter('test'), true);
  });
}
