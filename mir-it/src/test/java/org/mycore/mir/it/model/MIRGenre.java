package org.mycore.mir.it.model;

/**
 * Created by sebastian on 13.04.16.
 */
public enum MIRGenre {
    article("article"),
    chapter("chapter"),
    entry("entry"),
    preface("preface"),
    speech("speech"),
    review("review"),
    exam("exam"),
    dissertation("dissertation"),
    habilitation("habilitation"),
    diploma_thesis("diploma_thesis"),
    master_thesis("master_thesis"),
    bachelor_thesis("bachelor_thesis"),
    student_resarch_project("student_resarch_project"),
    magister_thesis("magister_thesis"),
    collection("collection"),
    festschrift("festschrift"),
    proceedings("proceedings"),
    lexicon("lexicon"),
    report("report"),
    research_results("research_results"),
    in_house("in_house"),
    press_release("press_release"),
    declaration("declaration"),
    teaching_material("teaching_material"),
    lecture_resource("lecture_resource"),
    course_resources("course_resources"),
    book("book"),
    journal("journal"),
    newspaper("newspaper"),
    series("series"),
    interview("interview"),
    research_data("research_data"),
    patent("patent"),
    poster("poster"),
    audio("audio"),
    video("video"),
    picture("picture"),
    broadcasting("broadcasting"),
    lecture("lecture");

    String value;

    MIRGenre(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}
