package org.mycore.mir.it.model;

/**
 * Created by sebastian on 13.04.16.
 */
public enum MIRLanguage {
    arabic("ar"),
    bosnian("bs"),
    english("en"),
    german("de");

    private String value;

    MIRLanguage(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
