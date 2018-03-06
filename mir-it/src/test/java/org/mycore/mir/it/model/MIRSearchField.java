package org.mycore.mir.it.model;

public enum MIRSearchField {
    Titel("mods.title"),
    Autor("mods.author"),
    Name("mods.name"),
    Metadaten("allMeta");

    private String value;

    MIRSearchField(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
