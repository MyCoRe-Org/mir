var engines = {
	shelfmark : {
		engine : new Bloodhound({
			// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
			datumTokenizer : Bloodhound.tokenizers.obj.whitespace('mods.title[0]'),
			queryTokenizer : Bloodhound.tokenizers.whitespace,
			remote : {
				url : webApplicationBaseURL + 'servlets/solr/select?%QUERY',
				wildcard : '%QUERY',
				transform : function(list) {
					list = list.response.docs;
					$.each(list, function(index, item) {
						item.name = item['shelfLocator'] + ' - ' + item['mods.title'][0];
						item.value = item['shelfLocator'];
					});
					return list;
				},
				prepare : function(query, settings) {
					var param = "q=%2Bmods.title%3A*" + query + "*";
					param += "+%2Bcategory.top%3A%22mir_genres\%3A" + $(document.activeElement).data("genre") + "%22";
					param += "+%2BobjectType%3A%22mods%22";
					param += "&fl=mods.title%2Cid%2Cidentifier.type.isbn%2CshelfLocator";
					param += "&version=4.5&rows=1000&wt=json";

					settings.url = settings.url.replace("%QUERY", param);
					return settings;
				}
			}
		}),
	},
	isbn : {
		engine : new Bloodhound({
			// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
			datumTokenizer : Bloodhound.tokenizers.obj.whitespace('mods.title[0]'),
			queryTokenizer : Bloodhound.tokenizers.whitespace,
			remote : {
				url : webApplicationBaseURL + 'servlets/solr/select?%QUERY',
				wildcard : '%QUERY',
				transform : function(list) {
					list = list.response.docs;
					$.each(list, function(index, item) {
						item.name = item['identifier.type.isbn'] + ' - ' + item['mods.title'][0];
						item.value = item['identifier.type.isbn'];
					});
					return list;
				},
				prepare : function(query, settings) {
					var param = "q=%2Bmods.title%3A*" + query + "*";
					param += "+%2Bcategory.top%3A%22mir_genres\%3A" + $(document.activeElement).data("genre") + "%22";
					param += "+%2BobjectType%3A%22mods%22";
					param += "&fl=mods.title%2Cid%2Cidentifier.type.isbn%2CshelfLocator";
					param += "&version=4.5&rows=1000&wt=json";

					settings.url = settings.url.replace("%QUERY", param);
					return settings;
				}
			}
		}),
	},
	issn : {
		engine : new Bloodhound({
			// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
			datumTokenizer : Bloodhound.tokenizers.obj.whitespace('mods.title[0]'),
			queryTokenizer : Bloodhound.tokenizers.whitespace,
			remote : {
				url : webApplicationBaseURL + 'servlets/solr/select?%QUERY',
				wildcard : '%QUERY',
				transform : function(list) {
					list = list.response.docs;
					$.each(list, function(index, item) {
						item.name = item['identifier.type.issn'] + ' - ' + item['mods.title'][0];
						item.value = item['identifier.type.issn'];
					});
					return list;
				},
				prepare : function(query, settings) {
					var param = "q=%2Bmods.title%3A*" + query + "*";
					param += "+%2Bcategory.top%3A%22mir_genres\%3A" + $(document.activeElement).data("genre") + "%22";
					param += "+%2BobjectType%3A%22mods%22";
					param += "&fl=mods.title%2Cid%2Cidentifier.type.issn";
					param += "&version=4.5&rows=1000&wt=json";

					settings.url = settings.url.replace("%QUERY", param);
					return settings;
				}
			}
		}),
	},
	title : {
		engine : new Bloodhound({
			// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
			datumTokenizer : Bloodhound.tokenizers.obj.whitespace('mods.title[0]'),
			queryTokenizer : Bloodhound.tokenizers.whitespace,
			remote : {
				url : webApplicationBaseURL + 'servlets/solr/select?%QUERY',
				wildcard : '%QUERY',
				transform : function(list) {
					list = list.response.docs;
					$.each(list, function(index, item) {
						item.name = item['mods.title'][0];
						item.value = item['mods.title'][0];
					});
					return list;
				},
				prepare : function(query, settings) {
					var param = "q=%2Bmods.title%3A*" + query + "*";
					param += "+%2Bcategory.top%3A%22mir_genres\%3A" + $(document.activeElement).data("genre") + "%22";
					param += "+%2BobjectType%3A%22mods%22";
					param += "&fl=mods.title%2Cid%2Cidentifier.type.issn%2Cidentifier.type.isbn%2CshelfLocator";
					param += "&version=4.5&rows=1000&wt=json";

					settings.url = settings.url.replace("%QUERY", param);
					return settings;
				}
			}
		}),
	},
	empty : {
		engine : new Bloodhound(
				{
					// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
					datumTokenizer : Bloodhound.tokenizers.obj.whitespace('mods.title[0]'),
					queryTokenizer : Bloodhound.tokenizers.whitespace,
					remote : {
						url : webApplicationBaseURL
								+ 'servlets/solr/select?&q=%2Bmods.title%3A*%QUERY*+%2Bcategory.top%3A%22mir_genres\%3Aseries%22+%2BobjectType%3A%22mods%22&version=4.5&rows=1000&fl=mods.title%2Cid%2Cmods.identifier&wt=json',
						transform : function(list) {
							return {};
						}
					}
				}),
		displayText : function(item) {
			return item;
		}
	}
};

$(document).ready(function() {

	$("input[data-provide='typeahead']").each(function(index, input) {
		var Engine;
		if (engines[$(this).data("searchengine")]) {
			Engine = engines[$(this).data("searchengine")];
		} else {
			Engine = engines["empty"];
		}
		Engine.engine.initialize();
		$(this).typeahead({
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
			},
			afterSelect : function(current) {
				fieldset = $(document.activeElement).closest("fieldset.mir-relatedItem");
				relatedItemBody = fieldset.children('div.mir-relatedItem-body');
				relatedItemBody.find("input[id^='relItem']").val(current.id);
				disableFieldset(fieldset);
				fillFieldset(fieldset, current.id);
				createbadge($(document.activeElement).closest("div"), current.id);

			}
		});

	});

	$("input[id^='relItem']").each(function(index, input) {
		if (input.value != "mir_mods_00000000") {
			fieldset = $(input).closest("fieldset.mir-relatedItem");
			disableFieldset(fieldset);
			fillFieldset(fieldset, input.value);
			createbadge($(fieldset.find("div.input-group")[0]), input.value);
		}
	});

});

function disableFieldset(fieldset) {
	relatedItemBody = fieldset.children('div.mir-relatedItem-body');
	relatedItemBody.find("div.form-group:not(.mir-modspart)").find("input[type!='hidden']").each(function(index, input) {
		if (input != document.activeElement) {
			$(input).prop('disabled', true);
			$(input).data('value', $(input).val());
		}
	});
	$(".searchbadge").addClass("disabled");

	fieldset.find("fieldset.mir-relatedItem").prop('disabled', true);
};

function fillFieldset(fieldset, relItemid) {
	$.ajax({
		method : "GET",
		url : webApplicationBaseURL + "receive/" + relItemid + "?XSL.Style=xml",
		dataType : "xml"
	}).done(function(xml) {
		fieldset.find('input').each(function(index, input) {
			path = input.name.substr(input.name.indexOf("relatedItem/") + 12);
			path = "/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/" + path;
			function nsResolver(prefix) {
				var ns = {
					'mods' : 'http://www.loc.gov/mods/v3',
					'xlink' : 'http://www.w3.org/1999/xlink',
				};
				return ns[prefix] || null;
			}
			xPathRes = xml.evaluate(path, xml, nsResolver, XPathResult.ANY_TYPE, null)
			node = xPathRes.iterateNext();
			if (node) {
				input.value = $(node).text();
			}
		});
		// alert(xml);

	});
};

function createbadge(inputgroup, relItemid) {
	badge = '<a href="../receive/' + relItemid + '" target="_blank" class="badge"> ';
	badge += 'intern ';
	badge += '<span class="glyphicon glyphicon-remove-circle relItem-reset"> </span>';
	badge += '</a>';

	inputgroup.find(".searchbadge").html(badge);

	inputgroup.find(".relItem-reset").click(function(event) {
		event.preventDefault();
		relatedItemBody = $(this).closest("fieldset.mir-relatedItem").children('div.mir-relatedItem-body');
		relatedItemBody.find("div.form-group:not(.mir-modspart)").find("input[type!='hidden']").each(function(index, input) {
			$(input).prop('disabled', false);
			$(input).val($(input).data('value'));
		});
		$('.searchbadge').removeClass("disabled");
		relatedItemBody.find("input[id^='relItem']").val("mir_mods_00000000");
		$(document.activeElement).closest("fieldset.mir-relatedItem").find("fieldset.mir-relatedItem").prop('disabled', false);
		inputgroup = $(this).closest("div");
		inputgroup.find(".searchbadge").html("");
	});
};
