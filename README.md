
# esp_ble_prov_wifi

Plugin for provisioning ESP32 Devices over BLE (Bluetooth Low Energy).

This library uses Espressif-provided provisioning libraries for their custom
protocol over BLE.

See the example.

## Requirements

## iOS
 - iOS 13.0+

Add to your Info.plist Bluetooth permissions
```
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Our app uses bluetooth to find, connect and transfer data between different devices</string>
```

## Android

In your `android/app/build.gradle` make sure your minSdkVersion it's 23 or above.

Add to `androud/build.gradle` repositories the following repository `maven { url ("https://jitpack.io/") }`
It should look something like this:

```
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url ("https://jitpack.io/") }
    }
}
```

Bluetooth permissions on Android changed at S (31) so some creative behaviour is
required in the manifest. This is all [documented](https://developer.android.com/guide/topics/connectivity/bluetooth/permissions) which the library requests on your behalf.

# Notes

## Library embedding

Currently we embed the Espressif Android library in libs because Jitpack
fetching doesn't work and we can't 

   

