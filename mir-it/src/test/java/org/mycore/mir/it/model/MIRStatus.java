package org.mycore.mir.it.model;

public enum MIRStatus {
    eingereicht("submitted"),
    gelöscht("deleted"),
    gesperrt("blocked"),
    veröffentlicht("published"),
    wird_bearbeitet("review");

    private String value;

    MIRStatus(String value) {

        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
