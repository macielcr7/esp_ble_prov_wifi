import 'package:esp_ble_prov_wifi/esp_ble_prov_wifi_models.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:esp_ble_prov_wifi/esp_ble_prov_wifi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _espBleProvWifiPlugin = EspBleProvWifi();

  final defaultPadding = 12.0;
  final defaultDevicePrefix = 'RT';

  List<Device> devices = [];
  List<Network> networks = [];

  String selectedDeviceName = '';
  String selectedSsid = '';
  String feedbackMessage = '';

  final prefixController = TextEditingController(text: 'RT');
  final proofOfPossessionController =
      TextEditingController(text: 'RUMITANK123');
  final passphraseController = TextEditingController();

  Future scanBleDevices() async {
    final prefix = prefixController.text;
    final scannedDevices = await _espBleProvWifiPlugin.scanBleDevices(prefix);
    setState(() {
      devices = scannedDevices;
    });
    pushFeedback('Success: scanned BLE devices');
  }

  Future scanWifiNetworks() async {
    final proofOfPossession = proofOfPossessionController.text;
    try {
      final scannedNetworks = await _espBleProvWifiPlugin.scanWifiNetworks(
          selectedDeviceName, proofOfPossession);
      setState(() {
        networks = scannedNetworks;
      });
      pushFeedback('Success: scanned WiFi on $selectedDeviceName');
    } catch (e) {
      pushFeedback('Error: $e');
    }
  }

  Future provisionWifi() async {
    final proofOfPossession = proofOfPossessionController.text;
    final passphrase = passphraseController.text;
    await _espBleProvWifiPlugin.provisionWifi(
        selectedDeviceName, proofOfPossession, selectedSsid, passphrase);
    pushFeedback(
        'Success: provisioned WiFi $selectedDeviceName on $selectedSsid');
  }

  pushFeedback(String msg) {
    setState(() {
      feedbackMessage = '$feedbackMessage\n$msg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ESP BLE Provisioning Example'),
          actions: [
            IconButton(
                icon: const Icon(Icons.bluetooth),
                onPressed: () async {
                  await scanBleDevices();
                }),
          ],
        ),
        bottomSheet: SafeArea(
          child: Container(
            width: double.infinity,
            color: Colors.black87,
            padding: EdgeInsets.all(defaultPadding),
            child: Text(
              feedbackMessage,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green.shade600),
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text('Device Prefix'),
                        ),
                        Expanded(
                          child: TextField(
                            controller: prefixController,
                            decoration: const InputDecoration(
                                hintText: 'enter device prefix'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(defaultPadding),
                    child: const Text('BLE devices'),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        title: Text(
                          devices[i].name,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () async {
                          selectedDeviceName = devices[i].name;
                          await scanWifiNetworks();
                        },
                      );
                    },
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text('Proof of possession'),
                        ),
                        Expanded(
                          child: TextField(
                            controller: proofOfPossessionController,
                            decoration: const InputDecoration(
                                hintText: 'enter proof of possession string'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(defaultPadding),
                    child: const Text('WiFi networks'),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: networks.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        title: Text(
                          networks[i].ssid,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () async {
                          selectedSsid = networks[i].ssid;
                          await provisionWifi();
                        },
                      );
                    },
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text('WiFi Passphrase'),
                        ),
                        Expanded(
                          child: TextField(
                            controller: passphraseController,
                            decoration: const InputDecoration(
                                hintText: 'enter passphrase'),
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
