/**
 * jQuery Plugin to search entity identifier.
 *
 * @author René Adler (eagle)
 * @version $Revision$
 *
 * <pre>
 * Usage:
 *
 * 	Parameters:
 * 		- target 				: the target container
 * 		- search 				: always &quot;searchEntity&quot;
 *
 * 		- searchEntityType		: can be person or organisation
 *
 * 		- searchType
 * 			- SELECT			: add searchType selection menu
 * 			- GND 				: search through http://lobid.org
 * 			- VIAF				: search through http://www.viaf.org
 * 		- searchOutput			: the output field for person the nameIdentifer ID,
 * 								  if nothing specified the input field is used
 * 		- searchOutputType		: the output field for person the nameIdentifer type,
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

  var toggle = '[data-search="searchEntity"]'

  var SearchEntity = function(element, options) {
    this.options = $.extend({}, SearchEntity.DEFAULTS, options);

    this.$parent = null;
    this.$element = $(element);
    this.$inputGroup = null;
    this.$searchBtn = null;
    this.$typeBtn = null;
    this.$typeMenu = null;
    this.$feedback = null;

    this.selectedType = options.searchType.toUpperCase() == "SELECT" ? SearchEntity.DEFAULTS.searchType : options.searchType;

    this.init();
  };

  SearchEntity.VERSION = '1.1.0';

  SearchEntity.LABEL_CLEANUP = /\s[\(]?[0-9-]+[\)]?/g;

  SearchEntity.TYPES = {
    GND : {
      baseURI : "http://d-nb.info/gnd/",
      person : {
        enabled : true,
        url : "//ws.gbv.de/suggest/gnd/",
        data : function(input) {
          return {
            searchterm : input,
            type : "DifferentiatedPerson"
          }
        },
        dataType : "jsonp",
        dataConvert : function(data) {
          var result = [];
          if (data.length == 4) {
            $(data[1]).each(function(index, item) {
              if (parseType(data[2][index]) === "DifferentiatedPerson") {
                var person = {
                  label : item,
                  value : data[3][index],
                  type: "personal"
                };
                result.push(person);
              }
            });
          }
          return result;
        }
      },
      organisation : {
        enabled : true,
        url : "//ws.gbv.de/suggest/gnd/",
        data : function(input) {
          return {
            searchterm : input,
            type : "CorporateBody"
          }
        },
        dataType : "jsonp",
        dataConvert : function(data) {
          var result = [];
          if (data.length == 4) {
            $(data[1]).each(function(index, item) {
              if (parseType(data[2][index]) === "CorporateBody") {
                var organisation = {
                  label : item,
                  value : data[3][index],
                  type: "corporate"
                };
                result.push(organisation);
              }
            });
          }
          return result;
        }
      },
      both : {
        enabled : true,
        url : "//ws.gbv.de/suggest/gnd/",
        data : function(input) {
          return {
            searchterm : input,
            type : "DifferentiatedPerson,CorporateBody",
            count: "30"
          }
        },
        dataType : "jsonp",
        dataConvert : function(data) {
          var result = [];
          if (data.length == 4) {
            $(data[1]).each(function(index, item) {
              if (parseType(data[2][index]) === "DifferentiatedPerson") {
                var person = {
                  label : item,
                  value : data[3][index],
                  type: "personal"
                };
                result.push(person);
              }
              if (parseType(data[2][index]) === "CorporateBody") {
                var organisation = {
                  label : item,
                  value : data[3][index],
                  type: "corporate"
                };
                result.push(organisation);
              }
            });
          }
          return result;
        }
      },
      topic : {
        enabled : true,
        url : "//ws.gbv.de/suggest/gnd/",
        data : function(input) {
          return {
            searchterm : input,
            type: "SubjectHeading"
          }
        },
        dataType : "jsonp",
        dataConvert : function(data) {
          var result = [];
          if (data.length == 4) {
            $(data[1]).each(function(index, item) {
              if (parseType(data[2][index]) === "SubjectHeading") {
                var topic = {
                  label : item,
                  value : data[3][index]
                };
                result.push(topic);
              }
            });
          }
          return result;
        }
      },
      geographic : {
        enabled : true,
        url : "//ws.gbv.de/suggest/gnd/",
        data : function(input) {
            return {
                searchterm : input,
                type: "PlaceOrGeographicName"
            }
        },
        dataType : "jsonp",
        dataConvert : function(data) {
            var result = [];
            if (data.length == 4) {
                $(data[1]).each(function(index, item) {
                    if (parseType(data[2][index]) === "PlaceOrGeographicName") {
                        var geographic = {
                            label : item,
                            value : data[3][index]
                        };
                        result.push(geographic);
                    }
                });
            }
            return result;
        }
      }
    },
    VIAF : {
      baseURI : "http://www.viaf.org/viaf/",
      person : {
        enabled : true,
        url : "//www.viaf.org/viaf/AutoSuggest",
        data : function(input) {
          return {
            query : input
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
        }

      },
      organisation : {
        enabled : true,
        url : "http://www.viaf.org/viaf/AutoSuggest",
        data : function(input) {
          return {
            query : input
          }
        },
        dataType : "jsonp",
        dataConvert : function(data) {
          var result = [];
          if (data.result !== undefined) {
            $(data.result).each(function(index, item) {
              if (item.nametype.toLowerCase() === "corporate") {
                var organisation = {
                  label : item.term,
                  value : "http://www.viaf.org/viaf/" + item.viafid
                };
                result.push(organisation);
              }
            });
          }
          return result;
        }
      },
      both : {
        enabled: true,
        url: "//www.viaf.org/viaf/AutoSuggest",
        data: function (input) {
          return {
            query: input
          }
        },
        dataType: "jsonp",
        dataConvert: function (data) {
          var result = [];
          if (data.result !== undefined) {
            $(data.result).each(function (index, item) {
              if (item.nametype.toLowerCase() === "personal") {
                var person = {
                  label: item.term,
                  value: "http://www.viaf.org/viaf/" + item.viafid,
                  type: "personal"
                };
                result.push(person);
              }
              if (item.nametype.toLowerCase() === "corporate") {
                var organisation = {
                  label: item.term,
                  value: "http://www.viaf.org/viaf/" + item.viafid,
                  type: "corporate"
                };
                result.push(organisation);
              }
            });
          }
          return result;
        }
      },
      topic : {
        enabled : false
      },
      geographic : {
        enabled : false
      }
    }
  };

  SearchEntity.DEFAULTS = {
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

    // default entity type
    searchEntityType : "person",

    // the max. height of results container
    searchResultMaxHeight : 200,

    // TEXT DEFINITIONS
    // ===============================
    // default button loading text
    searchButton : "Search",
    searchButtonLoading : "Loading...",
    searchResultEmpty : "<center><b>Nothing found</b></center>"
  };

  SearchEntity.prototype.init = function() {
    if (typeof $.fn.dropdown !== "function" && typeof $.fn.button !== "function") {
      console.error("Couldn't initalize SearchEntity because of missing Bootstrap \"dropdown\" and \"button\" plugin!");
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
      var outputValType = $(options.searchOutputType, getParent($element))[0] !== undefined ? $(options.searchOutputType, getParent($element)).val() : "";
      if (outputVal.length > 0) {
        this.selectedType = outputValType.toUpperCase();
      }

      var $typeBtn = this.$typeBtn = $(document.createElement("button"));
      $typeBtn.addClass(options.buttonClass).addClass("dropdown-toggle");
      $typeBtn.attr("data-toggle", "dropdown");
      $typeBtn.html("<span class=\"caret\"></span><span class=\"sr-only\">Toggle Dropdown</span>");

      $actions.append($typeBtn);

      var $typeMenu = this.$typeMenu = $(document.createElement("ul"));
      $typeMenu.addClass("dropdown-menu dropdown-menu-right");
      $typeMenu.attr("role", "menu");

      for ( var type in SearchEntity.TYPES) {
        if (SearchEntity.TYPES[type][options.searchEntityType].enabled == false)
          continue;

        if (SearchEntity.TYPES[this.selectedType] != undefined && SearchEntity.TYPES[this.selectedType][options.searchEntityType].enabled == false) {
          this.selectedType = type;
        }

        var $entry = $(document.createElement("li"));
        (type.toUpperCase() == this.selectedType.toUpperCase()) && $entry.addClass("active");

        var $ea = $(document.createElement("a"));
        $ea.attr("href", "#");
        $ea.data("search-type", type);
        $ea.text(type);

        $ea.on("click", function(e) {
          e.preventDefault();
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
  };

  SearchEntity.prototype.search = function(e) {
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
      for ( var t in SearchEntity.TYPES) {
        if (this.selectedType.toUpperCase() == t.toUpperCase()) {
          type = SearchEntity.TYPES[t][options.searchEntityType];
          break;
        }
      }

      this.$searchBtn.button("loading");
      if (type != null) {
        SearchEntity.loadData(type.url, type.dataType, type.data(input), function(data) {
          if (data !== undefined) {
            that.showResult(SearchEntity.sortData(input, typeof type.dataConvert == "function" ? type.dataConvert(data) : data));
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
  };

  SearchEntity.prototype.showResult = function(data) {
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
        $person.attr("data-type", item.type);
        $person.text(item.label);
        $person.on("click", function(e) {
          e.preventDefault();
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
  };

  SearchEntity.prototype.updateOutput = function(item) {
    var that = this;
    var options = this.options;
    var $output = $(options.searchOutput, getParent(this.$element))[0] !== undefined ? $(options.searchOutput, getParent(this.$element)).first() : this.$element;
    var $outputType = $(options.searchOutputType, getParent(this.$element))[0] !== undefined ? $(options.searchOutputType, getParent(this.$element)).first() : this.$element;
    var $outputNameType = $(options.searchOutputNameType, getParent(this.$element))[0] !== undefined ? $(options.searchOutputNameType, getParent(this.$element)).first() : this.$element;

    if (item) {
      this.$element != $output && item.label && this.$element.val(item.label.replace(SearchEntity.LABEL_CLEANUP, ""));
      $output.val(getIDFromURL(item.value));
      var outputType = getTypeFromURL(item.value);
      if (outputType != "") {
        $outputType.val(outputType.toLowerCase());
      }
      if (item.type != undefined && item.type != "") {
        $outputNameType.val(item.type.toLowerCase());
      }
    }

    if ($output != this.$element && $output.val().length > 0) {
      var type = $outputType.val();
      var $feedback = $(document.createElement("a"));
      $feedback.attr("href", getURLFromTypeAndID($outputType.val(), $output.val()));
      $feedback.attr("target", "_blank");
      $feedback.css({
        textDecoration : "none"
      });
      if(type == null || SearchEntity.TYPES[type.toUpperCase()] ==  undefined) {
        $feedback.attr("onclick", "return false;");
        $feedback.css({
          cursor : "default"
        });
      }

      var $label = $(document.createElement("span"));
      $label.addClass(options.feedbackClass);
      $label.html(type != null ? type.toUpperCase() : "N/A");

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
  };

  SearchEntity.prototype.clearAll = function(e) {
    if (e && e.which === 3)
      return;

    $(toggle).each(function() {
      var $this = $(this);
      var options = typeof this.options == 'object' ? this.options : $.extend({}, SearchEntity.DEFAULTS, $this.data());

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
  };

  SearchEntity.loadData = function(url, dataType, data, successCB, errorCB) {
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
  };

  SearchEntity.sortData = function(input, data) {
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
      return levenshteinDistance(input, a.label.replace(SearchEntity.LABEL_CLEANUP, ""))
          - levenshteinDistance(input, b.label.replace(SearchEntity.LABEL_CLEANUP, ""));
    });
  };

  function getTypeFromURL(url) {
    for ( var type in SearchEntity.TYPES) {
      if (url.indexOf(SearchEntity.TYPES[type].baseURI) != -1)
        return type;
    }

    return "";
  }

  function getIDFromURL(url) {
    for ( var type in SearchEntity.TYPES) {
      var pos = url.indexOf(SearchEntity.TYPES[type].baseURI);
      if (pos != -1)
        return url.substr(pos + SearchEntity.TYPES[type].baseURI.length);
    }
    return "";
  }

  function getURLFromTypeAndID(type, id) {
    var typeObj = SearchEntity.TYPES[type.toUpperCase()];
    if (typeObj != undefined) {
      return typeObj.baseURI + id;
    }
    return "";
  }

  function parseType(type) {
    var index = type.indexOf("/");
    if (index != -1) {
      return type.substring(0, index).trim();
    }
    return type;
  }

  function getParent($this) {
    var selector = $this.attr('data-target');

    if (!selector) {
      if ($this.attr('data-next')) {
        selector = $this.closest(".form-group").next($this.attr('data-next'));
      }
      else {
        selector = $this.attr('href');
        selector = selector && /#[A-Za-z]/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, '')
      }
    }

    var $parent = selector && $(selector)

    return $parent && $parent.length ? ($parent.length > 1) ? ($parent = $parent.has($this)) : $parent : $this.parent()
  }

  // SEARCH ENTITY PLUGIN DEFINITION
  // ===============================

  function Plugin(option) {
    return this.each(function() {
      var $this = $(this);
      var data = $this.data('mcr.searchentity');
      var options = typeof option == 'object' && option

      if (!data)
        $this.data('mcr.searchentity', (data = new SearchEntity(this, option)));
      if (typeof option == 'string')
        data[option]();
    });
  }

  var old = $.fn.SearchEntity;

  $.fn.searchEntity = Plugin;
  $.fn.searchEntity.Constructor = SearchEntity;

  // SEARCHPERSON NO CONFLICT
  // ========================

  $.fn.searchEntity.noConflict = function() {
    $.fn.SearchEntity = old;
    return this;
  };

  $(window).on('load', function() {
    $(toggle).each(function() {
      var $this = $(this);
      var data = $this.data();

      Plugin.call($this, data);
    });
  });

  $(document).on('click.mcr.searchentity.data-api', SearchEntity.prototype.clearAll);
}(jQuery);
