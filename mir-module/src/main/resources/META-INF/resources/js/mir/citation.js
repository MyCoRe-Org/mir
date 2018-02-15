(function() {
    $(document).ready(function () {
        let currentDOI = $("#crossref-cite").attr("data-doi");

        $('#crossref-cite').on('change', function() {
            getCitation(currentDOI, $(this).val(), false);
            localStorage.setItem('style', $(this).val());
        });

        loadStyle(currentDOI);
    });

    function getCitation(doi, style, first) {
        $.ajax({
            type: 'GET',
            url: 'https://data.datacite.org/text/x-bibliography;style=' + style + ';locale=de-DE/' + doi,
            // fixed MIR-550: overrides wrong charset=iso-8859-1
            mimeType: 'text/html;charset=UTF-8',
            success: function(data){
                $('#crossref-citation-text').text(data);
                $('#crossref-citation-text').removeClass("hidden");
                $('#default-citation-text').addClass("hidden");
                $('#crossref-citation-alert').addClass("hidden");
                $('#crossref-citation-error').addClass("hidden");
            },
            error: function (error) {
                console.warn("Citation not available: " + error.status + " " + error.statusText + ": " + error.responseText);
                if (first) {
                    $('#crossref-cite').addClass("hidden");
                    $('#crossref-citation-alert').addClass("hidden");
                }
                else {
                    $('#crossref-cite').removeClass("hidden");
                    $('#crossref-citation-alert').removeClass("hidden");
                }
                $('#default-citation-text').removeClass("hidden");
                $('#crossref-citation-text').addClass("hidden");
                $('#crossref-citation-error').removeClass("hidden");
            }
        });
    }

    function loadStyle(doi) {
        let style = localStorage.getItem('style');
        if (style !== undefined && style !== null && style !== '') {
            getCitation(doi, style, true);
            $('#crossref-cite').val(style);
        }
        else {
            getCitation(doi, 'deutsche-sprache', true);
        }
    }

})();
