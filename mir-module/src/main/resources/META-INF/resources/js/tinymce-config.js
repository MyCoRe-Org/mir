
tinymce.init({
    selector: "textarea.tinymce",
    license_key: "gpl",
    promotion: false,
    language: currentLang,
    plugins: [
        "advlist", "anchor", "autolink", "code", "fullscreen", "help",
        "lists", "preview",
        "searchreplace", "table", "visualblocks", "wordcount"
    ],
    menubar: false,
    toolbar: window["MIR.WebConfig.Editor.TinyMCE.Toolbar"] || "",
    toolbar_mode: "wrap",
    entity_encoding: "raw",
    valid_elements: window["MIR.WebConfig.Editor.TinyMCE.AllowedElements"] || "",
    convert_urls: false,
    verify_html: true
});
