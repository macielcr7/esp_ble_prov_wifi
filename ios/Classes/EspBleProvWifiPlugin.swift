import Flutter
import UIKit
import ESPProvision

struct Device {
    let name: String
    let address: String

    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "address": address
        ]
    }
}

struct Network {
    let ssid: String
    let rssi: Int32
    let auth: Int

    func toDictionary() -> [String: Any] {
        return [
            "ssid": ssid,
            "rssi": rssi,
            "auth": auth
        ]
    }
}

public class EspBleProvWifiPlugin: NSObject, FlutterPlugin {
  private let SCAN_BLE_DEVICES = "scanBleDevices"
  private let SCAN_WIFI_NETWORKS = "scanWifiNetworks"
  private let PROVISION_WIFI = "provisionWifi"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "esp_ble_prov_wifi", binaryMessenger: registrar.messenger())
    let instance = EspBleProvWifiPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let provisionService = BLEProvisionService(result: result);
    let arguments = call.arguments as! [String: Any]

    print("handle arguments: \(arguments)")
    
    if(call.method == SCAN_BLE_DEVICES) {
        let prefix = arguments["prefix"] as! String
        provisionService.searchDevices(prefix: prefix)
    } else if(call.method == SCAN_WIFI_NETWORKS) {
        let deviceName = arguments["deviceName"] as! String
        let proofOfPossession = arguments["proofOfPossession"] as! String
        provisionService.scanWifiNetworks(deviceName: deviceName, proofOfPossession: proofOfPossession)
    } else if (call.method == PROVISION_WIFI) {
        let deviceName = arguments["deviceName"] as! String
        let proofOfPossession = arguments["proofOfPossession"] as! String
        let ssid = arguments["ssid"] as! String
        let passphrase = arguments["passphrase"] as! String
        provisionService.provision(
            deviceName: deviceName,
            proofOfPossession: proofOfPossession,
            ssid: ssid,
            passphrase: passphrase
        )
    } else {
        result("iOS " + UIDevice.current.systemVersion)
    }
    }
}


protocol ProvisionService {
    var result: FlutterResult { get }
    func searchDevices(prefix: String) -> Void
    func scanWifiNetworks(deviceName: String, proofOfPossession: String) -> Void
    func provision(deviceName: String, proofOfPossession: String, ssid: String, passphrase: String) -> Void
}

private class BLEProvisionService: ProvisionService {
    fileprivate var result: FlutterResult
    var connectedDevice : ESPDevice?
    
    init(result: @escaping FlutterResult) {
        self.result = result
        ESPProvisionManager.shared.enableLogs(true)
    }
    
    func searchDevices(prefix: String) {
        ESPProvisionManager.shared.searchESPDevices(devicePrefix: prefix, transport:.ble, security:.secure) { deviceList, error in
            if(error != nil) {
                if( error?.code != 27){
                    ESPErrorHandler.handle(error: error!, result: self.result)
                }
            }
            
            let lists = deviceList?.map { device in
                Device(name: device.name, address: device.name)
            } ?? []
            self.result(self.devicesToJson(devices: lists))
            
        }
    }

    func devicesToJson(devices: [Device]) -> String {
        var jsonArray: [[String: Any]] = []
        for device in devices {
            jsonArray.append(device.toDictionary())
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                return jsonString;
            } else {
                print("Não foi possível converter os dados JSON para String.")
            }
        } catch {
            print("Erro na serialização para JSON: \(error)")
        }
        return "[]";
    }
    
    func scanWifiNetworks(deviceName: String, proofOfPossession: String) {
        self.connect(deviceName: deviceName, proofOfPossession: proofOfPossession) {
            device in
            device?.scanWifiList { wifiList, error in
                if(error != nil) {
                    NSLog("Error scanning wifi networks, deviceName: \(deviceName) ")
                    ESPErrorHandler.handle(error: error!, result: self.result)
                }
                let lists = wifiList?.map { network in
                    Network(ssid: network.ssid, rssi: network.rssi, auth: network.auth.rawValue)
                } ?? []
                self.result(self.networksToJson(networks: lists))
                self.setConnectedDevice(nil)
            }
        }
    }
    
    func networksToJson(networks: [Network]) -> String {
        var jsonArray: [[String: Any]] = []
        for network in networks {
            jsonArray.append(network.toDictionary())
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
                return jsonString;
            } else {
                print("Não foi possível converter os dados JSON para String.")
            }
        } catch {
            print("Erro na serialização para JSON: \(error)")
        }
        return "[]";
    }
    
    func provision(deviceName: String, proofOfPossession: String, ssid: String, passphrase: String) {
        self.connect(deviceName: deviceName, proofOfPossession: proofOfPossession){
            device in
            device?.provision(ssid: ssid, passPhrase: passphrase) { status in
                switch status {
                case .success:
                    NSLog("Success provisioning device. ssid: \(ssid), deviceName: \(deviceName) ")
                    self.result(true)
                    self.setConnectedDevice(nil)
                case .configApplied:
                    NSLog("Wifi config applied device. ssid: \(ssid), deviceName: \(deviceName) ")
                case .failure:
                    NSLog("Failed to provision device. ssid: \(ssid), deviceName: \(deviceName) ")
                    self.result(false)
                    self.setConnectedDevice(nil)
                }
            }
        }
    }
    
    private func connect(deviceName: String, proofOfPossession: String, completionHandler: @escaping (ESPDevice?) -> Void) {
        ESPProvisionManager.shared.createESPDevice(deviceName: deviceName, transport: .ble, security: .secure, proofOfPossession: proofOfPossession) { espDevice, error in
            self.setConnectedDevice(nil)
            if(error != nil) {
                ESPErrorHandler.handle(error: error!, result: self.result)
            }
            espDevice?.connect { status in
                switch status {
                case .connected:
                    self.setConnectedDevice(espDevice)
                    completionHandler(espDevice!)
                case let .failedToConnect(error):
                    ESPErrorHandler.handle(error: error, result: self.result)
                default:
                    self.result(FlutterError(code: "DEVICE_DISCONNECTED", message: nil, details: nil))
                }
            }
        }
    }

    private func setConnectedDevice(_ newDevice: ESPDevice?){
        if let lastDevice = self.connectedDevice {
            if let newDevice = newDevice {
                if( newDevice.name == lastDevice.name ){
                    return
                }
            }
            lastDevice.disconnect()
            self.connectedDevice = nil
        }
        
        if let newDevice = newDevice {
            self.connectedDevice = newDevice
            self.debug("Connected to device: \(newDevice.name)")
        }else{
            self.connectedDevice = nil
            self.debug("Cleared connected device")
        }
    }

    private func debug(_ message: String){
        print("EspBleProvWifi: \(message)")
    }
    
}

private class ESPErrorHandler {
    static func handle(error: ESPError, result: FlutterResult) {
        result(FlutterError(code: String(error.code), message: error.description, details: nil))
    }
}
