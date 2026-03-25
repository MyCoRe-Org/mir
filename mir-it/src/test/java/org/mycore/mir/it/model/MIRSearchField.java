package org.mycore.mir.it.model;

public enum MIRSearchField {
    Titel("mods.title,mods.title.lang.de,mods.title.lang.en,mods.title.lang.es,mods.title.lang.fr,mods.title.lang.it,mods.title.lang.ru,mods.title.lang.ru.latin,mods.title.lang.tr"),
    Autor("mods.author"),
    Name("mods.name"),
    Metadaten("allMeta,mods.abstract.lang.de,mods.abstract.lang.en,mods.abstract.lang.es,mods.abstract.lang.fr,mods.abstract.lang.it,mods.abstract.lang.ru,mods.abstract.lang.ru.latin,mods.abstract.lang.tr,mods.subject.lang.de,mods.subject.lang.en,mods.subject.lang.es,mods.subject.lang.fr,mods.subject.lang.it,mods.subject.lang.ru,mods.subject.lang.ru.latin,mods.subject.lang.tr");

    private String value;

    MIRSearchField(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
