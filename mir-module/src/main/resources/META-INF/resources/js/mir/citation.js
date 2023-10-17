(function() {
    $(document).ready(function () {
        const citeSelect = $("#mir-csl-cite");
        let objectID = citeSelect.attr("data-object-id");
        let defaultStyle = citeSelect.attr("data-default-selected");

        $('#mir-csl-cite').on('change', function() {
            getCitation(objectID, $(this).val(), false);
            localStorage.setItem('style', $(this).val());
        });

        loadStyle(objectID, defaultStyle);
    });

    function getCitation(objectID, style, first) {
        $.ajax({
            type: 'GET',
            url: window.webApplicationBaseURL+'receive/'+ objectID +'?XSL.Transformer=mods2csl&XSL.style=' + style + '&XSL.format=html',
            // fixed MIR-550: overrides wrong charset=iso-8859-1
            mimeType: 'text/html;charset=UTF-8',
            success: function(data){
                $('#citation-text').html(data);
                $('#citation-text').removeClass("d-none");
                $('#citation-alert').addClass("d-none");
                $('#citation-error').addClass("d-none");
            },
            error: function (error) {
                console.warn("Citation not available: " + error.status + " " + error.statusText + ": " + error.responseText);
                $('#citation-alert').removeClass("d-none");
                $('#citation-text').addClass("d-none");
            }
        });
    }

    function loadStyle(objectID, defaultStyle) {
        let style = localStorage.getItem('style');
        if (style !== undefined && style !== null && style !== '') {
            getCitation(objectID, style, true);
            $('#mir-csl-cite').val(style);
        }
        else {
            if(defaultStyle){
                getCitation(objectID, defaultStyle, true);
                $('#mir-csl-cite').val(defaultStyle);
            } else {
                getCitation(objectID, 'deutsche-sprache', true);
                console.warn("No default style defined. Using 'deutsche-sprache'.");
            }
        }
    }

})();
