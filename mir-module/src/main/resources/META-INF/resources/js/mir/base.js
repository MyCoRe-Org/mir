(function($) {
  $﻿(document).ready(function() {

    //for select box in search field on hit list page
    $( ".search_type a" ).click(function() {
        $( "#search_type_label" ).html( $( this ).html() );
        $( "#search_type_button" ).attr( 'value', $( this ).attr('value') );
    });

    //change search string on result page
    $( ".search_box form" ).submit(function( event ) {
      if ($('#search_type_button').attr('value') == 'all') {
        var newAction = $(this).attr('action') + "?qry=" + $('.search_box input').val();
      } else {
        var newAction = $(this).attr('action') + "?qry=" + $('.search_box input').val() + "&amp;df=" + $('#search_type_button').attr('value');
      }
      $(this).attr('action', newAction);
    });

    var languageList = jQuery('#topnav .languageList');
    jQuery('#topnav .languageSelect').click(function() {
      languageList.toggleClass('hide');
    });
    // editor fix (to many tables)
    $('table.editorPanel td:has(table)').css('padding', '0');

    $('.confirm_deletion, .confirm_derivate_deletion, .confirm_directory_deletion, .confirm_file_deletion').confirm({
      confirm: function(button) {
        location.href = $(this).attr('href');
      },
    });

    // activate empty nav-bar search
    $('.navbar-search').find(':input[value=""]').attr('disabled', false);

    // Search
    $("#index_search_form").submit(function () {
      if ($('#index_search').val().match('[^\\.]\\*' + '$')) {
        $('#index_search').val($('#index_search').val().replace('*','.*'));
      }
    });


  }); // END $﻿(document).ready()

  window.fireMirSSQuery = function base_fireMirSSQuery(form) {
    $(form).find(':input[value=""]').attr('disabled', true);
    return true;
  };

  $(document).tooltip({
    selector : "[data-toggle=tooltip]",
    container : "body"
  });

  $(document).popover({
    selector : "[data-toggle=popover]",
    container : "body",
    html : "true"
  });


})(jQuery);
