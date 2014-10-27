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
 * 		- searchButton			: the search button text
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
		this.$feedback = null;

		this.selectedType = options.searchType.toUpperCase() == "SELECT" ? SearchPerson.DEFAULTS.searchType : options.searchType;

		this.init();
	};

	SearchPerson.VERSION = '1.0.0';

	SearchPerson.LABEL_CLEANUP = /\s[\(]?[0-9-]+[\)]?/g;

	SearchPerson.TYPES = {
		GND : {
			url : "http://lobid.org/person",
			data : function(input) {
				return {
					name : input,
					format : "ids"
				}
			},
			dataType : "jsonp",
			baseURI : "http://d-nb.info/gnd/",
		},
		VIAF : {
			url : "http://www.viaf.org/viaf/AutoSuggest",
			data : function(input) {
				return {
					query : input,
				}
			},
			dataType : "jsonp",
			dataConvert : function(data) {
				var result = [];
				if (data.result !== undefined) {
					$(data.result).each(function(index, item) {
						if (item.nametype.toLowerCase() === "personal") {
							var person = {
								label : item.term,
								value : "http://www.viaf.org/viaf/" + item.viafid
							};
							result.push(person);
						}
					});
				}
				return result;
			},
			baseURI : "http://www.viaf.org/viaf/"
		}
	};

	SearchPerson.DEFAULTS = {
		// Button style
		buttonClass : "btn btn-default",
		// Feedback style (optical feedback for current selection)
		feedbackClass : "feedback label btn-primary",
		// Feedback cleaner icon style
		feedbackCleanIconClass : "feedback-clean btn-primary glyphicon glyphicon-remove-circle",

		// min length of search term
		inputMinLength : 3,

		// default search type
		searchType : "GND",

		// the max. height of results container
		searchResultMaxHeight : 200,

		// TEXT DEFINITIONS
		// ===============================
		// default button loading text
		searchButton : "Search",
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
		$searchBtn.html(options.searchButton);

		$searchBtn.on("click", function(e) {
			e.preventDefault();
			that.search(e);
		});

		$actions.append($searchBtn);
		$inputGroup.append($actions);
		$parent.append($inputGroup);

		if (options.searchType.toUpperCase() == "SELECT") {
			// preselect searchType by given output value
			var outputVal = $(options.searchOutput, getParent($element))[0] !== undefined ? $(options.searchOutput, getParent($element)).val() : "";
			if (outputVal.length > 0) {
				this.selectedType = getTypeFromURL(outputVal);
			}

			var $typeBtn = this.$typeBtn = $(document.createElement("button"));
			$typeBtn.addClass(options.buttonClass).addClass("dropdown-toggle");
			$typeBtn.attr("data-toggle", "dropdown");
			$typeBtn.html("<span class=\"caret\"></span><span class=\"sr-only\">Toggle Dropdown</span>");

			$actions.append($typeBtn);

			var $typeMenu = this.$typeMenu = $(document.createElement("ul"));
			$typeMenu.addClass("dropdown-menu dropdown-menu-right");
			$typeMenu.attr("role", "menu");

			for ( var type in SearchPerson.TYPES) {
				var $entry = $(document.createElement("li"));
				(type.toUpperCase() == this.selectedType.toUpperCase()) && $entry.addClass("active");

				var $ea = $(document.createElement("a"));
				$ea.attr("href", "#");
				$ea.data("search-type", type);
				$ea.text(type);

				$ea.on("click", function(e) {
					that.selectedType = $(this).data("search-type");
					$(".active", $(this).parents("ul")).toggleClass("active");
					$(this).parent().toggleClass("active");
				});

				$entry.append($ea);
				$typeMenu.append($entry);
			}

			$actions.append($typeMenu);
			$typeBtn.dropdown();
		}

		this.updateOutput();
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

			var type = null;
			for ( var t in SearchPerson.TYPES) {
				if (this.selectedType.toUpperCase() == t.toUpperCase()) {
					type = SearchPerson.TYPES[t];
					break;
				}
			}

			this.$searchBtn.button("loading");
			if (type != null) {
				SearchPerson.loadData(type.url, type.dataType, type.data(input), function(data) {
					if (data !== undefined) {
						that.showResult(SearchPerson.sortData(input, typeof type.dataConvert == "function" ? type.dataConvert(data) : data));
					} else {
						that.showResult();
					}
					that.$searchBtn.button("reset");
				}, function() {
					that.showResult();
					that.$searchBtn.button("reset");
				})
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

		var $resultBox = $(document.createElement("ul"));
		$resultBox.attr("role", "menu");
		$resultBox.addClass("dropdown-menu");

		if (data && data.length > 0) {
			$(data).each(function(index, item) {
				var $li = $(document.createElement("li"));

				var $person = $(document.createElement("a"));
				$person.attr("href", "#");
				$person.html(item.label);
				$person.on("click", function(e) {
					that.updateOutput(item);
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
		$resultBox.css({
			height : "auto",
			maxHeight : options.searchResultMaxHeight,
			width : "100%",
			overflow : "auto",
			overflowX : "hidden"
		});
		$resultBox.dropdown("toggle");

		this.$element.data($.extend({}, {
			searchResultContainer : $resultBox
		}, options));
	}

	SearchPerson.prototype.updateOutput = function(item) {
		var that = this;
		var options = this.options;
		var $output = $(options.searchOutput, getParent(this.$element))[0] !== undefined ? $(options.searchOutput, getParent(this.$element)) : this.$element;

		if (item) {
			this.$element != $output && item.label && this.$element.val(item.label.replace(SearchPerson.LABEL_CLEANUP, ""));
			$output.val(item.value);
		}

		if ($output != this.$element && $output.val().length > 0) {
			var $feedback = $(document.createElement("a"));
			$feedback.attr("href", $output.val());
			$feedback.attr("target", "_blank");
			$feedback.css({
				textDecoration : "none"
			});

			var $label = $(document.createElement("span"));
			$label.addClass(options.feedbackClass);
			$label.html(getTypeFromURL($output.val()));

			var $remover = $(document.createElement("a"));
			$remover.css({
				marginLeft : 5,
			});
			$remover.attr("href", "#");
			$remover.html("<i class=\"" + options.feedbackCleanIconClass + "\"></i>");
			$remover.on("click", function(e) {
				e.preventDefault();
				that.updateOutput({
					value : ""
				})
			});
			$label.append($remover);

			$feedback.append($label);

			if (this.$feedback)
				this.$feedback.remove();

			this.$feedback = $feedback;
			this.$element.after($feedback);

			$feedback.css({
				position : "absolute",
				marginLeft : -($feedback.width() + 10),
				marginTop : Math.floor((this.$element.innerHeight() - $feedback.height()) / 2),
				zIndex : 100
			});
		} else {
			if (this.$feedback)
				this.$feedback.remove();
		}
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

	SearchPerson.loadData = function(url, dataType, data, successCB, errorCB) {
		$.ajax({
			url : url,
			timeout : 5000,
			dataType : dataType,
			data : data,
			success : function(data) {
				successCB(data);
			},
			error : function() {
				errorCB();
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
			return levenshteinDistance(input, a.label.replace(SearchPerson.LABEL_CLEANUP, ""))
					- levenshteinDistance(input, b.label.replace(SearchPerson.LABEL_CLEANUP, ""));
		});
	}

	function getTypeFromURL(url) {
		for ( var type in SearchPerson.TYPES) {
			if (url.indexOf(SearchPerson.TYPES[type].baseURI) != -1)
				return type;
		}

		return null;
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
