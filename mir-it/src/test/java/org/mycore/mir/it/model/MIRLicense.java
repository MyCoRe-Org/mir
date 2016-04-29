package org.mycore.mir.it.model;

public enum MIRLicense {
    rights_reserved("rights_reserved"),
    cc_30("cc_3.0");


    private String value;

    MIRLicense(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
