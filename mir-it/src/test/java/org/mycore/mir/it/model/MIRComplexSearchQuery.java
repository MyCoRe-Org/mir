package org.mycore.mir.it.model;

public record MIRComplexSearchQuery(MIRSearchFieldCondition searchFieldConditions, String text,
    MIRSearchField searchField) {
}
