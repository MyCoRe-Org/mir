package org.mycore.mir.it.model;

public enum MIRInstitutes implements MIRSampleInstitutes {
    Universität_in_Deutschland("Unis"),
    Universität_Jena("Unis.Jena"),
    IBM("Firma.IBM");

    private String value;

    MIRInstitutes(String value) {
        this.value = value;
    }

    @Override
    public String getValue() {
        return value;
    }
}
