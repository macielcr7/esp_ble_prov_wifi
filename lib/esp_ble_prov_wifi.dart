import 'esp_ble_prov_wifi_models.dart';
import 'esp_ble_prov_wifi_platform_interface.dart';

/// Plugin provides core functionality to provision ESP32 devices over BLE
class EspBleProvWifi {
  /// Initiates a scan of BLE devices with the given [prefix].
  ///
  /// ESP32 Arduino demo defaults this value to "PROV_"
  Future<List<Device>> scanBleDevices(String prefix) {
    return EspBleProvWifiPlatform.instance.scanBleDevices(prefix);
  }

  /// Scan the available WiFi networks for the given [deviceName] and
  /// [proofOfPossession] string.

  /// This library uses SECURITY_1 by default which insists on a
  /// [proofOfPossession] string. ESP32 Arduino demo defaults this value to
  /// "abcd1234"
  Future<List<Network>> scanWifiNetworks(
      String deviceName, String proofOfPossession) {
    return EspBleProvWifiPlatform.instance
        .scanWifiNetworks(deviceName, proofOfPossession);
  }

  /// Provision the named WiFi network at [ssid] with the given [passphrase] for
  /// the named device [deviceName] and [proofOfPossession] string.
  Future<bool?> provisionWifi(String deviceName, String proofOfPossession,
      String ssid, String passphrase) {
    return EspBleProvWifiPlatform.instance
        .provisionWifi(deviceName, proofOfPossession, ssid, passphrase);
  }

  /// Returns the native platform version
  Future<String?> getPlatformVersion() {
    return EspBleProvWifiPlatform.instance.getPlatformVersion();
  }
}
