jQuery('#tocShowAll').click(function () {
    jQuery(this).hide();
    jQuery('.mir-toc-sections .collapse').collapse('show');
    jQuery('#tocHideAll').show();
    return false;
});

jQuery('#tocHideAll').click(function () {
    jQuery(this).hide();
    jQuery('.mir-toc-sections .collapse').collapse('hide');
    jQuery('#tocShowAll').show();
    return false;
});

jQuery('.mir-toc-sections .below').each(
    function (index) {
        jQuery(this).on(
            'shown.bs.collapse',
            function (evt) {
                if (jQuery(this).is(evt.target)) {
                    jQuery(this).parent().find(
                        "a > span.toggle-collapse").first()
                        .removeClass('fa-chevron-right')
                        .addClass('fa-chevron-down');
                }
            }
        );
        jQuery(this).on(
            'hidden.bs.collapse',
            function (evt) {
                if (jQuery(this).is(evt.target)) {
                    jQuery(this).parent().find(
                        "a > span.toggle-collapse").first()
                        .removeClass('fa-chevron-down')
                        .addClass('fa-chevron-right');
                }
            }
        );
    }
);
