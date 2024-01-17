package com.rumina.esp_ble_prov_wifi;

import org.json.JSONException;
import org.json.JSONObject;

public class Device {
    private String name;
    private String address;

    public Device(String name, String address) {
        this.name = name;
        this.address = address;
    }

    // Getter methods
    public String getName() {
        return name;
    }

    public String getAddress() {
        return address;
    }

    // Setter methods
    public void setName(String name) {
        this.name = name;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public JSONObject toJson() {
        JSONObject json = new JSONObject();
        try {
            json.put("name", this.name);
            json.put("address", this.address);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return json;
    }
}
