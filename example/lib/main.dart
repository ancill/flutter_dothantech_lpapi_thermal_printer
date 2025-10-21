import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_dothantech_lpapi_thermal_printer/flutter_dothantech_lpapi_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LPAPI Thermal Printer Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const PrinterDemoPage(),
    );
  }
}

class PrinterDemoPage extends StatefulWidget {
  const PrinterDemoPage({super.key});

  @override
  State<PrinterDemoPage> createState() => _PrinterDemoPageState();
}

class _PrinterDemoPageState extends State<PrinterDemoPage> {
  final _printer = LpapiThermalPrinter();
  List<PrinterInfo> _printers = [];
  String _connectionStatus = 'Disconnected';
  String? _connectedPrinterAddress;
  bool _isSearching = false;
  String _platformInfo = '';

  // Text controllers
  final _textController = TextEditingController(
    text: 'Hello from LPAPI Thermal Printer!',
  );
  final _barcodeTextController = TextEditingController(text: 'Product Label');
  final _barcodeDataController = TextEditingController(text: '1234567890');
  final _qrcodeController = TextEditingController(text: 'https://example.com');

  // Print settings
  int _printDensity = 6; // Default normal density
  int _printSpeed = 3; // Default normal speed

  @override
  void initState() {
    super.initState();
    _checkPrinterStatus();
    _getPlatformInfo();
  }

  Future<void> _getPlatformInfo() async {
    try {
      final version = await _printer.getPlatformVersion();
      final platform = Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Unknown';
      setState(() {
        _platformInfo = 'Running on $platform (Driver: $version)';
      });
    } catch (e) {
      setState(() {
        _platformInfo = 'Platform info unavailable';
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _barcodeTextController.dispose();
    _barcodeDataController.dispose();
    _qrcodeController.dispose();
    super.dispose();
  }

  Future<void> _checkPrinterStatus() async {
    try {
      final status = await _printer.getPrinterStatus();
      setState(() {
        _connectionStatus = status;
      });
    } catch (e) {
      _showError('Failed to check printer status: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Request multiple permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      // Check if all permissions are granted
      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (!allGranted) {
        _showError('Please grant all permissions to use the printer');
        return;
      }
    }
  }

  Future<void> _searchPrinters() async {
    // Request permissions first
    await _requestPermissions();

    setState(() {
      _isSearching = true;
      _printers = [];
    });

    try {
      final printers = await _printer.searchPrinters();
      setState(() {
        _printers = printers;
        _isSearching = false;
      });

      if (printers.isEmpty) {
        _showMessage(
          'No paired printers found. Try "Discover All" to find nearby printers.',
        );
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showError('Failed to search printers: $e');
    }
  }

  Future<void> _discoverPrinters() async {
    // Request permissions first
    await _requestPermissions();

    setState(() {
      _isSearching = true;
      _printers = [];
    });

    _showMessage('Discovering printers... This may take up to 12 seconds.');

    try {
      final printers = await _printer.discoverPrinters();
      setState(() {
        _printers = printers;
        _isSearching = false;
      });

      if (printers.isEmpty) {
        _showMessage(
          'No printers found. Make sure Bluetooth is enabled and printers are turned on.',
        );
      } else {
        _showMessage('Found ${printers.length} printer(s)');
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      _showError('Failed to discover printers: $e');
    }
  }

  Future<void> _connectPrinter(String address) async {
    try {
      _showMessage('Connecting to printer...');
      final success = await _printer.connectPrinter(address);

      if (success) {
        setState(() {
          _connectedPrinterAddress = address;
          _connectionStatus = 'Connected';
        });
        _showMessage('Printer connected successfully!');
      } else {
        _showError('Failed to connect to printer');
      }
    } catch (e) {
      _showError('Connection error: $e');
    }

    await _checkPrinterStatus();
  }

  Future<void> _connectFirstPrinter() async {
    // Request permissions first
    await _requestPermissions();

    try {
      _showMessage('Connecting to first available printer...');
      final success = await _printer.connectFirstPrinter();

      if (success) {
        setState(() {
          _connectedPrinterAddress = 'First Printer';
          _connectionStatus = 'Connected';
        });
        _showMessage('Printer connected successfully!');
      } else {
        _showError(
          'Failed to connect to printer. Make sure a printer is paired in Bluetooth settings.',
        );
      }
    } catch (e) {
      _showError('Connection error: $e');
    }

    await _checkPrinterStatus();
  }

  Future<void> _disconnectPrinter() async {
    try {
      final success = await _printer.disconnectPrinter();
      if (success) {
        setState(() {
          _connectedPrinterAddress = null;
          _connectionStatus = 'Disconnected';
        });
        _showMessage('Printer disconnected');
      }
    } catch (e) {
      _showError('Failed to disconnect: $e');
    }
  }

  Future<void> _printText() async {
    if (_connectionStatus != 'connected') {
      _showError('Please connect to a printer first');
      return;
    }

    try {
      final success = await _printer.printText(_textController.text);
      if (success) {
        _showMessage('Text printed successfully!');
      } else {
        _showError('Failed to print text');
      }
    } catch (e) {
      _showError('Print error: $e');
    }
  }

  Future<void> _print1DBarcode() async {
    if (_connectionStatus != 'connected') {
      _showError('Please connect to a printer first');
      return;
    }

    try {
      final success = await _printer.print1DBarcode(
        _barcodeDataController.text,
        text: _barcodeTextController.text,
      );
      if (success) {
        _showMessage('Barcode printed successfully!');
      } else {
        _showError('Failed to print barcode');
      }
    } catch (e) {
      _showError('Print error: $e');
    }
  }

  Future<void> _print2DBarcode() async {
    if (_connectionStatus != 'connected') {
      _showError('Please connect to a printer first');
      return;
    }

    try {
      final success = await _printer.print2DBarcode(_qrcodeController.text);
      if (success) {
        _showMessage('QR Code printed successfully!');
      } else {
        _showError('Failed to print QR code');
      }
    } catch (e) {
      _showError('Print error: $e');
    }
  }

  Future<void> _setPrintDensity(int density) async {
    if (_connectionStatus != 'connected') {
      _showError('Please connect to a printer first');
      return;
    }

    try {
      final success = await _printer.setPrintDensity(density);
      if (success) {
        setState(() {
          _printDensity = density;
        });
        _showMessage('Print density set to $density');
      }
    } catch (e) {
      _showError('Failed to set density: $e');
    }
  }

  Future<void> _setPrintSpeed(int speed) async {
    if (_connectionStatus != 'connected') {
      _showError('Please connect to a printer first');
      return;
    }

    try {
      final success = await _printer.setPrintSpeed(speed);
      if (success) {
        setState(() {
          _printSpeed = speed;
        });
        _showMessage('Print speed set to $speed');
      }
    } catch (e) {
      _showError('Failed to set speed: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LPAPI Thermal Printer Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform Info Card
            if (_platformInfo.isNotEmpty)
              Card(
                color: Platform.isIOS ? Colors.blue.shade50 : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(
                        Platform.isIOS ? Icons.apple : Icons.android,
                        color: Platform.isIOS ? Colors.blue : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _platformInfo,
                          style: TextStyle(
                            color: Platform.isIOS ? Colors.blue.shade900 : Colors.green.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_platformInfo.isNotEmpty) const SizedBox(height: 16),

            // Connection Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Printer Connection',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _connectionStatus == 'connected'
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _connectionStatus == 'connected'
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text('Status: $_connectionStatus'),
                      ],
                    ),
                    if (_connectedPrinterAddress != null) ...[
                      const SizedBox(height: 4),
                      Text('Address: $_connectedPrinterAddress'),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isSearching ? null : _discoverPrinters,
                          icon: _isSearching
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.bluetooth_searching),
                          label: const Text('Discover All'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _isSearching ? null : _searchPrinters,
                          icon: const Icon(Icons.search),
                          label: const Text('Paired Only'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _connectionStatus == 'disconnected'
                              ? _connectFirstPrinter
                              : null,
                          icon: const Icon(Icons.print),
                          label: const Text('Quick Connect'),
                        ),
                        const SizedBox(width: 8),
                        if (_connectedPrinterAddress != null)
                          ElevatedButton.icon(
                            onPressed: _disconnectPrinter,
                            icon: const Icon(Icons.bluetooth_disabled),
                            label: const Text('Disconnect'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Printers List
            if (_printers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Printers',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      ..._printers.map(
                        (printer) => ListTile(
                          leading: const Icon(Icons.print),
                          title: Text(printer.name),
                          subtitle: Text(
                            '${printer.address} (${printer.type})',
                          ),
                          trailing: printer.address == _connectedPrinterAddress
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: printer.address == _connectedPrinterAddress
                              ? null
                              : () => _connectPrinter(printer.address),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Print Settings
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Print Settings',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text('Print Density: $_printDensity'),
                    Slider(
                      value: _printDensity.toDouble(),
                      min: 0,
                      max: 20,
                      divisions: 20,
                      label: _printDensity.toString(),
                      onChanged: (value) => _setPrintDensity(value.toInt()),
                    ),
                    const SizedBox(height: 8),
                    Text('Print Speed: $_printSpeed'),
                    Slider(
                      value: _printSpeed.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _printSpeed.toString(),
                      onChanged: (value) => _setPrintSpeed(value.toInt()),
                    ),
                  ],
                ),
              ),
            ),

            // Print Actions
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Print Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Text printing
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Text to Print',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _connectionStatus == 'connected'
                          ? _printText
                          : null,
                      icon: const Icon(Icons.text_fields),
                      label: const Text('Print Text'),
                    ),

                    const Divider(height: 32),

                    // 1D Barcode
                    TextField(
                      controller: _barcodeTextController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode Label Text',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _barcodeDataController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode Data',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _connectionStatus == 'connected'
                          ? _print1DBarcode
                          : null,
                      icon: const Icon(Icons.barcode_reader),
                      label: const Text('Print 1D Barcode'),
                    ),

                    const Divider(height: 32),

                    // QR Code
                    TextField(
                      controller: _qrcodeController,
                      decoration: const InputDecoration(
                        labelText: 'QR Code Data',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _connectionStatus == 'connected'
                          ? _print2DBarcode
                          : null,
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Print QR Code'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
