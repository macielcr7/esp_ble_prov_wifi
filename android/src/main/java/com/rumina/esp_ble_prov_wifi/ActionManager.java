package com.rumina.esp_ble_prov_wifi;

public abstract class ActionManager {
    protected Boss boss;

    public ActionManager(Boss boss) {
        this.boss = boss;
    }

    public abstract void call(CallContext ctx);
}
