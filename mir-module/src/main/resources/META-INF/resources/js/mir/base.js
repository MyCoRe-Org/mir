(function($) {
  $(document).ready(function() {
  	
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

})(jQuery);