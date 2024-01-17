import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esp_ble_prov_wifi/esp_ble_prov_wifi_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelEspBleProvWifi platform = MethodChannelEspBleProvWifi();
  const MethodChannel channel = MethodChannel('esp_ble_prov_wifi');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
