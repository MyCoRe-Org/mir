(function($) {
  $(document).ready(function() {

    if($(".sherpa-issn").length > 0) {
      $(".sherpa-issn").each(function() {
        getSherpaIssn($(this));
      });
    }

//--- in metadata view the select/video controller
    // on start load the first source
    $(".mir-player video").ready(function(){
      $("#videoChooser").change();
    });

    //get all sources of selected item in a var and give it to player
    $("#videoChooser").change(function() {
      // reuse player
      var myPlayer = $(this).data("player");
      (!myPlayer) && (myPlayer = videojs($(".mir-player video").attr("id"))) && ($(this).data("player", myPlayer));
        
      myPlayer.src($.parseJSON($("#" + $(this).val() + " script").text()));
    });
//--------

    $("body").on("focus", ".search-organization input[name*='mods:displayForm']", function() {
      $(".name-modal textarea").val($(this).val());
      $(this).addClass("inModal");
      $(".name-modal").modal("show");
    });

    $("body").on("keydown", ".name-modal textarea", function(event) {
      if (event.which == 27) {
        $(this).modal("hide");
      }
    });

    $("body").on("hide.bs.modal", ".name-modal", function() {
      var input = $(this).find("textarea").val().replace(/\n/g, " ");
      $(".inModal").val(input);
      $(".inModal").attr("title", input);
      $(".inModal").removeClass("inModal");
    });

    $("#mir_relatedItem > li > ul").hide();

    //show full version history in metadata view
    $("#historyStarter").click(function() {
      $("#historyModal").modal("show");
    });

    //define the primary button in a form with multiple submit buttons
    $("[order=primary-button]").ready(function() {
      var myForm = $("[order=primary-button]").parents("form:first");
      $(myForm).find("input[type=text]").keypress(function(event) {
        if(event.keyCode == 13 || event.which == 13) {
          $("[order=primary-button]").click();
        }
      });
    });

    function getSherpaIssn(elm) {
      $.ajax({
        url: "http://www.sherpa.ac.uk/romeo/api29.php?issn=" + $(elm).html(),
        type: "GET",
        success: function(data) {
          if($(data).find("outcome").html() != "failed") {
            $(data).find("publisher").each(function() {
              var color = $(this).find("romeocolour");
              if (color != undefined && $(color).html() != "") {
                $(elm).parent().after("<dt>SHERPA/RoMEO:</dt><dd><a href='http://www.sherpa.ac.uk/romeo/search.php?issn=" + $(elm).html() + "'>RoMEO " + $(color).html() + " Journal</a>");
                $(elm).remove();
              }
            });
          }
          console.log("sherpa request failed for ISSN: " +  $(elm).html());
        },
        error: function(error) {
          console.log(error);
        }
      });
    }

    //for select box in search field on hit list page
    $( ".search_type a" ).click(function() {
        $( "#search_type_label" ).html( $( this ).html() );
        $( "#search_type_button" ).attr( 'value', $( this ).attr('value') );
    });

    //change search string on result page
    $( ".search_box form" ).submit(function( event ) {
      var origSearchAction = $(this).attr('action');
      if (origSearchAction.includes('servlets/solr/find')) {
        var replAction = origSearchAction.replace(/(.*[&|\?])(q=.*?)&(.*)/,'$1$3&$2');
        if ($('#search_type_button').attr('value') == 'all') {
            var newAction = replAction + "+%2B" + $('.search_box input').val();
          } else {
            var newAction = replAction + "+%2B" + $('.search_box input').val() + "&df=" + $('#search_type_button').attr('value');
          }
      }
      else {
        var replAction = origSearchAction.replace(/(.*[&|\?])(q=.*?)&(.*)/,'$1$3&$2');
        if ($('#search_type_button').attr('value') == 'all') {
            var newAction = replAction + "+%2BallMeta:" + $('.search_box input').val();
          } else {
            var newAction = replAction + "+%2B" + $('#search_type_button').attr('value') + ":" + $('.search_box input').val();
          }
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
      if(currentURL.indexOf('&fq=mods.dateIssued') > 0) {
        var fqDate = currentURL.substr(currentURL.indexOf('&fq=mods.dateIssued'));
        fqDate = decodeURIComponent(fqDate.split('&')[1]);

        //comparison val
        if(fqDate.indexOf('"') > 0) {
          $(".mir-search-options-date .list-group a").append(' = ');
        }
        if(fqDate.indexOf('+TO+*') > 0 && fqDate.indexOf('{') > 0) {
          $(".mir-search-options-date .list-group a").append(' > ');
        }
        if(fqDate.indexOf('+TO+*') > 0 && fqDate.indexOf('[') > 0) {
          $(".mir-search-options-date .list-group a").append(' >= ');
        }
        if(fqDate.indexOf('*+TO+') > 0 && fqDate.indexOf('}') > 0) {
          $(".mir-search-options-date .list-group a").append(' < ');
        }
        if(fqDate.indexOf('*+TO+') > 0 && fqDate.indexOf(']') > 0) {
          $(".mir-search-options-date .list-group a").append(' <= ');
        }

        //date val
        fqDate = fqDate.replace(/[a-zA-Z.:"+*={}/\]/\[]/g, '');
        $(".mir-search-options-date .list-group a").append(fqDate);
      }
    });

    //date filter option
    $('.mir-search-options-date #dateSearch').click(function() {
        var currentURL = window.location.href;
        var fqDate = '';
        var newURL = currentURL;
        var dateInput = $('.mir-search-options-date .dateContainer :input');
        var date = '';
        //piece together date
        if(!!$(dateInput[2]).val()) {
          date = $(dateInput[2]).val();
          if(!!$(dateInput[1]).val()) {
            date = date + '-' + $(dateInput[1]).val();
            if(!!$(dateInput[0]).val()) {
              date = date + '-' + $(dateInput[0]).val();
            }
          }
        }

        if(date != '') {
          if(currentURL.indexOf('&fq=mods.dateIssued') > 0) {
            fqDate = currentURL.substr(currentURL.indexOf('&fq=mods.dateIssued'));
            fqDate = fqDate.split('&')[1];
            newURL = currentURL.replace('&' + fqDate, '');
          }
          var operator = $('.mir-search-options-date select').val();
          if(operator == '=') {
            newURL = newURL + '&fq=mods.dateIssued%3A"' + date + '"';
          }
          if(operator == '>') {
            newURL = newURL + '&fq=mods.dateIssued%3A{' + date + '+TO+*]';
          }
          if(operator == '>=') {
            newURL = newURL + '&fq=mods.dateIssued%3A[' + date + '+TO+*]';
          }
          if(operator == '<') {
            newURL = newURL + '&fq=mods.dateIssued%3A[*+TO+' + date + '}';
          }
          if(operator == '<=') {
            newURL = newURL + '&fq=mods.dateIssued%3A[*+TO+' + date + ']';
          }
          window.location.href = newURL;
        }
    });

    $('.stopAutoclose').click(function(event) {
      event.stopPropagation()
    });

    //colapse the next element
    $('[data-toggle=collapse-next]').click(function() {
      $(this).next().collapse('toggle');
    });

    // for configuration look here: http://dotdotdot.frebsite.nl/
    if (jQuery.fn.dotdotdot) {

      $(".ellipsis-text").find("a.readmore").click(function() {

        var div = $(this).closest('.ellipsis-text');
        //$("a.readmore", div).hide();
        div.trigger('destroy');
        div.removeClass('ellipsis');
        $("a.readless", div).removeClass('hidden');

        $("a.readless", div).click(function(div) {
          var div = $(this).closest('.ellipsis-text');
          $("a.readmore", div).show();
          div.addClass('ellipsis');
          var readmore=$("a.readmore",div);
          readmore.clone(true,true).insertAfter( readmore );
          readmore.addClass('readmore-active');
          readmore.removeClass('hidden');
          div.dotdotdot({
            ellipsis	: '... ',
            after: "a.readmore-active",
            callback: dotdotdotCallback
          });
          $(this).addClass('hidden');
          return false;
        });

        return false;

      });

      $(".ellipsis").each(function( i ) {

        if (i > 0) $(this).addClass("active");

        var readmore=$("a.readmore",this);
        readmore.clone(true,true).insertAfter( readmore );
        readmore.addClass('readmore-active');
        readmore.removeClass('hidden');
        $(this).dotdotdot({
          ellipsis	: '... ',
          after: "a.readmore-active",
          callback: dotdotdotCallback
        });

        if (i > 0) $(this).removeClass("active");
      });
    };

    $("#mir_relatedItem > li > span").click(function(){
      if( $(this).parent().children("ul").is(":visible") ){
        $(this).parent().children("ul").hide();
        $(this).parent().children("span.glyphicon").removeClass('glyphicon-chevron-down');
        $(this).parent().children("span.glyphicon").addClass('glyphicon-chevron-right');
      } else {
        $(this).parent().children("ul").show();
        $(this).parent().children("span.glyphicon").removeClass('glyphicon-chevron-right');
        $(this).parent().children("span.glyphicon").addClass('glyphicon-chevron-down');
      }
    });


    $("#registerDOI").click(function (event) {
      var doiButton = jQuery(this);
      var mcrId = doiButton.attr("data-mycoreID");
      var baseURL = doiButton.attr("data-baseURL");
      var doiResource = baseURL + "rsc/pi/registration/service/Datacite/" + mcrId;

      $.ajax({
        type: 'POST',
        url: doiResource,
        data: {}
      }).done(function (result) {
        window.location.search="XSL.Status.Message=component.pi.register.doi.success&XSL.Status.Style=success";
      }).fail(function (result) {
        window.location.search="XSL.Status.Message=component.pi.register.doi.error&XSL.Status.Style=danger";
      });
    });

  }); // END $﻿(document).ready()

  function dotdotdotCallback(isTruncated, originalContent) {
    if (!isTruncated) {
      $("a.readmore", this).remove();
      $("a.readless", this).remove();
    }
  };


  window.fireMirSSQuery = function base_fireMirSSQuery(form) {
    $(form).find(':input[value=""]').attr('disabled', true);
    return true;
  };

  $(document).tooltip({
    selector : "[data-toggle=tooltip]",
    container : "body"
  });

})(jQuery);