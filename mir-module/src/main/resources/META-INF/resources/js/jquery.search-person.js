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
 * 		- target 				: the target container
 * 		- search 				: always &quot;searchPerson&quot;
 *  	
 * 		- searchType
 * 			- SELECT			: add searchType selection menu
 * 			- GND 				: search through http://lobid.org
 * 			- VIAF				: search through http://www.viaf.org
 * 		- searchOutput			: the output field for person id (URI), 
 * 								  if nothing specified the input field is used
 * 
 * 		- searchResultEmpty		: the label if search result was empty
 * 		- searchButtonLoading	: the button text on search
 * </pre>
 * 
 * All parameters can be also set with jQuery <code>data-</code> attributes.
 */
+function($) {
	'use strict';

	var toggle = '[data-search="searchPerson"]'

	var SearchPerson = function(element, options) {
		this.options = $.extend({}, SearchPerson.DEFAULTS, options);

		this.$parent = null;
		this.$element = $(element);
		this.$inputGroup = null;
		this.$searchBtn = null;
		this.$typeBtn = null;
		this.$typeMenu = null;

		this.selectedType = SearchPerson.DEFAULTS.searchType;

		this.init();
	};

	SearchPerson.VERSION = '1.0.0';

	SearchPerson.TYPES = [ "GND", "VIAF" ];

	SearchPerson.DEFAULTS = {
		// Button Style
		buttonClass : "btn btn-default",

		// min length of search term
		inputMinLength : 3,

		// default search type
		searchType : "GND",

		// TEXT DEFINITIONS
		// ===============================
		// default button loading text
		searchButtonLoading : "Loading...",
		searchResultEmpty : "<center><b>Nothing found</b></center>"
	};

	SearchPerson.prototype.init = function() {
		if (typeof $.fn.dropdown !== "function" && typeof $.fn.button !== "function") {
			console.error("Couldn't initalize SearchPerson because of missing Bootstrap \"dropdown\" and \"button\" plugin!");
			return;
		}

		var that = this;
		var options = this.options;

		var $parent = this.$parent = $(document.createElement("div"));

		var $inputGroup = this.$inputGroup = $(document.createElement("div"));
		$inputGroup.addClass("input-group");

		var $element = this.$element.clone();
		$inputGroup.append($element);

		this.$element.before($parent);
		this.$element.remove();
		this.$element = $element;

		var $actions = $(document.createElement("div"));
		$actions.addClass("input-group-btn");

		var $searchBtn = this.$searchBtn = $(document.createElement("button"));
		$searchBtn.addClass(options.buttonClass);
		$searchBtn.attr("data-loading-text", options.searchButtonLoading);
		$searchBtn.html("Suchen");

		$searchBtn.on("click", function(e) {
			e.preventDefault();
			that.search(e);
		});

		$actions.append($searchBtn);

		if (options.searchType.toUpperCase() == "SELECT") {
			var $typeBtn = this.$typeBtn = $(document.createElement("button"));
			$typeBtn.addClass(options.buttonClass).addClass("dropdown-toggle");
			$typeBtn.attr("data-toggle", "dropdown");
			$typeBtn.html("<span class=\"caret\"></span><span class=\"sr-only\">Toggle Dropdown</span>");

			$actions.append($typeBtn);

			var $typeMenu = this.$typeMenu = $(document.createElement("ul"));
			$typeMenu.addClass("dropdown-menu dropdown-menu-right");
			$typeMenu.attr("role", "menu");

			for ( var index in SearchPerson.TYPES) {
				var $entry = $(document.createElement("li"));
				var $ea = $(document.createElement("a"));
				$ea.attr("href", "#");
				$ea.data("search-type", SearchPerson.TYPES[index]);
				$ea.text(SearchPerson.TYPES[index]);

				$ea.on("click", function(e) {
					that.selectedType = $(this).data("search-type");
				});

				$entry.append($ea);
				$typeMenu.append($entry);
			}

			$actions.append($typeMenu);
			$typeBtn.dropdown();
		}

		$inputGroup.append($actions);
		$parent.append($inputGroup);
	}

	SearchPerson.prototype.search = function(e) {
		var that = this;
		var $parent = this.$parent;
		var options = this.options;

		var isActive = $parent.hasClass("open");

		this.clearAll();

		if (!isActive) {
			!$parent.hasClass("dropdown") && $parent.addClass("dropdown");

			var input = this.$element.val();

			if (input.length < options.inputMinLength)
				return;

			this.$searchBtn.button("loading");
			if (this.selectedType.toUpperCase() === "GND") {
				SearchPerson.searchGND(input, function(data) {
					if (data !== undefined) {
						that.showResult(data);
					}
					that.$searchBtn.button("reset");
				});
			} else if (this.selectedType.toUpperCase() === "VIAF") {
				SearchPerson.searchVIAF(input, function(data) {
					if (data !== undefined) {
						that.showResult(data);
					}
					that.$searchBtn.button("reset");
				});
			} else {
				console.error("Search type \"" + this.selectedType.toUpperCase() + "\" is unsupported!");
				this.$searchBtn.button("reset");
			}
		}

		return false;
	}

	SearchPerson.prototype.showResult = function(data) {
		var that = this;
		var $parent = this.$parent;
		var options = this.options;

		var $output = $(options.searchOutput, getParent(this.$element))[0] !== undefined ? $(options.searchOutput, getParent(this.$element)) : this.$element;

		var $resultBox = $(document.createElement("ul"));
		$resultBox.attr("role", "menu");
		$resultBox.addClass("dropdown-menu");

		if (data.length > 0) {
			$(data).each(function(index, item) {
				var $li = $(document.createElement("li"));

				var $person = $(document.createElement("a"));
				$person.attr("href", "#");
				$person.html(item.label);
				$person.on("click", function(e) {
					$output.val(item.value);
					that.clearAll();
				});

				$li.append($person);

				$resultBox.append($li);
			});
		} else {
			var $li = $(document.createElement("li"));
			$li.html(options.searchResultEmpty);
			$resultBox.append($li);
		}

		$parent.append($resultBox);
		$resultBox.dropdown("toggle");

		this.$element.data($.extend({}, {
			searchResultContainer : $resultBox
		}, options));
	}

	SearchPerson.prototype.clearAll = function(e) {
		if (e && e.which === 3)
			return;

		$(toggle).each(function() {
			var $this = $(this);
			var options = typeof this.options == 'object' ? this.options : $.extend({}, SearchPerson.DEFAULTS, $this.data());

			var $parent = this.$parent === undefined ? getParent($this) : this.$parent;

			$("." + "dropdown-toggle", $parent).each(function(e) {
				$(this).dropdown();
			});

			var $searchResultContainer = $(options.searchResultContainer);
			if ($searchResultContainer[0] !== undefined) {
				$searchResultContainer.parent().removeClass("open");
				$searchResultContainer.remove();
				$this.removeData("searchResultContainer");
			}
		});
	}

	SearchPerson.searchGND = function(input, callback) {
		$.ajax({
			url : "http://lobid.org/person",
			timeout : 5000,
			dataType : "jsonp",
			data : {
				name : input,
				format : "ids"
			},
			success : function(data) {
				callback(SearchPerson.sortData(input, data));
			},
			error : function() {
				callback();
			}
		});
	}

	SearchPerson.searchVIAF = function(input, callback) {
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
								value : "http://www.viaf.org/viaf/" + item.viafid
							};
							result.push(person);
						}
					});

					callback(SearchPerson.sortData(input, result));
				} else {
					callback();
				}
			},
			error : function() {
				callback();
			}
		});
	}

	SearchPerson.sortData = function(input, data) {
		// TheSpanishInquisition - http://jsperf.com/levenshtein-distance/5
		// Functional implementation of Levenshtein Distance.
		function levenshteinDistance(strA, strB, limit) {
			var strALength = strA.length, strBLength = strB.length;

			if (Math.abs(strALength - strBLength) > (limit || 32))
				return limit || 32;
			if (strALength === 0)
				return strBLength;
			if (strBLength === 0)
				return strALength;

			var matrix = [];
			for (var i = 0; i < 64; i++) {
				matrix[i] = [ i ];
				matrix[i].length = 64;
			}
			for (var i = 0; i < 64; i++) {
				matrix[0][i] = i;
			}

			var strA_i, strB_j, cost, min, t;
			for (var i = 1; i <= strALength; ++i) {
				strA_i = strA[i - 1];

				for (var j = 1; j <= strBLength; ++j) {
					if (i === j && matrix[i][j] > 4)
						return strALength;

					strB_j = strB[j - 1];
					cost = (strA_i === strB_j) ? 0 : 1;
					min = matrix[i - 1][j] + 1;
					if ((t = matrix[i][j - 1] + 1) < min)
						min = t;
					if ((t = matrix[i - 1][j - 1] + cost) < min)
						min = t;

					matrix[i][j] = min;
				}
			}

			return matrix[strALength][strBLength];
		}

		return data.sort(function(a, b) {
			return levenshteinDistance(input, a.label) - levenshteinDistance(input, b.label);
		});
	}

	function getParent($this) {
		var selector = $this.attr('data-target')

		if (!selector) {
			selector = $this.attr('href')
			selector = selector && /#[A-Za-z]/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, '')
		}

		var $parent = selector && $(selector)

		return $parent && $parent.length ? ($parent.length > 1) ? ($parent = $parent.has($this)) : $parent : $this.parent()
	}

	// SEARCH PERSON PLUGIN DEFINITION
	// ===============================

	function Plugin(option) {
		return this.each(function() {
			var $this = $(this);
			var data = $this.data('mcr.searchperson');
			var options = typeof option == 'object' && option

			if (!data)
				$this.data('mcr.searchperson', (data = new SearchPerson(this, option)));
			if (typeof option == 'string')
				data[option]();
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

	$(window).on('load', function() {
		$(toggle).each(function() {
			var $this = $(this)
			var data = $this.data()

			Plugin.call($this, data);
		});
	});

	$(document).on('click.mcr.searchperson.data-api', SearchPerson.prototype.clearAll);
}(jQuery);
