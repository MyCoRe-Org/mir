
var GenreXML;
let lang = window["currentLang"]

function resolveTranslation(callback) {
	let requestUrl = window["webApplicationBaseURL"] + "rsc/locale/translate/mir.select.optional";
	$.ajax({
		url: requestUrl
	}).done(function(text, result) {
		if(result==="success"){
			callback(text);
		}
	});
}

function changeHostOptions(){
	var id = $( '#genre option:selected' )[0].value;
	var host = $($(GenreXML).find('[ID="'+id+'"]')[0]).children('label[xml\\:lang="x-hosts"]').attr('text');
	$('#host').empty();
	$('#host').parent().parent().show();
	if(!(typeof host === 'undefined')) {
		var hosts = host.split(' ');
		$.each(hosts,function (ind,val) {
			if (val=='standalone') {
				$('#host').prepend('<option value="standalone" selected="selected" ></option>');
				resolveTranslation(function (result) {
					$('#host').children("option[value='standalone']").text(result);
				});
			} else {
				text = $($(GenreXML).find('[ID="'+val+'"]')[0]).children('label[xml\\:lang='+lang+']').attr('text');
				$('#host').append('<option value="'+val+'">'+text+'</option>');
			}
		});
		if(hosts.length == '1' && hosts[0] == 'standalone') {
			$('#host').parent().parent().hide();
		}
	} else {
		$('#host').parent().parent().hide();
	}
}

function createGenreOption(category,level) {
    if (level > 8) {return ("");}
    var Option="";
    var Title = category.children('label[xml\\:lang="'+lang+'"]').attr('text');
    var xEditorGroup = category.children('label[xml\\:lang="x-group"]').attr('text');
    var xEditorDisable = category.children('label[xml\\:lang="x-disable"]').attr('text');
    var id = category.attr('ID');
    var space = "";
    var space2 = "";
	for (var i = 0; i < level; i++) {
        space+="&nbsp;&nbsp;&nbsp;";
        space2+="   ";
	}
	if (xEditorGroup == "true" && category.find('category').length > 0) {
        Option+='<optgroup label="'+ space2 +Title+'"></optgroup>';
    } else {
		if (xEditorDisable == "true") {
			Option+='<option value="'+id+'" disabled>' + space + Title + '</option>';
		} else {
			Option+='<option value="'+id+'">' + space + Title + '</option>';
		}
	}
	category.children('category').each(function(){
		Option+=createGenreOption($(this),level+1);
	});
	return Option;
}

function createGenreOptions() {
    var Options="";
  	$(GenreXML).find('categories > category').each(function(){
        Options+=createGenreOption($(this),1);
	});
	$('#genre').append(Options);
}

function toggleMoreOptions( duration ) {
    if ( $('#more_options_box').is(':visible') ) {
        $('#more_options_box').fadeOut( duration );
        $('#more_options_label, #more_options_label_hide').toggleClass("d-none");
        $('#more_options_button').removeClass('fas fa-chevron-down').addClass('fas fa-chevron-up');
        localStorage.setItem("moreOptions", "closed");
    } else {
        $('#more_options_box').fadeIn( duration );
        $('#more_options_label, #more_options_label_hide').toggleClass("d-none");

        $('#more_options_button').removeClass('fas fa-chevron-up').addClass('fas fa-chevron-down');
        localStorage.setItem("moreOptions", "opened");
    }
}

$(document).ready( function() {
    if (!webApplicationBaseURL) console.log("Error: webApplicationBaseURL not set");
    $('#genre').change(function (){changeHostOptions();});
	$.ajax({
		method: "GET",
		url: webApplicationBaseURL+"api/v1/classifications/mir_genres",
		dataType: "xml"
	}) .done(function( xml ) {
		GenreXML=xml;
		createGenreOptions();
		changeHostOptions();
	});

	// load option view from history
	if ( typeof(Storage) !== "undefined" ) {
		switch ( localStorage.getItem("moreOptions") ) {
			case 'opened':
				if ( !$('#more_options_box').is(":visible") ) {
					toggleMoreOptions(0);
				}
				break;
			case 'closed':
				if ( $('#more_options_box').is(":visible") ) {
					toggleMoreOptions(0);
				}
				break;
			case null:
				if ( $('#more_options_box').is(":visible") ) {
					localStorage.setItem("moreOptions", "opened");
				} else {
					localStorage.setItem("moreOptions", "closed");
				}
				break;
			default:
		}
	}

	$('#more_options_trigger').click(function(){
		toggleMoreOptions(500);
	});

});
