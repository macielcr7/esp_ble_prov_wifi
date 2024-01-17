package com.rumina.esp_ble_prov_wifi;

import android.os.Handler;
import android.os.Looper;

import com.espressif.provisioning.WiFiAccessPoint;
import com.espressif.provisioning.listeners.WiFiScanListener;

import java.util.ArrayList;

public class WifiScanManager extends ActionManager {

    public WifiScanManager(Boss boss) {
        super(boss);
    }

    @Override
    public void call(CallContext ctx) {
        String name = ctx.arg("deviceName");
        if (name == null) return;
        
        String proofOfPossession = ctx.arg("proofOfPossession");
        if (proofOfPossession == null) return;
        
        BleConnector conn = boss.connector(name);
        if (conn == null) return;
        
        boss.d("esp connect: start");
        boss.connect(conn, proofOfPossession, esp -> {
            boss.d("scanNetworks: start");
            esp.scanNetworks(new WiFiScanListener() {
                @Override
                public void onWifiListReceived(ArrayList<WiFiAccessPoint> wifiList) {
                    if (wifiList == null) return;
                    for (WiFiAccessPoint accessPoint : wifiList) {
                        boss.getNetworks().add(new Network(accessPoint.getWifiName(), accessPoint.getRssi(), accessPoint.getSecurity()));
                    }
                    boss.d("scanNetworks: complete " + boss.getNetworks());
                    new Handler(Looper.getMainLooper()).post(() -> {
                        ctx.getResult().success(boss.networksToJson().toString());
                    });
                    boss.setConnectedDevice(null);
                }

                @Override
                public void onWiFiScanFailed(Exception e) {
                    boss.e("scanNetworks: error " + e);
                    ctx.getResult().error("E1", "WiFi scan failed", "Exception details " + e);
                    boss.setConnectedDevice(null);
                }
            });
        });
    }
}
