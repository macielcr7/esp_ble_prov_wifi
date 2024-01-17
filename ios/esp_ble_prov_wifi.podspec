#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint esp_ble_prov_wifi.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'esp_ble_prov_wifi'
  s.version          = '1.0.0'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
  Provision WiFi on Espressif ESP32 devices over BLE. This library
  uses Espressif-provided provisioning libraries for their custom
  protocol over BLE.
                       DESC
  s.homepage         = 'http://rumina.com.br'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rumina' => 'maciel.sousa@rumina.com.br' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.dependency 'ESPProvision'
end
