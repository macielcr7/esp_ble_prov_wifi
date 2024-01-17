import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'esp_ble_prov_wifi_models.dart';
import 'esp_ble_prov_wifi_platform_interface.dart';

/// An implementation of [EspBleProvWifiPlatform] that uses method channels.
class MethodChannelEspBleProvWifi extends EspBleProvWifiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('esp_ble_prov_wifi');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<Device>> scanBleDevices(String prefix) async {
    final args = {'prefix': prefix};
    final raw =
        await methodChannel.invokeMethod<String>('scanBleDevices', args);
    final List<Device> devices = [];
    if (raw != null) {
      var rawJson = json.decode(raw);
      for (var device in rawJson) {
        devices.add(Device.fromJson(device));
      }
    }
    return devices;
  }

  @override
  Future<List<Network>> scanWifiNetworks(
      String deviceName, String proofOfPossession) async {
    final args = {
      'deviceName': deviceName,
      'proofOfPossession': proofOfPossession,
    };
    final raw =
        await methodChannel.invokeMethod<String>('scanWifiNetworks', args);
    final List<Network> networks = [];
    if (raw != null) {
      var rawJson = json.decode(raw);
      for (var network in rawJson) {
        networks.add(Network.fromJson(network));
      }
    }
    return networks;
  }

  @override
  Future<bool?> provisionWifi(String deviceName, String proofOfPossession,
      String ssid, String passphrase) async {
    final args = {
      'deviceName': deviceName,
      'proofOfPossession': proofOfPossession,
      'ssid': ssid,
      'passphrase': passphrase
    };
    return await methodChannel.invokeMethod<bool?>('provisionWifi', args);
  }
}
