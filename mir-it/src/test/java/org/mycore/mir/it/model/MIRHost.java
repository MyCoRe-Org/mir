package org.mycore.mir.it.model;

/**
 * Created by sebastian on 13.04.16.
 */
public enum MIRHost {
    standalone("standalone"),
    journal("journal"),
    newspaper("newspaper"),
    collection("collection"),
    festschrift("festschrift"),
    proceedings("proceedings");

    String value;

    MIRHost(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
