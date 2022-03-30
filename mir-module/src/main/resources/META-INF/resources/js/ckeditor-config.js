CKEDITOR.editorConfig = function( config ) {

    config.extraPlugins = 'notification,wordcount';

    config.toolbar = JSON.parse(window["MIR.WebConfig.Editor.CKEditor.Toolbar"] || "{}");

    config.allowedContent = window["MIR.WebConfig.Editor.CKEditor.AllowedContent"] || "*";
    config.autoParagraph = window["MIR.WebConfig.Editor.CKEditor.AutoParagraph"] || false;

    config.wordcount = {
        showRemaining: window["MIR.WebConfig.Editor.CKEditor.Wordcount.ShowRemaining"] || false,
        showParagraphs: window["MIR.WebConfig.Editor.CKEditor.Wordcount.ShowParagraphs"] || true,
        showWordCount: window["MIR.WebConfig.Editor.CKEditor.Wordcount.ShowWordCount"] || true,
        showCharCount: window["MIR.WebConfig.Editor.CKEditor.Wordcount.ShowCharCount"] || false,
        countBytesAsChars: window["MIR.WebConfig.Editor.CKEditor.Wordcount.CountBytesAsChars"] || false,
        countSpacesAsChars: window["MIR.WebConfig.Editor.CKEditor.Wordcount.CountSpacesAsChars"] || false,
        countHTML: window["MIR.WebConfig.Editor.CKEditor.Wordcount.CountHTML"] || false,
        countLineBreaks: window["MIR.WebConfig.Editor.CKEditor.Wordcount.CountLineBreaks"] || false,
        hardLimit: window["MIR.WebConfig.Editor.CKEditor.Wordcount.HardLimit"] || true,
        warnOnLimitOnly: window["MIR.WebConfig.Editor.CKEditor.Wordcount.WarnOnLimitOnly"] || false,
        maxParagraphs: window["MIR.WebConfig.Editor.CKEditor.Wordcount.MaxParagraphs"] || -1,
        maxWordCount: window["MIR.WebConfig.Editor.CKEditor.Wordcount.MaxWordCount"] || -1,
        maxCharCount: window["MIR.WebConfig.Editor.CKEditor.Wordcount.MaxCharCount"] || -1,
        pasteWarningDuration: window["MIR.WebConfig.Editor.CKEditor.Wordcount.PasteWarningDuration"] || 0
    };

};