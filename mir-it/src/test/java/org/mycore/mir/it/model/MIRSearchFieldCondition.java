package org.mycore.mir.it.model;

public enum MIRSearchFieldCondition {
    enthält("contains"),
    wie_("like"),
    Phrase("phrase");

    private String value;

    MIRSearchFieldCondition(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
