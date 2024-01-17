package com.rumina.esp_ble_prov_wifi;

import org.json.JSONException;
import org.json.JSONObject;

public class Network {
    private String ssid;
    private int rssi;
    private int auth;

    public Network(String ssid, int rssi, int auth) {
        this.ssid = ssid;
        this.rssi = rssi;
        this.auth = auth;
    }

    // Getter methods
    public String getSsid() {
        return ssid;
    }

    public int getRssi() {
        return rssi;
    }

    public int getAuth() {
        return auth;
    }

    // Setter methods
    public void setSsid(String ssid) {
        this.ssid = ssid;
    }

    public void setRssi(int rssi) {
        this.rssi = rssi;
    }

    public void setAuth(int auth) {
        this.auth = auth;
    }

    public JSONObject toJson() {
        JSONObject json = new JSONObject();
        try {
            json.put("ssid", this.ssid);
            json.put("rssi", this.rssi);
            json.put("auth", this.auth);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return json;
    }
}
