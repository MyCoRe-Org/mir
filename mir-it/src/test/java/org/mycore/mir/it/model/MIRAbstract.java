package org.mycore.mir.it.model;


public class MIRAbstract {

    private final MIRLanguage language;
    private final String textOrLink;
    private final boolean text;

    public MIRAbstract(boolean text, String textOrLink, MIRLanguage language) {
        this.text = text;
        this.textOrLink = textOrLink;
        this.language = language;
    }


    public MIRLanguage getLanguage() {
        return language;
    }

    public String getTextOrLink() {
        return textOrLink;
    }

    public boolean isText() {
        return text;
    }
}
