#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_dothantech_lpapi_thermal_printer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_dothantech_lpapi_thermal_printer'
  s.version          = '2.0.1'
  s.summary          = 'Flutter plugin for Dothantech LPAPI thermal label printers'
  s.description      = <<-DESC
Flutter plugin for Dothantech LPAPI thermal label printers. Supports Bluetooth discovery, direct connection without pairing, and printing of text, barcodes, QR codes, and images.
                       DESC
  s.homepage         = 'https://github.com/ancill/flutter_dothantech_lpapi_thermal_printer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Dothantech' => 'support@dothantech.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Preserve both device and simulator libraries
  s.preserve_paths = 'Frameworks/**/*'

  # Add CoreBluetooth framework dependency
  s.frameworks = 'CoreBluetooth', 'UIKit', 'Foundation'
  s.libraries = 'c++'

  # Conditionally link the correct library based on the target
  # For device builds, use device library; for simulator, use simulator library
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS[sdk=iphoneos*]' => '-ObjC -force_load ${PODS_TARGET_SRCROOT}/Frameworks/device/libLPAPI.a',
    'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '-ObjC -force_load ${PODS_TARGET_SRCROOT}/Frameworks/simulator/libLPAPI.a',
    'HEADER_SEARCH_PATHS' => '${PODS_TARGET_SRCROOT}/Frameworks'
  }

  s.user_target_xcconfig = {
    'OTHER_LDFLAGS[sdk=iphoneos*]' => '-force_load ${PODS_ROOT}/../.symlinks/plugins/flutter_dothantech_lpapi_thermal_printer/ios/Frameworks/device/libLPAPI.a',
    'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '-force_load ${PODS_ROOT}/../.symlinks/plugins/flutter_dothantech_lpapi_thermal_printer/ios/Frameworks/simulator/libLPAPI.a'
  }

  s.swift_version = '5.0'
end
