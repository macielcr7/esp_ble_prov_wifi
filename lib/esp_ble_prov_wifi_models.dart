class Device {
  final String name;
  final String address;

  Device({
    required this.name,
    required this.address,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      name: json['name'],
      address: json['address'],
    );
  }

  factory Device.convertMapToDevice(map) {
    var json = map.map((key, value) => MapEntry(key as String, value));
    return Device.fromJson(json);
  }
}

class Network {
  final String ssid;
  final int rssi;
  final int auth;

  Network({
    required this.ssid,
    required this.rssi,
    required this.auth,
  });

  factory Network.fromJson(Map<String, dynamic> json) {
    return Network(
      ssid: json['ssid'],
      rssi: json['rssi'],
      auth: json['auth'],
    );
  }
}
