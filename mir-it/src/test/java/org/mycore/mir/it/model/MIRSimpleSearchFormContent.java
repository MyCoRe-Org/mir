package org.mycore.mir.it.model;

public class MIRSimpleSearchFormContent {

    private String title;
    private String author;
    private String metadata;
    private String files;
    private MIRInstitutes institute;
    private MIRStatus status;

    public MIRSimpleSearchFormContent(String title, String author, String metadata, String files,
        MIRInstitutes institute, MIRStatus status) {
        this.title = title;
        this.author = author;
        this.metadata = metadata;
        this.files = files;
        this.institute = institute;
        this.status = status;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getMetadata() {
        return metadata;
    }

    public void setMetadata(String metadata) {
        this.metadata = metadata;
    }

    public String getFiles() {
        return files;
    }

    public void setFiles(String files) {
        this.files = files;
    }

    public MIRInstitutes getInstitute() {
        return institute;
    }

    public void setInstitute(MIRInstitutes institute) {
        this.institute = institute;
    }

    public MIRStatus getStatus() {
        return status;
    }

    public void setStatus(MIRStatus status) {
        this.status = status;
    }
}
