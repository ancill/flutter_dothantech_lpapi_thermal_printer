#import "FlutterDothantechLpapiThermalPrinterPlugin.h"
#import "LPAPI.h"

@interface FlutterDothantechLpapiThermalPrinterPlugin ()
@property (nonatomic, strong) NSArray *scannedPrinters;
@property (nonatomic, strong) FlutterResult connectResult;
@property (nonatomic, strong) FlutterResult discoveryResult;
@property (nonatomic, strong) FlutterMethodChannel *channel;
@end

@implementation FlutterDothantechLpapiThermalPrinterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"lpapi_thermal_printer"
            binaryMessenger:[registrar messenger]];
  FlutterDothantechLpapiThermalPrinterPlugin* instance = [[FlutterDothantechLpapiThermalPrinterPlugin alloc] init];
  instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"searchPrinters" isEqualToString:call.method]) {
    [self searchPrinters:result];
  } else if ([@"discoverPrinters" isEqualToString:call.method]) {
    [self discoverPrinters:result];
  } else if ([@"connectPrinter" isEqualToString:call.method]) {
    NSString *address = call.arguments[@"address"];
    [self connectPrinter:address result:result];
  } else if ([@"connectFirstPrinter" isEqualToString:call.method]) {
    [self connectFirstPrinter:result];
  } else if ([@"disconnectPrinter" isEqualToString:call.method]) {
    [self disconnectPrinter:result];
  } else if ([@"getPrinterStatus" isEqualToString:call.method]) {
    [self getPrinterStatus:result];
  } else if ([@"printText" isEqualToString:call.method]) {
    NSString *text = call.arguments[@"text"];
    NSNumber *width = call.arguments[@"width"];
    NSNumber *height = call.arguments[@"height"];
    [self printText:text width:width height:height result:result];
  } else if ([@"print1DBarcode" isEqualToString:call.method]) {
    NSString *barcode = call.arguments[@"barcode"];
    NSString *text = call.arguments[@"text"];
    NSNumber *width = call.arguments[@"width"];
    NSNumber *height = call.arguments[@"height"];
    [self print1DBarcode:barcode text:text width:width height:height result:result];
  } else if ([@"print2DBarcode" isEqualToString:call.method]) {
    NSString *barcode = call.arguments[@"barcode"];
    NSNumber *width = call.arguments[@"width"];
    NSNumber *height = call.arguments[@"height"];
    [self print2DBarcode:barcode width:width height:height result:result];
  } else if ([@"printImage" isEqualToString:call.method]) {
    NSString *imageData = call.arguments[@"imageData"];
    [self printImage:imageData result:result];
  } else if ([@"setPrintDensity" isEqualToString:call.method]) {
    NSNumber *density = call.arguments[@"density"];
    [self setPrintDensity:density result:result];
  } else if ([@"setPrintSpeed" isEqualToString:call.method]) {
    NSNumber *speed = call.arguments[@"speed"];
    [self setPrintSpeed:speed result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)searchPrinters:(FlutterResult)result {
  NSLog(@"[iOS] searchPrinters called");

  // On iOS, searchPrinters and discoverPrinters use the same mechanism
  [self discoverPrinters:result];
}

- (void)discoverPrinters:(FlutterResult)result {
  NSLog(@"[iOS] discoverPrinters called");

  self.discoveryResult = result;

  [LPAPI scanPrinters:^(NSArray *scanedPrinterNames) {
    NSLog(@"[iOS] Found %lu printers", (unsigned long)scanedPrinterNames.count);

    NSMutableArray *printerList = [NSMutableArray array];
    for (NSString *printerName in scanedPrinterNames) {
      [printerList addObject:@{
        @"name": printerName,
        @"address": printerName, // iOS uses printer name as identifier
        @"type": @"DISCOVERED"
      }];
    }

    self.scannedPrinters = scanedPrinterNames;

    if (self.discoveryResult) {
      self.discoveryResult(printerList);
      self.discoveryResult = nil;
    }
  }];
}

- (void)connectPrinter:(NSString *)address result:(FlutterResult)result {
  NSLog(@"[iOS] connectPrinter called with address: %@", address);

  self.connectResult = result;

  // On iOS, the address is actually the printer name
  [LPAPI openPrinter:address completion:^(BOOL isSuccess) {
    NSLog(@"[iOS] Connection result: %d", isSuccess);

    if (self.connectResult) {
      self.connectResult(@(isSuccess));
      self.connectResult = nil;
    }

    if (isSuccess) {
      [self.channel invokeMethod:@"onPrinterConnected" arguments:nil];
    } else {
      [self.channel invokeMethod:@"onPrinterDisconnected" arguments:nil];
    }
  }];
}

- (void)connectFirstPrinter:(FlutterResult)result {
  NSLog(@"[iOS] connectFirstPrinter called");

  self.connectResult = result;

  // Connect to first available printer (empty string)
  [LPAPI openPrinter:@"" completion:^(BOOL isSuccess) {
    NSLog(@"[iOS] First printer connection result: %d", isSuccess);

    if (self.connectResult) {
      self.connectResult(@(isSuccess));
      self.connectResult = nil;
    }

    if (isSuccess) {
      [self.channel invokeMethod:@"onPrinterConnected" arguments:nil];
    } else {
      [self.channel invokeMethod:@"onPrinterDisconnected" arguments:nil];
    }
  }];
}

- (void)disconnectPrinter:(FlutterResult)result {
  NSLog(@"[iOS] disconnectPrinter called");

  [LPAPI closePrinter];
  [self.channel invokeMethod:@"onPrinterDisconnected" arguments:nil];
  result(@YES);
}

- (void)getPrinterStatus:(FlutterResult)result {
  // Check if printer is connected by trying to get printer info
  PrinterInfo *info = [LPAPI connectingPrinterDetailInfos];
  NSString *status = info ? @"connected" : @"disconnected";

  NSLog(@"[iOS] getPrinterStatus: %@", status);
  result(status);
}

- (void)printText:(NSString *)text width:(NSNumber *)width height:(NSNumber *)height result:(FlutterResult)result {
  NSLog(@"[iOS] printText called: %@", text);

  PrinterInfo *info = [LPAPI connectingPrinterDetailInfos];
  if (!info) {
    result([FlutterError errorWithCode:@"NOT_CONNECTED"
                               message:@"Printer is not connected"
                               details:nil]);
    return;
  }

  double w = width ? [width doubleValue] : 48.0;
  double h = height ? [height doubleValue] : 50.0;

  // Start drawing
  BOOL started = [LPAPI startDraw:w height:h orientation:0];
  if (!started) {
    result([FlutterError errorWithCode:@"DRAW_FAILED"
                               message:@"Failed to start drawing"
                               details:nil]);
    return;
  }

  // Draw text
  [LPAPI drawText:text x:4.0 y:5.0 width:(w - 8.0) height:(h - 10.0) fontHeight:4.0];

  // End drawing
  [LPAPI endDraw];

  // Print
  [LPAPI print:^(BOOL isSuccess) {
    NSLog(@"[iOS] Print text result: %d", isSuccess);

    if (isSuccess) {
      result(@YES);
      [self.channel invokeMethod:@"onPrintSuccess" arguments:nil];
    } else {
      result([FlutterError errorWithCode:@"PRINT_FAILED"
                                 message:@"Failed to print text"
                                 details:nil]);
      [self.channel invokeMethod:@"onPrintFailed" arguments:nil];
    }
  }];
}

- (void)print1DBarcode:(NSString *)barcode text:(NSString *)text width:(NSNumber *)width height:(NSNumber *)height result:(FlutterResult)result {
  NSLog(@"[iOS] print1DBarcode called: %@", barcode);

  PrinterInfo *info = [LPAPI connectingPrinterDetailInfos];
  if (!info) {
    result([FlutterError errorWithCode:@"NOT_CONNECTED"
                               message:@"Printer is not connected"
                               details:nil]);
    return;
  }

  double w = width ? [width doubleValue] : 48.0;
  double h = height ? [height doubleValue] : 50.0;

  // Start drawing
  BOOL started = [LPAPI startDraw:w height:h orientation:0];
  if (!started) {
    result([FlutterError errorWithCode:@"DRAW_FAILED"
                               message:@"Failed to start drawing"
                               details:nil]);
    return;
  }

  // Draw text if provided
  double barcodeY = 10.0;
  if (text && text.length > 0) {
    [LPAPI drawText:text x:4.0 y:4.0 width:(w - 8.0) height:20.0 fontHeight:4.0];
    barcodeY = 25.0;
  }

  // Draw barcode
  [LPAPI drawBarcode:barcode x:4.0 y:barcodeY width:(w - 8.0) height:15.0];

  // End drawing
  [LPAPI endDraw];

  // Print
  [LPAPI print:^(BOOL isSuccess) {
    NSLog(@"[iOS] Print barcode result: %d", isSuccess);

    if (isSuccess) {
      result(@YES);
      [self.channel invokeMethod:@"onPrintSuccess" arguments:nil];
    } else {
      result([FlutterError errorWithCode:@"PRINT_FAILED"
                                 message:@"Failed to print barcode"
                                 details:nil]);
      [self.channel invokeMethod:@"onPrintFailed" arguments:nil];
    }
  }];
}

- (void)print2DBarcode:(NSString *)barcode width:(NSNumber *)width height:(NSNumber *)height result:(FlutterResult)result {
  NSLog(@"[iOS] print2DBarcode called: %@", barcode);

  PrinterInfo *info = [LPAPI connectingPrinterDetailInfos];
  if (!info) {
    result([FlutterError errorWithCode:@"NOT_CONNECTED"
                               message:@"Printer is not connected"
                               details:nil]);
    return;
  }

  double w = width ? [width doubleValue] : 48.0;
  double h = height ? [height doubleValue] : 50.0;

  // Start drawing
  BOOL started = [LPAPI startDraw:w height:h orientation:0];
  if (!started) {
    result([FlutterError errorWithCode:@"DRAW_FAILED"
                               message:@"Failed to start drawing"
                               details:nil]);
    return;
  }

  // Draw QR code (centered)
  double size = MIN(w, h) - 10.0;
  double x = (w - size) / 2.0;
  double y = (h - size) / 2.0;
  [LPAPI drawQRCode:barcode x:x y:y width:size];

  // End drawing
  [LPAPI endDraw];

  // Print
  [LPAPI print:^(BOOL isSuccess) {
    NSLog(@"[iOS] Print QR code result: %d", isSuccess);

    if (isSuccess) {
      result(@YES);
      [self.channel invokeMethod:@"onPrintSuccess" arguments:nil];
    } else {
      result([FlutterError errorWithCode:@"PRINT_FAILED"
                                 message:@"Failed to print QR code"
                                 details:nil]);
      [self.channel invokeMethod:@"onPrintFailed" arguments:nil];
    }
  }];
}

- (void)printImage:(NSString *)imageData result:(FlutterResult)result {
  NSLog(@"[iOS] printImage called");

  PrinterInfo *info = [LPAPI connectingPrinterDetailInfos];
  if (!info) {
    result([FlutterError errorWithCode:@"NOT_CONNECTED"
                               message:@"Printer is not connected"
                               details:nil]);
    return;
  }

  // Decode base64 image
  NSData *data = [[NSData alloc] initWithBase64EncodedString:imageData options:0];
  UIImage *image = [UIImage imageWithData:data];

  if (!image) {
    result([FlutterError errorWithCode:@"INVALID_IMAGE"
                               message:@"Failed to decode image"
                               details:nil]);
    return;
  }

  // Print image directly
  [LPAPI printImage:image completion:^(BOOL isSuccess) {
    NSLog(@"[iOS] Print image result: %d", isSuccess);

    if (isSuccess) {
      result(@YES);
      [self.channel invokeMethod:@"onPrintSuccess" arguments:nil];
    } else {
      result([FlutterError errorWithCode:@"PRINT_FAILED"
                                 message:@"Failed to print image"
                                 details:nil]);
      [self.channel invokeMethod:@"onPrintFailed" arguments:nil];
    }
  }];
}

- (void)setPrintDensity:(NSNumber *)density result:(FlutterResult)result {
  NSLog(@"[iOS] setPrintDensity called: %@", density);

  PrinterInfo *info = [LPAPI connectingPrinterDetailInfos];
  if (!info) {
    result([FlutterError errorWithCode:@"NOT_CONNECTED"
                               message:@"Printer is not connected"
                               details:nil]);
    return;
  }

  // iOS LPAPI uses darkness (0-15), Flutter plugin uses 0-20
  // Map 0-20 to 0-15
  int darkness = (int)([density intValue] * 15 / 20);
  [LPAPI setPrintDarkness:darkness];

  result(@YES);
}

- (void)setPrintSpeed:(NSNumber *)speed result:(FlutterResult)result {
  NSLog(@"[iOS] setPrintSpeed called: %@", speed);

  PrinterInfo *info = [LPAPI connectingPrinterDetailInfos];
  if (!info) {
    result([FlutterError errorWithCode:@"NOT_CONNECTED"
                               message:@"Printer is not connected"
                               details:nil]);
    return;
  }

  [LPAPI setPrintSpeed:[speed intValue]];

  result(@YES);
}

@end
