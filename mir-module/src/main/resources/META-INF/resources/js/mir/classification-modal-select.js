$﻿(document).ready(function() {
	$(".mir-classification-select").each(function() {
		var button = $(this);

		if(!!button.next().val()) {
  		var label = button.next().val();
			var classi = button.next().next().val();
			if(classi != "" && label != "") {
				button.parent().find("span").empty();
				button.parent().find("span").append(label);
			}
		}

		button.click(function() {
			work(button);
		})
	});

	function work(button){
		initBody();
		loadClassifications(leftContent, "");

		function leftContent(data) {
			var mainBody = $(data).find("#main_content");
			mainBody.filter("#main_content").addClass("list-group");
			mainBody.filter("#main_content").attr("id", "main_left_content").attr("style" , "max-height: 560px; overflow: auto");
			$("#modalFrame-body").html(mainBody);

			$("#main_left_content > a").each(function() {
				var href = $(this).attr("href");
				$(this).attr("data-href", href).attr("style", "cursor: pointer");
				$(this).removeAttr("href");

				$(this).click(function() {
					$(".list-group-item").removeClass("active");
					$(this).addClass("active");
					loadClassifications(rightContent, $(this).attr("data-href"));
				});
			});

			setTimeout(function() {
				if(!!button.next().val() && button.next().next().val().indexOf(":") > 0) {
					var classi = button.next().next().val().split(':')[0];
					$("a[data-href*='" + classi + "']").addClass("active");
					loadClassifications(rightContent, $("a.active").attr("data-href"));
				}
			}, 300);
        }
        function rightContent(data) {
			$("#modalFrame-body > #main_right_content").remove();
			var mainBody = $(data).find("#main_content");
			mainBody.filter("#main_content").attr("id", "main_right_content").addClass("col-md-6 mir-form-group").attr("style" , "max-height: 560px; overflow: auto");
			mainBody.find(".classificationBrowser").removeAttr("class");
			if(!$("#main_left_content").hasClass("col-md-6")) {
				$("#main_left_content").addClass("col-md-6");
			}
			$("#modalFrame-body").append(mainBody);

			setTimeout(function() {
				removeHrefCbList();
			}, 300);
        }
        function removeHrefCbList() {
			$("#main_right_content .cbList > li > a").each(function() {
				if($(this).attr("href") != "#" && !!$(this).attr("href")) {
					var href = decodeURIComponent($(this).attr("href"));
					var classi = href.substr(href.indexOf("@name=") + 6);
					classi = classi.split("&")[0];
					var label = href.substr(href.indexOf("@text=") + 6);
					label = label.replace(/\+/g, " ");
					$(this).removeAttr("href").attr("style", "cursor: pointer");
					//fix when you only get categID without classification ID (like mcr-roles)
					if(!(classi.indexOf(":") > 0)) {
						var classiHref = $("a.list-group-item.active").attr("data-href");
						classiHref = classiHref.substr(classiHref.indexOf("categID=") + 8);
						classi = classiHref.split("&")[0] + ":" + classi;
					}

					$(this).click(function() {
						button.next().val(label);
						button.next().next().val(classi);
						$("#modalFrame").modal("hide");
						displayComplett();
					});
				}

				if($(this).attr("href") == "#") {
					$(this).removeAttr("href").attr("style", "cursor: pointer");
					$(this).click(function() {
						setTimeout(function() {
							removeHrefCbList();
						}, 300);
					});
				}
			});
        }
        function displayComplett() {
			var label = button.next().val();
			var classi = button.next().next().val();
			if(classi != "" && label != "") {
				button.parent().find("span").empty();
				button.parent().find("span").append(label);
			}
		}

		$("#modalFrame").on('hidden.bs.modal', function() {
			$("#modalFrame-body").empty();
		});

		function initBody() {
			$("#modalFrame-title").text(button.val());
			$("#modalFrame-cancel").text($("button[name='_xed_submit_cancel']").text());
			$("#modalFrame-send").hide();
			$("#modalFrame").modal("show");
        }
        function loadClassifications(callback, href){
			var url = href;
			if(url == "") {
				var session = $("input[name='_xed_session']").val();
				url = webApplicationBaseURL + "servlets/MIRClassificationServlet?_xed_subselect_session=" + session;
			}
			$.ajax({
				url: url,
				type: "GET",
				dataType: "html",
				success: function(data) {
					callback(data);
				},
				error: function(error) {
					alert(error);
				}
			});
        }
    }
});
