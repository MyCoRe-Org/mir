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

    $('.confirm_deletion').confirm();

    // activate empty nav-bar search
    $('.navbar-search').find(':input[value=""]').attr('disabled', false);

    // Search
    $("#index_search_form").submit(function () {
      if ($('#index_search').val().match('[^\\.]\\*' + '$')) {
        $('#index_search').val($('#index_search').val().replace('*','.*'));
      }
      else {
        $('#index_search').val($('#index_search').val()+".*");
      }
    });

    //date filter option
    $('.mir-search-options-date input').ready(function() {
      var currentURL = window.location.href;
      var fqDate = '';
      //input start val
      if(currentURL.indexOf('&fq=mods.dateIssued') > 0) {
        fqDate = currentURL.substr(currentURL.indexOf('&fq=mods.dateIssued'));
        fqDate = decodeURIComponent(fqDate.split('&')[1]);
        $(".mir-search-options-date input").val(fqDate.replace(/[a-zA-Z.:"+*={}/\]/\[]/g, ''));
      }
      //select start val
      if(fqDate.indexOf('"') > 0) {
        $('.mir-search-options-date select').val('=');
      }
      if(fqDate.indexOf('+TO+*') > 0 && fqDate.indexOf('{') > 0) {
        $('.mir-search-options-date select').val('>');
      }
      if(fqDate.indexOf('+TO+*') > 0 && fqDate.indexOf('[') > 0) {
        $('.mir-search-options-date select').val('>=');
      }
      if(fqDate.indexOf('*+TO+') > 0 && fqDate.indexOf('}') > 0) {
        $('.mir-search-options-date select').val('<');
      }
      if(fqDate.indexOf('*+TO+') > 0 && fqDate.indexOf(']') > 0) {
        $('.mir-search-options-date select').val('<=');
      }
    });

    //date filter option
    $('.mir-search-options-date input').keyup(function(event) {
      if(event.which === 13) {
        var currentURL = window.location.href;
        var fqDate = '';
        var newURL = currentURL;
        if(currentURL.indexOf('&fq=mods.dateIssued') > 0) {
          fqDate = currentURL.substr(currentURL.indexOf('&fq=mods.dateIssued'));
          fqDate = fqDate.split('&')[1];
          newURL = currentURL.replace('&' + fqDate, '');
        }
        if($(this).val() != '') {
          var operator = $('.mir-search-options-date select').val();
          if(operator == '=') {
            newURL = newURL + '&fq=mods.dateIssued%3A"' + $(this).val() + '"';
          }
          if(operator == '>') {
            newURL = newURL + '&fq=mods.dateIssued%3A{' + $(this).val() + '+TO+*]';
          }
          if(operator == '>=') {
            newURL = newURL + '&fq=mods.dateIssued%3A[' + $(this).val() + '+TO+*]';
          }
          if(operator == '<') {
            newURL = newURL + '&fq=mods.dateIssued%3A[*+TO+' + $(this).val() + '}';
          }
          if(operator == '<=') {
            newURL = newURL + '&fq=mods.dateIssued%3A[*+TO+' + $(this).val() + ']';
          }
        }
        window.location.href = newURL;
      }
    });

    //colapse the next element
    $('[data-toggle=collapse-next]').click(function() {
      $(this).next().collapse('toggle');
    });

    // Enables the datetimepicker
    if (jQuery.fn.datetimepicker) {
      $(function () {
        $('.datetimepicker').find('input').datetimepicker({
          locale: 'de',
          format: 'YYYY-MM-DD',
          extraFormats: [ 'YYYY','YYYY-MM', 'YYYY-MM-DD' ]
        });
      });
    };

    // for configuration look here: http://dotdotdot.frebsite.nl/
    if (jQuery.fn.dotdotdot) {
      $(".ellipsis").dotdotdot({
        ellipsis	: '... ',
        after: "a.readmore"
      });
    };

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
    html : "true",
    trigger: "focus"
  });

})(jQuery);