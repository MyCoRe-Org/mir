/**
 * jQuery Plugin to search Person identifier.
 * 
 * @author René Adler (eagle)
 * @version $Revision$
 * 
 * <pre>
 * Usage:
 * 
 * 	Parameters:
 * 		- toggle 			: always &quot;searchPerson&quot;
 * 		- target 			: the parent container to show result
 * 
 * 		- parentClass 		: the CSS class to set on parent container
 * 		- resultClass 		: the CSS class to set on result container
 * 		- resultShownClass	: the CSS class to show the result container
 * 	
 * 		- searchType
 * 			- GND 			: search through http://lobid.org
 * 			- VIAF			: search through http://www.viaf.org
 * 		- searchInput 		: the input field with search term
 * 		- searchOutput		: the output field for person id, 
 * 								if nothing specified the input field is used
 * 
 * 		- resultEmptyText	: the label if search result was empty
 * 		- loadingText		: the button text on search
 * </pre>
 * 
 * All parameters can be use through jQuery <code>data-</code> tag.
 */
+function($) {
	'use strict';

	var toggle = '[data-toggle="searchPerson"]'

	var SearchPerson = function(element) {
		$(element).on('click.mcr.searchperson', this.search)
	};

	SearchPerson.VERSION = '0.1.0';

	SearchPerson.DEFAULTS = {
		parentClass : "dropdown",
		resultClass : "dropdown-menu",
		resultShownClass : "open",

		searchType : "GND",

		resultEmptyText : "<center><b>Nothing found</b></center>",
		loadingText : "Loading..."
	};

	SearchPerson.prototype.search = function(e) {
		var $this = $(this)
		var options = $.extend({}, SearchPerson.DEFAULTS, $this.data());
		$this.data(options);

		var $parent = getParent($this);
		var isActive = $parent.hasClass(options.resultShownClass);

		clearResults();

		if (!isActive) {
			!$parent.hasClass(options.parentClass) && $parent.addClass(options.parentClass);

			var input = $(options.searchInput).val();
			var isBtn = $this.is("input[type=image]") || $this.is("input[type=button]") || $this.is("input[type=submit]") || $this.is("button")
					|| $this.is("a");

			isBtn && $this.button("loading");
			if (options.searchType.toUpperCase() === "GND") {
				searchGND(input, function(data) {
					if (data !== undefined) {
						showResult($parent, options, data);
					}
					isBtn && $this.button("reset");
				});
			} else if (options.searchType.toUpperCase() === "VIAF") {
				searchVIAF(input, function(data) {
					if (data !== undefined) {
						showResult($parent, options, data);
					}
					isBtn && $this.button("reset");
				});
			} else {
				console.error("Search type \"" + options.searchType.toUpperCase() + "\" is unsupported!");
				isBtn && $this.button("reset");
			}
		}

		return false;
	}

	function searchGND(input, callback) {
		$.ajax({
			url : "http://lobid.org/person",
			timeout : 5000,
			dataType : "jsonp",
			data : {
				name : input,
				format : "ids"
			},
			success : function(data) {
				callback(data);
			},
			error : function() {
				callback();
			}
		});
	}

	function searchVIAF(input, callback) {
		$.ajax({
			url : "http://www.viaf.org/viaf/AutoSuggest",
			timeout : 5000,
			dataType : "jsonp",
			data : {
				query : input,
			},
			success : function(data) {
				if (data.result !== undefined) {
					var result = [];
					$(data.result).each(function(index, item) {
						if (item.nametype.toLowerCase() === "personal") {
							var person = {
								label : item.term,
								value : "http://www.viaf.org/viaf/" + item.viafid + "/"
							};
							result.push(person);
						}
					});

					callback(result);
				} else {
					callback();
				}
			},
			error : function() {
				callback();
			}
		});
	}

	function showResult($parent, options, data) {
		var output = $(options.searchOutput)[0] !== undefined ? $(options.searchOutput) : $(options.searchInput);

		var resultBox = $(document.createElement("ul"));
		resultBox.addClass(options.resultClass);

		if (data.length > 0) {
			$(data).each(function(index, item) {
				var li = $(document.createElement("li"));

				var person = $(document.createElement("a"));
				person.attr("href", "#");
				person.html(item.label);
				person.on("click", function(e) {
					e.preventDefault();
					output.val(item.value);
					clearResults();
				});

				li.append(person);

				resultBox.append(li);
			});
		} else {
			var li = $(document.createElement("li"));
			li.html(options.resultEmptyText);
			resultBox.append(li);
		}

		$parent.append(resultBox);
		$parent.addClass(options.resultShownClass);

		$parent.data($.extend({}, {
			searchResultContainer : resultBox
		}, options));
	}

	function clearResults(e) {
		if (e && e.which === 3)
			return;

		$(toggle).each(function() {
			var $parent = getParent($(this))
			var options = $parent.data();

			if (options !== undefined) {
				var searchResultContainer = $(options.searchResultContainer);
				if (searchResultContainer[0] !== undefined) {
					$parent.removeClass(options.resultShownClass);
					$parent.removeClass(options.parentClass);
					$(options.searchResultContainer).remove();
				}
			}
		});
	}

	function getParent($this) {
		var selector = $this.attr('data-target')

		if (!selector) {
			selector = $this.attr('href')
			selector = selector && /#[A-Za-z]/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, '')
		}

		var $parent = selector && $(selector)

		return $parent && $parent.length ? $parent : $this.parent()
	}

	// SEARCH PERSON PLUGIN DEFINITION
	// ===============================

	function Plugin(option) {
		return this.each(function() {
			var $this = $(this);
			var data = $this.data('mcr.searchperson');

			if (!data)
				$this.data('mcr.searchperson', (data = new SearchPerson(this)));
			if (typeof option == 'string')
				data[option].call($this)
		});
	}

	var old = $.fn.SearchPerson;

	$.fn.searchPerson = Plugin;
	$.fn.searchPerson.Constructor = SearchPerson;

	// SEARCHPERSON NO CONFLICT
	// ========================

	$.fn.searchPerson.noConflict = function() {
		$.fn.SearchPerson = old;
		return this;
	};

	$(document).on('click.mcr.searchperson.data-api', clearResults).on('click.mcr.searchperson.data-api', toggle, SearchPerson.prototype.search);
}(jQuery);
