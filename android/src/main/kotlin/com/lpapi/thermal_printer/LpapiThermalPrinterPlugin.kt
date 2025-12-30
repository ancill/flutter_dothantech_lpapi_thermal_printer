package com.lpapi.thermal_printer

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Base64
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.dothantech.lpapi.LPAPI
import com.dothantech.lpapi.LPAPI.BarcodeType
import com.dothantech.printer.IDzPrinter
import com.dothantech.printer.IDzPrinter.*
import java.io.ByteArrayOutputStream

class LpapiThermalPrinterPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private lateinit var api: LPAPI
  private val handler = Handler(Looper.getMainLooper())
  private var printerConnectedResult: Result? = null
  private var discoveryResult: Result? = null
  private val discoveredDevices = mutableListOf<BluetoothDevice>()

  // Bluetooth discovery receiver
  private val discoveryReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      when (intent.action) {
        BluetoothDevice.ACTION_FOUND -> {
          val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
          if (device != null && !device.name.isNullOrEmpty()) {
            android.util.Log.d("LpapiThermalPrinter", "Found device: ${device.name} - ${device.address}")

            // Check if this is a printer device (you may want to filter by name pattern)
            if (api.isDeviceSupported(device, null)) {
              android.util.Log.d("LpapiThermalPrinter", "✅ Device is a supported printer")
              if (!discoveredDevices.any { it.address == device.address }) {
                discoveredDevices.add(device)
              }
            }
          }
        }
        BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
          android.util.Log.d("LpapiThermalPrinter", "Discovery finished. Found ${discoveredDevices.size} printers")
          sendDiscoveryResults()
        }
      }
    }
  }

  private fun sendDiscoveryResults() {
    if (discoveryResult != null) {
      val printerList = discoveredDevices.map { device ->
        mapOf(
          "name" to (device.name ?: "Unknown"),
          "address" to device.address,
          "type" to "DISCOVERED"
        )
      }
      discoveryResult?.success(printerList)
      discoveryResult = null
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "lpapi_thermal_printer")
    channel.setMethodCallHandler(this)

    // Verify LPAPI JAR is loaded
    try {
      // Test if we can access LPAPI class
      val lpapiClass = Class.forName("com.dothantech.lpapi.LPAPI")
      android.util.Log.d("LpapiThermalPrinter", "✅ LPAPI class found: $lpapiClass")

      // Test if we can access Factory
      val factoryClass = Class.forName("com.dothantech.lpapi.LPAPI\$Factory")
      android.util.Log.d("LpapiThermalPrinter", "✅ LPAPI.Factory class found: $factoryClass")

      // Test if we can access printer classes
      val printerStateClass = Class.forName("com.dothantech.printer.IDzPrinter\$PrinterState")
      android.util.Log.d("LpapiThermalPrinter", "✅ PrinterState class found: $printerStateClass")

      // Initialize LPAPI
      api = LPAPI.Factory.createInstance(callback)
      android.util.Log.d("LpapiThermalPrinter", "✅ LPAPI instance created successfully: $api")

      // Test some basic methods
      val apiClassName = api.javaClass.name
      android.util.Log.d("LpapiThermalPrinter", "✅ LPAPI implementation class: $apiClassName")

      // Check if we can call methods
      val state = api.getPrinterState()
      android.util.Log.d("LpapiThermalPrinter", "✅ Initial printer state: $state")

    } catch (e: ClassNotFoundException) {
      android.util.Log.e("LpapiThermalPrinter", "❌ LPAPI JAR not loaded properly: ${e.message}")
      android.util.Log.e("LpapiThermalPrinter", "Stack trace:", e)
    } catch (e: Exception) {
      android.util.Log.e("LpapiThermalPrinter", "❌ Error initializing LPAPI: ${e.message}")
      android.util.Log.e("LpapiThermalPrinter", "Stack trace:", e)
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }

      "searchPrinters" -> {
        searchPrinters(result)
      }

      "discoverPrinters" -> {
        discoverPrinters(result)
      }

      "connectPrinter" -> {
        val address = call.argument<String>("address")
        connectPrinter(address, result)
      }

      "connectFirstPrinter" -> {
        connectFirstPrinter(result)
      }

      "disconnectPrinter" -> {
        disconnectPrinter(result)
      }

      "getPrinterStatus" -> {
        getPrinterStatus(result)
      }

      "printText" -> {
        val text = call.argument<String>("text") ?: ""
        val width = call.argument<Int>("width") ?: 48
        val height = call.argument<Int>("height") ?: 50
        printText(text, width, height, result)
      }

      "print1DBarcode" -> {
        val barcode = call.argument<String>("barcode") ?: ""
        val text = call.argument<String>("text") ?: ""
        val width = call.argument<Int>("width") ?: 48
        val height = call.argument<Int>("height") ?: 50
        print1DBarcode(text, barcode, width, height, result)
      }

      "print2DBarcode" -> {
        val barcode = call.argument<String>("barcode") ?: ""
        val width = call.argument<Int>("width") ?: 48
        val height = call.argument<Int>("height") ?: 50
        print2DBarcode(barcode, width, height, result)
      }

      "printLotLabel" -> {
        val lotId = call.argument<String>("lotId") ?: ""
        val sku = call.argument<String>("sku") ?: ""
        val expiryDate = call.argument<String>("expiryDate")
        val locationCode = call.argument<String>("locationCode")
        val width = call.argument<Int>("width") ?: 50
        val height = call.argument<Int>("height") ?: 30
        printLotLabel(lotId, sku, expiryDate, locationCode, width, height, result)
      }

      "printWeightedItemLabel" -> {
        val productName = call.argument<String>("productName") ?: ""
        val weightKg = call.argument<Double>("weightKg") ?: 0.0
        val totalPrice = call.argument<Double>("totalPrice") ?: 0.0
        val orderId = call.argument<Int>("orderId") ?: 0
        val currencySymbol = call.argument<String>("currencySymbol") ?: "₽"
        val width = call.argument<Int>("width") ?: 50
        val height = call.argument<Int>("height") ?: 30
        printWeightedItemLabel(productName, weightKg, totalPrice, orderId, currencySymbol, width, height, result)
      }

      "printImage" -> {
        val imageData = call.argument<String>("imageData")
        if (imageData != null) {
          printImage(imageData, result)
        } else {
          result.error("INVALID_ARGUMENT", "Image data is required", null)
        }
      }

      "setPrintDensity" -> {
        val density = call.argument<Int>("density") ?: 6
        setPrintDensity(density, result)
      }

      "setPrintSpeed" -> {
        val speed = call.argument<Int>("speed") ?: 3
        setPrintSpeed(speed, result)
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  private fun searchPrinters(result: Result) {
    android.util.Log.d("LpapiThermalPrinter", "searchPrinters() called")

    val btAdapter = BluetoothAdapter.getDefaultAdapter()
    if (btAdapter == null) {
      android.util.Log.e("LpapiThermalPrinter", "❌ No Bluetooth adapter found")
      result.error("NO_BLUETOOTH", "Device doesn't support Bluetooth", null)
      return
    }

    if (!btAdapter.isEnabled) {
      android.util.Log.e("LpapiThermalPrinter", "❌ Bluetooth is disabled")
      result.error("BLUETOOTH_DISABLED", "Bluetooth is disabled", null)
      return
    }

    android.util.Log.d("LpapiThermalPrinter", "Calling api.getAllPrinterAddresses(null)...")
    val printers = api.getAllPrinterAddresses(null)
    android.util.Log.d("LpapiThermalPrinter", "✅ Found ${printers.size} paired printers")

    // Get paired devices too
    val pairedDevices = btAdapter.bondedDevices
    val allPrinters = mutableListOf<Map<String, String>>()

    // Add LPAPI recognized printers
    printers.forEach { printer ->
      android.util.Log.d("LpapiThermalPrinter", "Paired printer: ${printer.shownName} - ${printer.macAddress} - ${printer.addressType}")
      allPrinters.add(mapOf(
        "name" to (printer.shownName ?: printer.macAddress),
        "address" to printer.macAddress,
        "type" to "PAIRED"
      ))
    }

    // Check other paired devices that might be printers
    pairedDevices.forEach { device ->
      // Skip if already in LPAPI list
      if (!printers.any { it.macAddress == device.address }) {
        // Check if it's a supported printer
        if (api.isDeviceSupported(device, null)) {
          android.util.Log.d("LpapiThermalPrinter", "Additional printer: ${device.name} - ${device.address}")
          allPrinters.add(mapOf(
            "name" to (device.name ?: device.address),
            "address" to device.address,
            "type" to "PAIRED"
          ))
        }
      }
    }

    android.util.Log.d("LpapiThermalPrinter", "✅ Returning ${allPrinters.size} printers (paired)")
    result.success(allPrinters)
  }

  private fun discoverPrinters(result: Result) {
    android.util.Log.d("LpapiThermalPrinter", "discoverPrinters() called - starting Bluetooth discovery")

    val btAdapter = BluetoothAdapter.getDefaultAdapter()
    if (btAdapter == null) {
      android.util.Log.e("LpapiThermalPrinter", "❌ No Bluetooth adapter found")
      result.error("NO_BLUETOOTH", "Device doesn't support Bluetooth", null)
      return
    }

    if (!btAdapter.isEnabled) {
      android.util.Log.e("LpapiThermalPrinter", "❌ Bluetooth is disabled")
      result.error("BLUETOOTH_DISABLED", "Bluetooth is disabled", null)
      return
    }

    // Clear previous discovered devices
    discoveredDevices.clear()
    discoveryResult = result

    // Register receiver for discovery
    val filter = IntentFilter().apply {
      addAction(BluetoothDevice.ACTION_FOUND)
      addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
    }
    context.registerReceiver(discoveryReceiver, filter)

    // Cancel any ongoing discovery
    if (btAdapter.isDiscovering) {
      btAdapter.cancelDiscovery()
    }

    // Start discovery
    if (btAdapter.startDiscovery()) {
      android.util.Log.d("LpapiThermalPrinter", "✅ Bluetooth discovery started")

      // Add already paired printers to the list
      val pairedDevices = btAdapter.bondedDevices
      pairedDevices.forEach { device ->
        if (api.isDeviceSupported(device, null)) {
          discoveredDevices.add(device)
          android.util.Log.d("LpapiThermalPrinter", "Added paired printer: ${device.name} - ${device.address}")
        }
      }

      // Set timeout for discovery (12 seconds is typical)
      handler.postDelayed({
        if (discoveryResult != null) {
          btAdapter.cancelDiscovery()
          sendDiscoveryResults()
        }
      }, 12000)
    } else {
      android.util.Log.e("LpapiThermalPrinter", "❌ Failed to start Bluetooth discovery")
      result.error("DISCOVERY_FAILED", "Failed to start Bluetooth discovery", null)
      discoveryResult = null
    }
  }

  private fun connectPrinter(address: String?, result: Result) {
    android.util.Log.d("LpapiThermalPrinter", "connectPrinter() called with address: $address")
    printerConnectedResult = result

    if (address == null || address.isEmpty()) {
      // Connect to first available printer
      android.util.Log.d("LpapiThermalPrinter", "Attempting to connect to first available printer using api.openPrinter(\"\")")
      if (api.openPrinter("")) {
        android.util.Log.d("LpapiThermalPrinter", "✅ Connection request submitted successfully")
        // Connection request submitted successfully, wait for callback
        return
      }
      android.util.Log.e("LpapiThermalPrinter", "❌ api.openPrinter(\"\") returned false")
    } else {
      // Try direct connection using BluetoothDevice
      val btAdapter = BluetoothAdapter.getDefaultAdapter()
      val device = btAdapter.getRemoteDevice(address)

      if (device != null) {
        android.util.Log.d("LpapiThermalPrinter", "Got Bluetooth device: ${device.name} at ${device.address}")

        // Try to connect directly using LPAPI with BluetoothDevice
        if (api.openPrinter(device)) {
          android.util.Log.d("LpapiThermalPrinter", "✅ Direct connection request to $address submitted successfully")
          return
        } else {
          android.util.Log.w("LpapiThermalPrinter", "Direct connection failed, trying PrinterAddress method...")
        }
      }

      // Fallback: Connect to specific printer by address using PrinterAddress
      android.util.Log.d("LpapiThermalPrinter", "Trying PrinterAddress method for: $address")
      val printers = api.getAllPrinterAddresses(null)
      val printer = printers.find { it.macAddress == address }

      if (printer != null) {
        android.util.Log.d("LpapiThermalPrinter", "Found printer in paired list: ${printer.shownName} at ${printer.macAddress}")
        if (api.openPrinterByAddress(printer)) {
          android.util.Log.d("LpapiThermalPrinter", "✅ Connection request to $address submitted successfully")
          // Connection request submitted successfully, wait for callback
          return
        }
        android.util.Log.e("LpapiThermalPrinter", "❌ api.openPrinterByAddress() returned false")
      } else {
        android.util.Log.w("LpapiThermalPrinter", "Printer not in paired list, but may still be able to connect")
      }
    }

    android.util.Log.e("LpapiThermalPrinter", "❌ Failed to connect to printer")
    result.error("CONNECTION_FAILED", "Failed to connect to printer", null)
    printerConnectedResult = null
  }

  private fun connectFirstPrinter(result: Result) {
    printerConnectedResult = result

    // Connect to first available printer using empty string
    if (api.openPrinter("")) {
      // Connection request submitted successfully, wait for callback
      return
    }

    result.error("CONNECTION_FAILED", "Failed to connect to first printer", null)
    printerConnectedResult = null
  }

  private fun disconnectPrinter(result: Result) {
    api.closePrinter()
    result.success(true)
  }

  private fun getPrinterStatus(result: Result) {
    val state = api.getPrinterState()
    val status = when (state) {
      PrinterState.Connected, PrinterState.Connected2 -> "connected"
      PrinterState.Connecting -> "connecting"
      PrinterState.Disconnected, null -> "disconnected"
      else -> "unknown"
    }
    result.success(status)
  }

  private fun printText(text: String, width: Int, height: Int, result: Result) {
    val state = api.getPrinterState()
    if (state != PrinterState.Connected && state != PrinterState.Connected2) {
      result.error("NOT_CONNECTED", "Printer is not connected", null)
      return
    }

    // Start drawing task
    api.startJob(width.toDouble(), height.toDouble(), 0)

    // Draw text
    api.drawText(text, 4.0, 5.0, (width - 8).toDouble(), (height - 10).toDouble(), 4.0)

    // Commit job
    if (api.commitJob()) {
      result.success(true)
    } else {
      result.error("PRINT_FAILED", "Failed to print text", null)
    }
  }

  private fun print1DBarcode(text: String, barcode: String, width: Int, height: Int, result: Result) {
    val state = api.getPrinterState()
    if (state != PrinterState.Connected && state != PrinterState.Connected2) {
      result.error("NOT_CONNECTED", "Printer is not connected", null)
      return
    }

    // Start drawing task
    api.startJob(width.toDouble(), height.toDouble(), 0)

    // Draw text if provided
    if (text.isNotEmpty()) {
      api.drawText(text, 4.0, 4.0, (width - 8).toDouble(), 20.0, 4.0)
    }

    // Draw barcode
    val barcodeY = if (text.isNotEmpty()) 25.0 else 10.0
    api.draw1DBarcode(barcode, BarcodeType.AUTO, 4.0, barcodeY, (width - 8).toDouble(), 15.0, 3.0)

    // Commit job
    if (api.commitJob()) {
      result.success(true)
    } else {
      result.error("PRINT_FAILED", "Failed to print barcode", null)
    }
  }

  private fun print2DBarcode(barcode: String, width: Int, height: Int, result: Result) {
    val state = api.getPrinterState()
    if (state != PrinterState.Connected && state != PrinterState.Connected2) {
      result.error("NOT_CONNECTED", "Printer is not connected", null)
      return
    }

    // Start drawing task
    api.startJob(width.toDouble(), height.toDouble(), 0)

    // Draw QR code
    val size = Math.min(width, height) - 10
    val x = (width - size) / 2
    val y = (height - size) / 2
    api.draw2DQRCode(barcode, x.toDouble(), y.toDouble(), size.toDouble())

    // Commit job
    if (api.commitJob()) {
      result.success(true)
    } else {
      result.error("PRINT_FAILED", "Failed to print QR code", null)
    }
  }

  /**
   * Print an inventory lot label (50x30mm format)
   * Layout:
   *   Left: QR code (~24x24mm) containing lotId
   *   Right (stacked): SKU (largest), EXP, LOC (optional), LOT (small)
   */
  private fun printLotLabel(
    lotId: String,
    sku: String,
    expiryDate: String?,
    locationCode: String?,
    width: Int,
    height: Int,
    result: Result
  ) {
    val state = api.getPrinterState()
    if (state != PrinterState.Connected && state != PrinterState.Connected2) {
      result.error("NOT_CONNECTED", "Printer is not connected", null)
      return
    }

    // Start drawing task (50mm x 30mm label)
    api.startJob(width.toDouble(), height.toDouble(), 0)

    // Layout calculations (all in mm)
    // QR code on left side: ~24mm, positioned with 2mm margin
    val qrSize = 24.0
    val qrX = 2.0
    val qrY = (height - qrSize) / 2  // Vertically centered

    // Text area starts after QR + 2mm gap
    val textX = qrX + qrSize + 2.0
    val textWidth = width - textX - 2.0  // Right margin 2mm

    // Draw QR code containing LOT ID
    api.draw2DQRCode(lotId, qrX, qrY, qrSize)

    // Calculate text positions
    // Available height: ~28mm (30mm - 2mm margins)
    // Divide among 3-4 lines
    val lineHeight = 5.5
    var currentY = 3.0

    // SKU - largest text (6mm font)
    api.drawText(sku, textX, currentY, textWidth, lineHeight + 1, 6.0)
    currentY += lineHeight + 2

    // Expiry date (if provided)
    if (!expiryDate.isNullOrEmpty()) {
      api.drawText("EXP $expiryDate", textX, currentY, textWidth, lineHeight, 4.0)
      currentY += lineHeight + 0.5
    }

    // Location code (optional)
    if (!locationCode.isNullOrEmpty()) {
      api.drawText("LOC $locationCode", textX, currentY, textWidth, lineHeight, 4.0)
      currentY += lineHeight + 0.5
    }

    // LOT ID - smaller text at bottom
    val shortLotId = if (lotId.length > 10) lotId.takeLast(10) else lotId
    api.drawText("LOT $shortLotId", textX, currentY, textWidth, lineHeight, 3.0)

    // Commit job
    if (api.commitJob()) {
      result.success(true)
    } else {
      result.error("PRINT_FAILED", "Failed to print lot label", null)
    }
  }

  /**
   * Print a weighted item label for pick/pack (50x30mm format)
   * Used for items sold by weight (apples, cheese, etc.)
   * Layout:
   *   Left: QR code (~24x24mm) containing PKG:{orderId}:{weight}
   *   Right (stacked): Product name, weight, price, order reference
   */
  private fun printWeightedItemLabel(
    productName: String,
    weightKg: Double,
    totalPrice: Double,
    orderId: Int,
    currencySymbol: String,
    width: Int,
    height: Int,
    result: Result
  ) {
    val state = api.getPrinterState()
    if (state != PrinterState.Connected && state != PrinterState.Connected2) {
      result.error("NOT_CONNECTED", "Printer is not connected", null)
      return
    }

    // Start drawing task (50mm x 30mm label)
    api.startJob(width.toDouble(), height.toDouble(), 0)

    // Layout calculations (all in mm)
    val qrSize = 24.0
    val qrX = 2.0
    val qrY = (height - qrSize) / 2

    val textX = qrX + qrSize + 2.0
    val lineHeight = 5.5
    var currentY = 3.0

    // QR code content: PKG:{orderId}:{weight}
    val weightStr = String.format("%.3f", weightKg)
    val qrContent = "PKG:$orderId:$weightStr"
    api.draw2DQRCode(qrContent, qrX, qrY, qrSize)

    // Product name - largest text (5mm font)
    api.drawText(productName, textX, currentY, 20.0, lineHeight + 1, 5.0)
    currentY += lineHeight + 1.5

    // Weight - prominent (5mm font)
    val weightDisplay = "$weightStr kg"
    api.drawText(weightDisplay, textX, currentY, 20.0, lineHeight, 5.0)
    currentY += lineHeight + 0.5

    // Price - prominent (5mm font)
    val priceStr = String.format("%.2f", totalPrice)
    val priceDisplay = "$currencySymbol $priceStr"
    api.drawText(priceDisplay, textX, currentY, 20.0, lineHeight, 5.0)
    currentY += lineHeight + 0.5

    // Order reference - smaller (3mm font)
    val orderRef = "Заказ #$orderId"
    api.drawText(orderRef, textX, currentY, 20.0, lineHeight, 3.0)

    // Commit job
    if (api.commitJob()) {
      result.success(true)
    } else {
      result.error("PRINT_FAILED", "Failed to print weighted item label", null)
    }
  }

  private fun printImage(imageData: String, result: Result) {
    val state = api.getPrinterState()
    if (state != PrinterState.Connected && state != PrinterState.Connected2) {
      result.error("NOT_CONNECTED", "Printer is not connected", null)
      return
    }

    try {
      // Decode base64 image data
      val imageBytes = Base64.decode(imageData, Base64.DEFAULT)
      val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

      if (bitmap != null) {
        // Print bitmap
        if (api.printBitmap(bitmap, null)) {
          result.success(true)
        } else {
          result.error("PRINT_FAILED", "Failed to print image", null)
        }
      } else {
        result.error("INVALID_IMAGE", "Failed to decode image", null)
      }
    } catch (e: Exception) {
      result.error("ERROR", "Error printing image: ${e.message}", null)
    }
  }

  private fun setPrintDensity(density: Int, result: Result) {
    val state = api.getPrinterState()
    if (state != PrinterState.Connected && state != PrinterState.Connected2) {
      result.error("NOT_CONNECTED", "Printer is not connected", null)
      return
    }

    api.setPrintDarkness(density)
    result.success(true)
  }

  private fun setPrintSpeed(speed: Int, result: Result) {
    val state = api.getPrinterState()
    if (state != PrinterState.Connected && state != PrinterState.Connected2) {
      result.error("NOT_CONNECTED", "Printer is not connected", null)
      return
    }

    api.setPrintSpeed(speed)
    result.success(true)
  }

  private val callback = object : LPAPI.Callback {
    override fun onStateChange(address: PrinterAddress?, state: PrinterState?) {
      handler.post {
        when (state) {
          PrinterState.Connected, PrinterState.Connected2 -> {
            printerConnectedResult?.success(true)
            printerConnectedResult = null

            // Send event to Flutter
            channel.invokeMethod("onPrinterConnected", null)
          }
          PrinterState.Disconnected -> {
            printerConnectedResult?.error("CONNECTION_FAILED", "Failed to connect to printer", null)
            printerConnectedResult = null

            // Send event to Flutter
            channel.invokeMethod("onPrinterDisconnected", null)
          }
          else -> {}
        }
      }
    }

    override fun onProgressInfo(info: ProgressInfo?, obj: Any?) {}

    override fun onPrinterDiscovery(address: PrinterAddress?, obj: Any?) {}

    override fun onPrintProgress(
      address: PrinterAddress?,
      printData: PrintData?,
      progress: PrintProgress?,
      addiInfo: Any?
    ) {
      handler.post {
        when (progress) {
          PrintProgress.Success -> {
            channel.invokeMethod("onPrintSuccess", null)
          }
          PrintProgress.Failed -> {
            channel.invokeMethod("onPrintFailed", null)
          }
          else -> {}
        }
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    api.quit()

    // Unregister discovery receiver if it was registered
    try {
      context.unregisterReceiver(discoveryReceiver)
    } catch (e: Exception) {
      // Receiver might not be registered
    }
  }
}