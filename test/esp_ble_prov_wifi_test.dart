import 'package:esp_ble_prov_wifi/esp_ble_prov_wifi_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esp_ble_prov_wifi/esp_ble_prov_wifi.dart';
import 'package:esp_ble_prov_wifi/esp_ble_prov_wifi_platform_interface.dart';
import 'package:esp_ble_prov_wifi/esp_ble_prov_wifi_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEspBleProvWifiPlatform
    with MockPlatformInterfaceMixin
    implements EspBleProvWifiPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool?> provisionWifi(String deviceName, String proofOfPossession,
      String ssid, String passphrase) {
    // TODO: implement provisionWifi
    throw UnimplementedError();
  }

  @override
  Future<List<Device>> scanBleDevices(String prefix) {
    // TODO: implement scanBleDevices
    throw UnimplementedError();
  }

  @override
  Future<List<Network>> scanWifiNetworks(
      String deviceName, String proofOfPossession) {
    // TODO: implement scanWifiNetworks
    throw UnimplementedError();
  }
}

void main() {
  final EspBleProvWifiPlatform initialPlatform =
      EspBleProvWifiPlatform.instance;

  test('$MethodChannelEspBleProvWifi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEspBleProvWifi>());
  });

  test('getPlatformVersion', () async {
    EspBleProvWifi espBleProvWifiPlugin = EspBleProvWifi();
    MockEspBleProvWifiPlatform fakePlatform = MockEspBleProvWifiPlatform();
    EspBleProvWifiPlatform.instance = fakePlatform;

    expect(await espBleProvWifiPlugin.getPlatformVersion(), '42');
  });
}
