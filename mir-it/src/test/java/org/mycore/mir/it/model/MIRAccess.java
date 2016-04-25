package org.mycore.mir.it.model;

public enum MIRAccess {
    public_("unlimited"),
    intern("intern"),
    ipAddressRange("ipAddressRange");

    private String value;

    MIRAccess(String value) {

        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
