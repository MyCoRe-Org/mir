CKEDITOR.editorConfig = function( config ) {

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

};


