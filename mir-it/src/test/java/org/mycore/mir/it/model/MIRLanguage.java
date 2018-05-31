package org.mycore.mir.it.model;

/**
 * Created by sebastian on 13.04.16.
 */
public enum MIRLanguage {
    arabic("Arabisch"),
    bosnian("Bosnisch"),
    english("Englisch"),
    german("Deutsch");

    private String value;

    MIRLanguage(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
