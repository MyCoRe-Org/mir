package org.mycore.mir.it.model;

public enum MIRLicense {
    rights_reserved("rights_reserved"),
    cc_by_40("cc_by_4.0");


    private String value;

    MIRLicense(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
