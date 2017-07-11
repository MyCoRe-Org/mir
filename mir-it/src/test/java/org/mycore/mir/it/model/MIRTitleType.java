package org.mycore.mir.it.model;

public enum MIRTitleType {
    mainTitle(""),
    translated("translated"),
    alternative("alternative"),
    abbreviated("abbreviated"),
    uniform("uniform");
    MIRTitleType(String value) {
        this.value = value;
    }

    private String value;

    public String getValue() {
        return value;
    }
}
