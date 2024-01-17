package com.rumina.esp_ble_prov_wifi;

import android.media.tv.CommandRequest;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;

public class CallContext {
    private MethodCall call;
    private Result result;

    public CallContext(MethodCall call, Result result) {
        this.call = call;
        this.result = result;
    }

    /**
     * Extracts an argument's value from the method call, and returns an error condition if it is not
     * present.
     */
    public String arg(String name) {
        String v = call.argument(name);
        if (v == null) {
            result.error("E0", "Missing argument: " + name, "The argument " + name + " was not provided");
        }
        return v;
    }

    public MethodCall getCall() {
        return this.call;
    }

    public Result getResult() {
        return this.result;
    }
}
