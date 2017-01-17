package org.mycore.mir.it.model;

public enum MIRIdentifier {
    doi("doi"), hdl("hdl"), urn("urn"), uri("uri"), ppn("ppn");

    MIRIdentifier(String value){
        this.value = value;
    }

    String value;

    public String getValue() {
        return value;
    }
}
