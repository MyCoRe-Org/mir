package org.mycore.mir.it.model;

public enum MIRRights {
    rights_reserved("rights_reserved"),
    cc_by("cc_by"),
    cc_by_nc("cc_by-nc"),
    cc_by_nc_nd("cc_by-nc-nd"),
    cc_by_nc_sa("cc_by-nc-sa"),
    cc_by_nd("cc_by-nd"),
    cc_by_sa("cc_by-sa"),
    oa_nlz("oa_nlz");

    private String value;

    MIRRights(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
