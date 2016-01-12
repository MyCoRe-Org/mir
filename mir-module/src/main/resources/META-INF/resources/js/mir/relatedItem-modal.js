$(document).ready(function() {
	var GenreXML;

	$(".mir-relatedItem-select").each(function() {
		var button = $(this);
		button.next("span").text(button.next().next("input").val());
		button.click(function() {
			workRelatedItem(button);
		})
	});
	
	function workRelatedItem(button){
		initBody();
		
		var input = button.next().next("input");
		var sortType = "";
		
		//load genre classification
		loadGenres();
		
		if(input.val().length > 0) {
			loadPublikation(leftContent, "", input.val(), "0", "xml");
			setTimeout(function() {
				$("#modalFrame").find(".list-group-item").addClass("active");
			}, 300);
			loadPublikation(rightContent, "receive/" + input.val(), "", "", "html");
			$("#modalFrame-send").removeAttr("disabled");
		}
		
    
		if(!input.val()) {
			loadPublikation(leftContent, "", "", "0", "xml");
		}
		
		function initBody() {
			$("#modalFrame-title").text(button.val());
			$("#modalFrame-cancel").text($("button[name='_xed_submit_cancel']").text());
			$("#modalFrame-send").text("Auswählen").attr("disabled", "").removeAttr("style");
			$("#modalFrame-body").append("<div id='main_left_content' class='list-group col-md-4' />");
			$("#modalFrame-body").append("<div id='main_right_content' class='list-group col-md-8' />");
			$("#main_left_content, #main_right_content").css({"max-height": "560px", "overflow": "auto"});
			$("#main_right_content").css("padding-left", "10px");
			//create pager
			$("#modalFrame-body").after("<nav class='col-md-4' style='clear: both'><ul class='pager'><li id='first' class='previous disabled'><a data='0'>First</a></li><li id='previous' class='previous disabled'><a>Previous</a></li><li class='next disabled'><a>Next</a></li></ul></nav>");
			$("#modalFrame-cancel").before("<div class='col-md-4'><select class='form-control'><option value=''>Sortieren nach Typ:</option></select></div>");
			$("li a").css("cursor", "pointer");
			$("#modal-searchInput").removeAttr("hidden");
			$("#modal-searchInput > input").attr("autocomplete", "off");
			$("#modalFrame").modal("show");
		}
		
		function leftContent(data) {
			$("#main_left_content").empty();
			var mainBody = $(data).find("result[name='response']");
			mainBody.children().each(function() {
				var autorContainer = "";
				var autor = "";
				$(this).find("arr[name='mods.author'] > str").each(function() {
					autor = autor + "; " + $(this).text();
				});
				autor = $.trim(autor.substring(1, autor.length));
				if(autor != "") {
					autorContainer = "<br/><i><small>Autor: " + autor + "</small></i>"
				}
				var type = "<br/><i><small>Type: " + getGenre($(this).find("str[name='mods.type']").text()) + "</small></i>";
				var elm = $("<a class='list-group-item' value='" + $(this).find("str[name='id']").text() + "'>" + $(this).find("str[name='mods.title.main']").text() + autorContainer + type + "</a>");
				$("#main_left_content").append(elm);
				$(elm).css("cursor", "pointer");
				$(elm).attr("data-type", $(this).find("str[name='mods.type']").text());
			});
			
			updatePager(data);
			loadPublikation(updateType,"servlets/solr/select?q=" + $(data).find("str[name='q']").text() + "&XSL.Style=xml","","","xml");
		}
		
		function rightContent(data) {
			$("#main_right_content").empty().append($(data).find("h1[itemprop='name']").css("margin-top", "0"));
			$("h1[itemprop='name']").after($(data).find(".mods_genre").removeAttr("href"));
			$("#main_right_content").append($(data).find("#main_col > .detail_block:first-child")).append($(data).find(".mir_metadata"));
			$("a[itemprop='creator']").removeAttr("href");
		}
		
		function updateType(data) {
			$(".modal-footer select > option[value != '']").remove();
			$(data).find("lst[name='facet_counts'] lst[name='mods.type'] > int").each(function() {
				var type_val = encodeURIComponent('+mods.type:"' + $(this).attr('name') + '"');
				var text = getGenre($(this).attr('name'));
				$(".modal-footer select").append("<option value='" + type_val + "'>" + text + " (" + $(this).text() + ")</option>");
			});
			$(".modal-footer select").val(encodeURIComponent(sortType));
		}
		
		function updatePager(data) {
			var start = $(data).find("str[name='start']").text();
			var rows = $(data).find("str[name='rows']").text();
			var matches = $(data).find("result[name='response']").attr("numFound");
			
			$("#previous, li.next, #first").show();
			$("ul.pager li").removeClass("disabled");
			
			if(parseInt(start) - parseInt(rows) < 0) {
				$("#previous").addClass("disabled");
			}
			$("#previous a").attr("data", parseInt(start) - parseInt(rows));
			
			if((parseInt(start) + parseInt(rows)) > parseInt(matches)) {
				$("li.next").addClass("disabled");
			}
			$("li.next a").attr("data", parseInt(start) + parseInt(rows));
			
			if(parseInt(start) == 0) {
				$("#first").addClass("disabled");
			}
			
			if($("#previous").hasClass("disabled") && $("li.next").hasClass("disabled") && $("#first").hasClass("disabled")) {
				$("#previous, li.next, #first").hide();
			}
		}
		
		$("#modalFrame").on("click", "#main_left_content > .list-group-item", function() {
			if(!$(this).is($(".list-group-item.active"))) {
				$(".list-group-item").removeClass("active");
				loadPublikation(rightContent, "receive/" + $(this).attr("value"), "", "", "html");
				$(this).addClass("active");
				$("#modalFrame-send").removeAttr("disabled");
			}
		});
		
		$("#modalFrame-send").unbind().click(function() {
			input.val($(".list-group-item.active").attr("value"));
			$(button).next("span").text($(".list-group-item.active").attr("value"));
			$("#modalFrame").modal("hide");
		});
		
		$("#modalFrame").on('hidden.bs.modal', function() {
			$("#modalFrame-body").empty();
			$("nav.col-md-4").remove();
			$("#modal-searchInput > input").val("");
			$(".modal-footer div.col-md-4").remove();
		});
		
		$("#modal-searchInput > input").typeahead({
			source: function(query, process) {
				return loadPublikation(function(data){
					var list = [];
					$(data).find("arr[name='mods.title']").each(function() {
						list.push($(this).find("str:first-child").text());
					});
					return process(list);
				}, "" ,query , "0", "xml");
			},
			updater: function(item) {
				$("#main_right_content").empty();
				sortType = "";
				loadPublikation(leftContent, "", item, "0", "xml");
				return item;
			},
			items: 10
		});
		
		$("#modal-searchInput .glyphicon-search").unbind().click(function() {
			searchPublikation();
		});

		$("#modal-searchInput > input").keydown(function(event) {
			if (event.which == 13) {
				event.preventDefault();
				searchPublikation();
			}
		});

		$("#modalFrame li.next a, #modalFrame #previous a, #modalFrame #first a").click(function() {
			if(!$(this).parent().hasClass("disabled")) {
				loadPublikation(leftContent, "", getInputAsQuery(), $(this).attr("data"), "xml");
				$("#main_right_content").empty();
			}
		});
		
		$(".modal-footer select").change(function() {
			sortType = decodeURIComponent($(this).val());
			loadPublikation(leftContent, "",  getInputAsQuery(), "0", "xml");
			$("#main_right_content").empty();
		});

		function searchPublikation() {
			$("#main_right_content").empty();
			sortType = "";
			loadPublikation(leftContent, "", getInputAsQuery(), "0", "xml");
		}
		
		function loadPublikation(callback, href, qry, start, dataType){
			var url = href;
			if(url == "") {
				url = "servlets/solr/select?q=" + qry + "&fq=" + sortType + "&start=" + start + "&rows=10&XSL.Style=xml";
			}
			$.ajax({
				url: webApplicationBaseURL + url,
				type: "GET",
				dataType: dataType,
				success: function(data) {
					callback(data);
				},
				error: function(error) {
					console.log("Failed to load " + webApplicationBaseURL + url);
					console.log(error);
				}
			});
		}

		function getInputAsQuery() {
			var query = $("#modal-searchInput > input").val();
			if (query == "") {
				query = "*";
			}
			return query;
		}

		function loadGenres() {
			if (!webApplicationBaseURL) console.log("Error: webApplicationBaseURL not set");
			$.ajax({
				method: "GET",
				url: webApplicationBaseURL + "api/v1/classifications/mir_genres",
				dataType: "xml"
			}) .done(function( xml ) {
				GenreXML=xml;
			});
		}

		function getGenre(genreID) {
			var cat = $(GenreXML).find('category[ID="' + genreID + '"]');
			var lang = $(cat).find("label").filter(function() {
				return $(this).attr('xml:lang') == $("html.no-js").attr("lang");
			});
			if (lang == undefined || lang == "") {
				lang = $(cat).find("label").filter(function() {
					return $(this).attr('xml:lang') == "de";
				});
			}
			return $(lang).attr("text");
		}
	}
});