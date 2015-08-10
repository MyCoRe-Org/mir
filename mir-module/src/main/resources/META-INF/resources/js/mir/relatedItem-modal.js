$﻿(".mir-relatedItem-select").ready(function() {
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
		if(input.val().length > 0) {
			console.log("next input");
			loadPublikation(leftContent, "", input.val(), "0");
			setTimeout(function() {
				$("#modalFrame").find(".list-group-item").addClass("active");
			}, 300);
			loadPublikation(rightContent, "receive/" + input.val(), "", "");
			$("#modalFrame-send").removeAttr("disabled");
		}
		
		if(!input.val()) {
			console.log("normal load");
			loadPublikation(leftContent, "", "", "0");
		}
		
		function initBody() {
			$("#modalFrame-title").text(button.val());
			$("#modalFrame-cancel").text($("button[name='_xed_submit_cancel']").text());
			$("#modalFrame-send").text("Auswählen").attr("disabled", "").removeAttr("style");
			$("#modalFrame-body").append("<div id='main_left_content' class='list-group col-md-4' />");
			$("#modalFrame-body").append("<div id='main_right_content' class='list-group col-md-8' />");
			$("#main_left_content, #main_right_content").css({"max-height": "560px", "overflow": "auto"});
			//create pager
			$("#modalFrame-body").after("<nav class='col-md-4' style='clear: both'><ul class='pager'><li id='first' class='previous disabled'><a data='0'>First</a></li><li id='previous' class='previous disabled'><a>Previous</a></li><li class='next disabled'><a>Next</a></li></ul></nav>");
			$("li a").css("cursor", "pointer");
			$("#modal-searchInput").removeAttr("hidden");
			$("#modalFrame").modal("show");
		}
		
		function leftContent(data) {
			$("#main_left_content").empty();
			var mainBody = $(data).find("arr[name='groups']");
			mainBody.children().each(function() {
				var autorContainer = "";
				var autor = "";
				console.log($(this).find("arr[name='mods.author'] > str").text());
				$(this).find("arr[name='mods.author'] > str").each(function() {
					autor = autor + "; " + $(this).text();
				});
				autor = $.trim(autor.substring(1, autor.length));
				console.log("Autor = " + autor);
				if(autor != "") {
					autorContainer = "<br/><i><small>Autor: " + autor + "</small></i>"
				}
				$("#main_left_content").append("<a class='list-group-item' value='" + $(this).find("str[name='groupValue']").text() + "'>" + $(this).find("str[name='mods.title.main']").text() + autorContainer + "</a>").css("cursor", "pointer");
			});
			
			updatePager(data);
		}
		
		function rightContent(data) {
			$("#main_right_content").empty().append($(data).find("h1[itemprop='name']").css("margin-top", "0"));
			$("h1[itemprop='name'").after($(data).find(".mods_genre").removeAttr("href"));
			$("#main_right_content").append($(data).find("#main_col").removeClass("col-md-8"));
			$("a[itemprop='creator']").removeAttr("href");
		}
		
		function updatePager(data) {
			var start = $(data).find("str[name='start']").text();
			var rows = $(data).find("str[name='rows']").text();
			var matches = $(data).find("int[name='matches']").text();
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
				loadPublikation(rightContent, "receive/" + $(this).attr("value"), "", "");
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
		});
		
		$("#modal-searchInput > input").unbind().keyup(function(event) {
			if(event.keyCode == '13') {
				loadPublikation(leftContent, "", $(this).val(), "0");
				$("#main_right_content").empty();
			}
		});
		
		$(".glyphicon-search").unbind().click(function() {
			$("#main_right_content").empty();
			loadPublikation(leftContent, "", $("#modal-searchInput > input").val(), "0");
		});
		
		$("li.next a, #previous a, #first a").click(function() {
			if(!$(this).parent().hasClass("disabled")) {
				loadPublikation(leftContent, "", $("#modal-searchInput > input").val(), $(this).attr("data"));
				$("#main_right_content").empty();
			}
		});
		
		function loadPublikation(callback, href, qry, start){
			var url = href;
			if(url == "") {
				url = "servlets/solr/find?qry=" + qry + "&start=" + start + "&rows=10&XSL.Style=xml";
			}
			$.ajax({
				url: webApplicationBaseURL + url,
				type: "GET",
				dataType: "html",
				success: function(data) {
					callback(data);
				},
				error: function(error) {
					console.log("Failed to load " + webApplicationBaseURL + url);
					console.log(error);
				}
			});
		};
	}
});