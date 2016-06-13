  
var GenreXML;

function changeHostOptions(){
	var id = $( '#genre option:selected' )[0].value;
	var host = $($(GenreXML).find('[ID="'+id+'"]')[0]).children('label[xml\\:lang="x-hosts"]').attr('text');
	$('#host').empty();
	$('#host').parent().parent().show();
	if(!(typeof host === 'undefined')) {
		var hosts = host.split(' ');
		$.each(hosts,function (ind,val) {
			if (val=='standalone') {
				$('#host').prepend('<option value="standalone" selected="selected" >(bitte ggf. auswählen)</option>');
			} else {
				text = $($(GenreXML).find('[ID="'+val+'"]')[0]).children('label[xml\\:lang="de"]').attr('text');
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


        
function createGenreOptions() {
	var Options="";
  	$(GenreXML).find('categories > category').each(function(){
		var Title = $(this).children('label[xml\\:lang="de"]').attr('text');
		var xEditorGroup = $(this).children('label[xml\\:lang="x-group"]').attr('text');
		var xEditorDisable = $(this).children('label[xml\\:lang="x-disable"]').attr('text');
		var id = $(this).attr('ID');
		if (xEditorGroup == "true") {
			if ($(this).find('category').length > 0) {
				Options+='<optgroup label="'+Title+'"></optgroup>';
			}
		}
		else {
			if (xEditorDisable == "true") {
				Options+='<option value="'+id+'" disabled>' + Title + '</option>';
			}
			else {
				Options+='<option value="'+id+'">' + Title + '</option>';
			}
		}
		$(this).find('category').each(function(){
	  		var Title = $(this).children('label[xml\\:lang="de"]').attr('text');
			var disable = $(this).children('label[xml\\:lang="x-disable"]').attr('text');
	  		var id = $(this).attr('ID');
			if (disable == "true") {
				Options+='<option value="'+id+'" disabled>&nbsp;&nbsp;&nbsp;' + Title + '</option>';
			}
			else {
				Options+='<option value="'+id+'">&nbsp;&nbsp;&nbsp;' + Title + '</option>';
			}
	  	});
	});
	$('#genre').append(Options);
}

function toggleMoreOptions( duration ) {
	if ( $('#more_options_box').is(':visible') ) {
		$('#more_options_box').fadeOut( duration );
		$('#more_options_label').html('weitere Optionen einblenden');
		$('#more_options_button').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
		localStorage.setItem("moreOptions", "closed");
	} else {
		$('#more_options_box').fadeIn( duration );
		$('#more_options_label').html('weitere Optionen ausblenden');
		$('#more_options_button').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
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
