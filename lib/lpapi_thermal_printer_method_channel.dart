import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'lpapi_thermal_printer_platform_interface.dart';

/// An implementation of [LpapiThermalPrinterPlatform] that uses method channels.
class MethodChannelLpapiThermalPrinter extends LpapiThermalPrinterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('lpapi_thermal_printer');

  MethodChannelLpapiThermalPrinter() {
    // Set up method call handler for events from native side
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onPrinterConnected':
        // Handle printer connected event
        break;
      case 'onPrinterDisconnected':
        // Handle printer disconnected event
        break;
      case 'onPrintSuccess':
        // Handle print success event
        break;
      case 'onPrintFailed':
        // Handle print failed event
        break;
      default:
        throw MissingPluginException('Method ${call.method} not implemented');
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<Map<String, dynamic>>> searchPrinters() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('searchPrinters');
    return result?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
  }

  @override
  Future<List<Map<String, dynamic>>> discoverPrinters() async {
    final result = await methodChannel.invokeMethod<List<dynamic>>('discoverPrinters');
    return result?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
  }

  @override
  Future<bool> connectPrinter(String address) async {
    final result = await methodChannel.invokeMethod<bool>('connectPrinter', {
      'address': address,
    });
    return result ?? false;
  }

  @override
  Future<bool> connectFirstPrinter() async {
    final result = await methodChannel.invokeMethod<bool>('connectFirstPrinter');
    return result ?? false;
  }

  @override
  Future<bool> disconnectPrinter() async {
    final result = await methodChannel.invokeMethod<bool>('disconnectPrinter');
    return result ?? false;
  }

  @override
  Future<String> getPrinterStatus() async {
    final result = await methodChannel.invokeMethod<String>('getPrinterStatus');
    return result ?? 'disconnected';
  }

  @override
  Future<bool> printText(String text, {int width = 48, int height = 50}) async {
    final result = await methodChannel.invokeMethod<bool>('printText', {
      'text': text,
      'width': width,
      'height': height,
    });
    return result ?? false;
  }

  @override
  Future<bool> print1DBarcode(String barcode, {String text = '', int width = 48, int height = 50}) async {
    final result = await methodChannel.invokeMethod<bool>('print1DBarcode', {
      'barcode': barcode,
      'text': text,
      'width': width,
      'height': height,
    });
    return result ?? false;
  }

  @override
  Future<bool> print2DBarcode(String barcode, {int width = 48, int height = 50}) async {
    final result = await methodChannel.invokeMethod<bool>('print2DBarcode', {
      'barcode': barcode,
      'width': width,
      'height': height,
    });
    return result ?? false;
  }

  @override
  Future<bool> printImage(String base64Image) async {
    final result = await methodChannel.invokeMethod<bool>('printImage', {
      'imageData': base64Image,
    });
    return result ?? false;
  }

  @override
  Future<bool> setPrintDensity(int density) async {
    final result = await methodChannel.invokeMethod<bool>('setPrintDensity', {
      'density': density,
    });
    return result ?? false;
  }

  @override
  Future<bool> setPrintSpeed(int speed) async {
    final result = await methodChannel.invokeMethod<bool>('setPrintSpeed', {
      'speed': speed,
    });
    return result ?? false;
  }
}
