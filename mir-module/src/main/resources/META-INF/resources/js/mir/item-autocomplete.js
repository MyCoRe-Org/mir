var enginesItem = {
	conference : {
		engine : new Bloodhound({
			datumTokenizer : Bloodhound.tokenizers.whitespace,
			queryTokenizer : Bloodhound.tokenizers.whitespace,
			remote : {
				url : webApplicationBaseURL + 'servlets/solr/select?%QUERY',
				wildcard : '%QUERY',
				transform : function(list) {
					list = list.response.docs;
					options = [];
					$.each(list, function(index, item) {
						options[item['mods.name.conference'][0]] = true;
					});
					return Object.keys(options);
				},
				prepare : function(query, settings) {
					var param = "q=%2Bmods.name.conference%3A*" + query + "*";
					param += "+%2BobjectType%3A%22mods%22";
					param += "&fl=mods.name.conference";
					param += "&version=4.5&rows=4&wt=json";

					settings.url = settings.url.replace("%QUERY", param);
					return settings;
				}
			}
		})
	}
};

$(document).ready(function() {

	$("input[data-provide='typeahead'].itemsearch").each(function(index, input) {
		var responsefield = $(this).data("responsefield");
		if (responsefield != "" && responsefield != undefined) {
			testForResponsefield(responsefield, $(this));
		}
	});

	function testForResponsefield(responsefield, currentElm) {
		$.ajax({
			url: webApplicationBaseURL + 'servlets/solr/select?q=%2B' + responsefield + '%3A*&wt=json',
			dataType: 'json',
			type: "GET",
			statusCode: {
				200: function (search) {
					if(search.response.numFound > 0) {
						addTypeahead(currentElm);
					}
				}
			}
		});
	}

	function addTypeahead(currentElm) {
		if (enginesItem[$(currentElm).data("searchengine")]) {
			var Engine = enginesItem[$(currentElm).data("searchengine")];
			Engine.engine.initialize();
			$(currentElm).typeahead({
				items : 4,
				source : function(query, callback) {
					// rewrite source function to work with newer typeahead version
					// @see (withAsync(query, sync, async))
					var func = Engine.engine.ttAdapter();
					return $.isFunction(func) ? func(query, callback, callback) : func;
				},
				updater : function(current) {
					current.name = current.value;
					return (current);
				}
			});
		}
	}
});
