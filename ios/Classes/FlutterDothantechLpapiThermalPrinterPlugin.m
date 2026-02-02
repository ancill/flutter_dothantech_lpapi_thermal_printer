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
  } else if ([@"printLotLabel" isEqualToString:call.method]) {
    NSString *lotId = call.arguments[@"lotId"];
    NSString *sku = call.arguments[@"sku"];
    NSString *expiryDate = call.arguments[@"expiryDate"];
    NSString *locationCode = call.arguments[@"locationCode"];
    NSString *zone = call.arguments[@"zone"];
    NSNumber *width = call.arguments[@"width"];
    NSNumber *height = call.arguments[@"height"];
    [self printLotLabel:lotId sku:sku expiryDate:expiryDate locationCode:locationCode zone:zone width:width height:height result:result];
  } else if ([@"printWeightedItemLabel" isEqualToString:call.method]) {
    NSString *productName = call.arguments[@"productName"];
    NSNumber *weightKg = call.arguments[@"weightKg"];
    NSNumber *totalPrice = call.arguments[@"totalPrice"];
    NSNumber *orderId = call.arguments[@"orderId"];
    NSString *currencySymbol = call.arguments[@"currencySymbol"];
    NSNumber *width = call.arguments[@"width"];
    NSNumber *height = call.arguments[@"height"];
    [self printWeightedItemLabel:productName weightKg:weightKg totalPrice:totalPrice orderId:orderId currencySymbol:currencySymbol width:width height:height result:result];
  } else if ([@"printBagLabel" isEqualToString:call.method]) {
    NSString *barcode = call.arguments[@"barcode"];
    NSString *orderInfo = call.arguments[@"orderInfo"];
    NSString *zone = call.arguments[@"zone"];
    NSNumber *bagNumber = call.arguments[@"bagNumber"];
    NSString *timestamp = call.arguments[@"timestamp"];
    NSNumber *width = call.arguments[@"width"];
    NSNumber *height = call.arguments[@"height"];
    [self printBagLabel:barcode orderInfo:orderInfo zone:zone bagNumber:bagNumber timestamp:timestamp width:width height:height result:result];
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

/**
 * Print an inventory lot label (portrait format)
 * Layout:
 *   Top half: QR code (~22x22mm) left-aligned
 *   Bottom half: LOT ID, SKU, other info stacked
 */
- (void)printLotLabel:(NSString *)lotId
                  sku:(NSString *)sku
           expiryDate:(NSString *)expiryDate
         locationCode:(NSString *)locationCode
                 zone:(NSString *)zone
                width:(NSNumber *)width
               height:(NSNumber *)height
               result:(FlutterResult)result {
  NSLog(@"[iOS] printLotLabel called: lotId=%@, sku=%@", lotId, sku);

  PrinterInfo *info = [LPAPI connectingPrinterDetailInfos];
  if (!info) {
    result([FlutterError errorWithCode:@"NOT_CONNECTED"
                               message:@"Printer is not connected"
                               details:nil]);
    return;
  }

  double w = width ? [width doubleValue] : 70.0;
  double h = height ? [height doubleValue] : 50.0;

  // Start drawing with 90° rotation for portrait mode
  BOOL started = [LPAPI startDraw:w height:h orientation:90];
  if (!started) {
    result([FlutterError errorWithCode:@"DRAW_FAILED"
                               message:@"Failed to start drawing"
                               details:nil]);
    return;
  }

  // Layout calculations (all in mm)
  double margin = 2.0;

  // QR code: ~22mm left-aligned
  double qrSize = 22.0;
  double qrX = margin;
  double qrY = margin;

  // Draw QR code containing LOT ID
  [LPAPI drawQRCode:lotId x:qrX y:qrY width:qrSize];

  // Text area below QR
  double textY = qrY + qrSize + 1.5;
  double textWidth = w - 2 * margin;
  double currentY = textY;

  // LOT ID - BIG font (6mm)
  NSString *shortLotId = lotId;
  if ([lotId hasPrefix:@"LOT:"]) {
    shortLotId = [lotId substringFromIndex:4];
  }
  NSString *lotDisplay = [NSString stringWithFormat:@"LOT %@", shortLotId];
  [LPAPI drawText:lotDisplay x:margin y:currentY width:textWidth height:8.0 fontHeight:6.0];
  currentY += 8.0;

  // SKU - BIG font (5mm)
  [LPAPI drawText:sku x:margin y:currentY width:textWidth height:6.0 fontHeight:5.0];
  currentY += 6.0;

  // Bottom info line: EXP, LOC, Zone
  NSMutableArray *infoItems = [NSMutableArray array];
  if (expiryDate && expiryDate.length >= 10) {
    // Shorten date format: 2025-01-05 -> 01-05
    NSString *shortDate = [expiryDate substringFromIndex:5];
    [infoItems addObject:shortDate];
  } else if (expiryDate && expiryDate.length > 0) {
    [infoItems addObject:expiryDate];
  }
  if (locationCode && locationCode.length > 0) {
    [infoItems addObject:locationCode];
  }
  if (zone && zone.length > 0) {
    NSString *zoneDisplay = zone;
    if ([[zone lowercaseString] isEqualToString:@"frozen"]) {
      zoneDisplay = @"FRZ";
    } else if ([[zone lowercaseString] isEqualToString:@"chill"]) {
      zoneDisplay = @"CHL";
    } else if ([[zone lowercaseString] isEqualToString:@"ambient"]) {
      zoneDisplay = @"AMB";
    } else {
      zoneDisplay = [[zone uppercaseString] substringToIndex:MIN(3, zone.length)];
    }
    [infoItems addObject:zoneDisplay];
  }

  if (infoItems.count > 0) {
    NSString *infoText = [infoItems componentsJoinedByString:@"  "];
    [LPAPI drawText:infoText x:margin y:currentY width:textWidth height:5.0 fontHeight:3.5];
  }

  // End drawing
  [LPAPI endDraw];

  // Print
  [LPAPI print:^(BOOL isSuccess) {
    NSLog(@"[iOS] Print lot label result: %d", isSuccess);

    if (isSuccess) {
      result(@YES);
      [self.channel invokeMethod:@"onPrintSuccess" arguments:nil];
    } else {
      result([FlutterError errorWithCode:@"PRINT_FAILED"
                                 message:@"Failed to print lot label"
                                 details:nil]);
      [self.channel invokeMethod:@"onPrintFailed" arguments:nil];
    }
  }];
}

/**
 * Print a weighted item label for pick/pack (50x30mm format)
 * Used for items sold by weight (apples, cheese, etc.)
 * Layout:
 *   Left: QR code (~24x24mm) containing PKG:{orderId}:{weight}
 *   Right (stacked): Product name, weight, price, order reference
 */
- (void)printWeightedItemLabel:(NSString *)productName
                      weightKg:(NSNumber *)weightKg
                    totalPrice:(NSNumber *)totalPrice
                       orderId:(NSNumber *)orderId
                currencySymbol:(NSString *)currencySymbol
                         width:(NSNumber *)width
                        height:(NSNumber *)height
                        result:(FlutterResult)result {
  NSLog(@"[iOS] printWeightedItemLabel called: product=%@, weight=%@", productName, weightKg);

  PrinterInfo *info = [LPAPI connectingPrinterDetailInfos];
  if (!info) {
    result([FlutterError errorWithCode:@"NOT_CONNECTED"
                               message:@"Printer is not connected"
                               details:nil]);
    return;
  }

  double w = width ? [width doubleValue] : 50.0;
  double h = height ? [height doubleValue] : 30.0;

  // Start drawing
  BOOL started = [LPAPI startDraw:w height:h orientation:0];
  if (!started) {
    result([FlutterError errorWithCode:@"DRAW_FAILED"
                               message:@"Failed to start drawing"
                               details:nil]);
    return;
  }

  // Layout calculations (all in mm)
  double qrSize = 24.0;
  double qrX = 2.0;
  double qrY = (h - qrSize) / 2;

  double textX = qrX + qrSize + 2.0;
  double lineHeight = 5.5;
  double currentY = 3.0;

  // QR code content: PKG:{orderId}:{weight}
  NSString *weightStr = [NSString stringWithFormat:@"%.3f", [weightKg doubleValue]];
  NSString *qrContent = [NSString stringWithFormat:@"PKG:%d:%@", [orderId intValue], weightStr];
  [LPAPI drawQRCode:qrContent x:qrX y:qrY width:qrSize];

  // Product name - largest text (5mm font)
  [LPAPI drawText:productName x:textX y:currentY width:20.0 height:(lineHeight + 1) fontHeight:5.0];
  currentY += lineHeight + 1.5;

  // Weight - prominent (5mm font)
  NSString *weightDisplay = [NSString stringWithFormat:@"%@ kg", weightStr];
  [LPAPI drawText:weightDisplay x:textX y:currentY width:20.0 height:lineHeight fontHeight:5.0];
  currentY += lineHeight + 0.5;

  // Price - prominent (5mm font)
  NSString *priceStr = [NSString stringWithFormat:@"%.2f", [totalPrice doubleValue]];
  NSString *currency = currencySymbol ?: @"$";
  NSString *priceDisplay = [NSString stringWithFormat:@"%@ %@", currency, priceStr];
  [LPAPI drawText:priceDisplay x:textX y:currentY width:20.0 height:lineHeight fontHeight:5.0];
  currentY += lineHeight + 0.5;

  // Order reference - smaller (3mm font)
  NSString *orderRef = [NSString stringWithFormat:@"Order #%d", [orderId intValue]];
  [LPAPI drawText:orderRef x:textX y:currentY width:20.0 height:lineHeight fontHeight:3.0];

  // End drawing
  [LPAPI endDraw];

  // Print
  [LPAPI print:^(BOOL isSuccess) {
    NSLog(@"[iOS] Print weighted item label result: %d", isSuccess);

    if (isSuccess) {
      result(@YES);
      [self.channel invokeMethod:@"onPrintSuccess" arguments:nil];
    } else {
      result([FlutterError errorWithCode:@"PRINT_FAILED"
                                 message:@"Failed to print weighted item label"
                                 details:nil]);
      [self.channel invokeMethod:@"onPrintFailed" arguments:nil];
    }
  }];
}

/**
 * Print a bag label for packing workflow (50x50mm format)
 * Layout:
 *   - Zone header (bordered rectangle with text)
 *   - Order info (e.g., "Order #4")
 *   - Bag number (e.g., "Bag #2")
 *   - 1D Barcode (centered)
 *   - Barcode text
 *   - Timestamp
 */
- (void)printBagLabel:(NSString *)barcode
            orderInfo:(NSString *)orderInfo
                 zone:(NSString *)zone
            bagNumber:(NSNumber *)bagNumber
            timestamp:(NSString *)timestamp
                width:(NSNumber *)width
               height:(NSNumber *)height
               result:(FlutterResult)result {
  NSLog(@"[iOS] printBagLabel called: barcode=%@, zone=%@, bag=%@", barcode, zone, bagNumber);

  PrinterInfo *info = [LPAPI connectingPrinterDetailInfos];
  if (!info) {
    result([FlutterError errorWithCode:@"NOT_CONNECTED"
                               message:@"Printer is not connected"
                               details:nil]);
    return;
  }

  double w = width ? [width doubleValue] : 50.0;
  double h = height ? [height doubleValue] : 50.0;

  // Start drawing
  BOOL started = [LPAPI startDraw:w height:h orientation:0];
  if (!started) {
    result([FlutterError errorWithCode:@"DRAW_FAILED"
                               message:@"Failed to start drawing"
                               details:nil]);
    return;
  }

  // Layout calculations (all in mm)
  double margin = 3.0;
  double contentWidth = w - 2 * margin;
  double currentY = margin;

  // === Zone Header (with border) ===
  double headerHeight = 8.0;
  NSString *headerText = [zone uppercaseString];

  // Draw rectangle border for header
  [LPAPI drawRectangleWithX:margin y:currentY width:contentWidth height:headerHeight lineWidth:0.5 isFilled:NO];

  // Draw header text (centered)
  [LPAPI drawText:headerText x:(margin + 2.0) y:(currentY + 1.5) width:(contentWidth - 4.0) height:(headerHeight - 2.0) fontHeight:5.0];
  currentY += headerHeight + 3.0;

  // === Order Info ===
  [LPAPI drawText:orderInfo x:margin y:currentY width:contentWidth height:6.0 fontHeight:5.0];
  currentY += 7.0;

  // === Bag Number ===
  NSString *bagText = [NSString stringWithFormat:@"Bag #%d", [bagNumber intValue]];
  [LPAPI drawText:bagText x:margin y:currentY width:contentWidth height:5.0 fontHeight:4.0];
  currentY += 6.0;

  // === 1D Barcode (centered) ===
  double barcodeHeight = 12.0;
  [LPAPI drawBarcode:barcode x:margin y:currentY width:contentWidth height:barcodeHeight];
  currentY += barcodeHeight + 2.0;

  // === Barcode Text ===
  [LPAPI drawText:barcode x:margin y:currentY width:contentWidth height:4.0 fontHeight:3.0];
  currentY += 5.0;

  // === Timestamp ===
  [LPAPI drawText:timestamp x:margin y:currentY width:contentWidth height:4.0 fontHeight:2.5];

  // End drawing
  [LPAPI endDraw];

  // Print
  [LPAPI print:^(BOOL isSuccess) {
    NSLog(@"[iOS] Print bag label result: %d", isSuccess);

    if (isSuccess) {
      result(@YES);
      [self.channel invokeMethod:@"onPrintSuccess" arguments:nil];
    } else {
      result([FlutterError errorWithCode:@"PRINT_FAILED"
                                 message:@"Failed to print bag label"
                                 details:nil]);
      [self.channel invokeMethod:@"onPrintFailed" arguments:nil];
    }
  }];
}

@end
