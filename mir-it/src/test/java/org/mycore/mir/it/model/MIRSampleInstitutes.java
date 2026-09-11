package org.mycore.mir.it.model;

public enum MIRSampleInstitutes implements MIRInstitutes {
    Universität_in_Deutschland("Unis"),
    Universität_Jena("Unis.Jena"),
    IBM("Firma.IBM");

    private String value;

    MIRSampleInstitutes(String value) {
        this.value = value;
    }

    @Override
    public String getValue() {
        return value;
    }
}
