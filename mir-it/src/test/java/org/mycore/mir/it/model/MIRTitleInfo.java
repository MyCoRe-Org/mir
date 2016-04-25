package org.mycore.mir.it.model;


public class MIRTitleInfo {
    public MIRTitleInfo(String nonSort, MIRLanguage lang, MIRTitleType titleType, String title, String subTitle) {
        this.nonSort = nonSort;
        this.lang = lang;
        this.titleType = titleType;
        this.title = title;
        this.subTitle = subTitle;
    }

    private String nonSort;
    private MIRLanguage lang;
    private MIRTitleType titleType;
    private String title;
    private String subTitle;

    public String getNonSort() {
        return nonSort;
    }

    public MIRLanguage getLang() {
        return lang;
    }

    public MIRTitleType getTitleType() {
        return titleType;
    }

    public String getTitle() {
        return title;
    }

    public String getSubTitle() {
        return subTitle;
    }
}
