package org.mycore.mir.it.model;

public enum MIRTypeOfResource {
    still_image("typeOfResource:still_image"),
    three_dimensional_object("typeOfResource:three_dimensional_object"),
    moving_image("typeOfResource:moving_image"),
    text("typeOfResource:text");

    private String value;

    MIRTypeOfResource(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
