
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
    toolbar: "undo redo | styles | bold italic underline | remove | code | indent outdent |" +
        " alignleft aligncenter alignright alignjustify | bullist numlist | table | hr",
    toolbar_mode: "wrap",
    entity_encoding: "raw",
    valid_elements: window["MIR.WebConfig.Editor.TinyMCE.AllowedElements"] || "",
    convert_urls: false,
    verify_html: true
});
