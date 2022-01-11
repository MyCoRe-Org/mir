CKEDITOR.editorConfig = function( config ) {

    config.extraPlugins = 'notification,wordcount';

    config.toolbar = [
        { name: 'document', items: [ 'Source'] },
        { name: 'clipboard', items: ['Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ] },
        { name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'CopyFormatting', 'RemoveFormat' ] },
        { name: 'insert', items: [ 'Table', 'HorizontalRule', 'SpecialChar' ] },
        { name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', '-', 'Blockquote', 'CreateDiv', '-', 'JustifyBlock', '-' ] },
        { name: 'styles', items: [ 'Styles', 'Format', 'FontSize' ] },
        { name: 'about', items: [ 'About' ] }
    ];

    config.allowedContent = window["MIR.Editor.HTML.Elements"];
    config.autoParagraph = false;

    config.wordcount = {
        showRemaining: false,
        showParagraphs: true,
        showWordCount: true,
        showCharCount: false,
        countBytesAsChars: false,
        countSpacesAsChars: false,
        countHTML: false,
        countLineBreaks: false,
        hardLimit: true,
        warnOnLimitOnly: false,
        maxParagraphs: -1,
        maxWordCount: -1,
        maxCharCount: -1,
        pasteWarningDuration: 0
    };

};


