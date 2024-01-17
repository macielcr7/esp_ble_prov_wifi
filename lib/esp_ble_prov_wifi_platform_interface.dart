import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'esp_ble_prov_wifi_method_channel.dart';
import 'esp_ble_prov_wifi_models.dart';

abstract class EspBleProvWifiPlatform extends PlatformInterface {
  /// Constructs a EspBleProvWifiPlatform.
  EspBleProvWifiPlatform() : super(token: _token);

  static final Object _token = Object();

  static EspBleProvWifiPlatform _instance = MethodChannelEspBleProvWifi();

  /// The default instance of [EspBleProvWifiPlatform] to use.
  ///
  /// Defaults to [MethodChannelEspBleProvWifi].
  static EspBleProvWifiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EspBleProvWifiPlatform] when
  /// they register themselves.
  static set instance(EspBleProvWifiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<Device>> scanBleDevices(String prefix) {
    throw UnimplementedError('scanBleDevices has not been implemented.');
  }

  Future<List<Network>> scanWifiNetworks(
      String deviceName, String proofOfPossession) {
    throw UnimplementedError('scanWifiNetworks has not been implemented.');
  }

  Future<bool?> provisionWifi(String deviceName, String proofOfPossession,
      String ssid, String passphrase) {
    throw UnimplementedError('provisionWifi has not been implemented');
  }
}
