package org.mycore.mir.it.model;


public class MIRComplexSearchQuery {
    private final MIRSearchFieldCondition searchFieldConditions;

    private final String text;

    private final MIRSearchField searchField;

    public MIRComplexSearchQuery(MIRSearchFieldCondition searchFieldConditions, String text,
        MIRSearchField searchField) {
        this.searchFieldConditions = searchFieldConditions;
        this.text = text;
        this.searchField = searchField;
    }

    public MIRSearchFieldCondition getSearchFieldConditions() {
        return searchFieldConditions;
    }

    public String getText() {
        return text;
    }

    public MIRSearchField getSearchField() {
        return searchField;
    }


}
