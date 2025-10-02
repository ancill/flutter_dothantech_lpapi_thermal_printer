import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lpapi_thermal_printer/lpapi_thermal_printer_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelLpapiThermalPrinter platform = MethodChannelLpapiThermalPrinter();
  const MethodChannel channel = MethodChannel('lpapi_thermal_printer');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
