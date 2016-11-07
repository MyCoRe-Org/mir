$(document).ready(function() {
  var GenreXML;

  $(".mir-related-item-search input[name*='mods:titleInfo/mods:title']").each(function() {
    var id = $(this).closest(".mir-related-item-search").find("input[name*='mods:relatedItem/@xlink:href']").val();
    if ($(this).val() == "" && id != "") {
      loadTitle(id, $(this));
    } else {
      $(this).attr("disabled", "true");
    }
  });

  checkHost();

  $(".mir-relatedItem-select").each(function() {
    var button = $(this);
    var id = button.next().next("input").val();
    if (parseInt(id.substr(id.lastIndexOf("_") + 1)) < 1){
      button.next("span").text("Wird angelegt");
    }
    else {
      button.next("span").text(id);
    }
  });

  $("body").on("change", "select[name*='/@type']", function() {
    checkHost();
  });

  $("body").on("click", ".mir-relatedItem-select", function() {
    workRelatedItem($(this));
  });

  function checkHost() {
    var hostSelect = $("select[name*='/@type'] option[value='host']:selected").closest(".mir-related-item-search");
    $(".mir-related-item-search").each(function( index ) {
      if($(this).find("input[name*='mods:relatedItem/@xlink:href']").val() != "" && $(this).find("select[name*='mods:relatedItem/@type']").val() == "host") {
        $(this).find(".mir-relatedItem-select").prop('disabled', true);
      }
      else {
        $(this).find(".mir-relatedItem-select").prop('disabled', false);
      }
      if (hostSelect.length > 0 && $(this)[0] === hostSelect[0]) {
        $(this).find("select[name*='/@type'] option[value='host']").prop('disabled', false);
      }
      else {
        $(this).find("select[name*='/@type'] option[value='host']").prop('disabled', true);
        $(this).find("select[name*='/@type'] option[value='host']:selected").next().attr('selected', 'selected');
      }
      if (hostSelect.length == 0) {
        $(this).find("select[name*='/@type'] option[value='host']").prop('disabled', false);
      }
    });
  }

  function loadTitle(id, element){
    $.ajax({
      url: webApplicationBaseURL + "servlets/solr/select?q=id:" + id + "&XSL.Style=xml",
      type: "GET",
      success: function(data) {
        var title = $(data).find("str[name='mods.title.main']").text();
        $(element).val(title);
        $(element).attr("disabled", "true");
      },
      error: function(error) {
        console.log("Failed to load title for " + id );
        console.log(error);
      }
    });
  }

  function workRelatedItem(button){
    initBody();

    var input = button.next().next("input");
    var sortType = "";

    //load genre classification
    loadGenres(initContent);

    function initContent() {
      if(input.val().length > 0 && parseInt(input.val().substr(input.val().lastIndexOf("_") + 1)) > 1) {
        loadPublikation(leftContent, "select", "id:" + input.val(), "0");
        setTimeout(function() {
          $("#modalFrame").find(".list-group-item").addClass("active");
        }, 300);
        loadPublikation(rightContent, "receive", input.val(), "");
        activateSendButton(input.val());
      }


      if(!input.val() || parseInt(input.val().substr(input.val().lastIndexOf("_") + 1)) < 1) {
        loadPublikation(leftContent, "find", "", "0");
      }
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
      $(".already-linked").before("<div class='col-md-4 type-select'><select class='form-control'><option value=''>Sortieren nach Typ:</option></select></div>");
      $("li a").css("cursor", "pointer");
      $("#modal-searchInput").removeAttr("hidden");
      $("#modal-searchInput > input").attr("autocomplete", "off");
      $("#modalFrame").modal("show");
    }

    function leftContent(data) {
      $("#main_left_content").empty();
      var mainBody = $(data).find("result[name='doclist']");
      if (mainBody.length < 1) {
        mainBody = $(data).find("result[name='response']");
      }
      mainBody.each(function() {
        $(this).children().each(function() {
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
          $(elm).attr("data-title", $(this).find("str[name='mods.title.main']").text());
        });
      });
      updatePager(data);
      loadPublikation(updateType,"find", $(data).find("str[name='q']").text(), "0");
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
      var matches = $(data).find("int[name='matches']").text();
      if (matches == undefined || matches == "") {
        matches = $(data).find("result[name='response']").attr("numFound");
      }

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
        loadPublikation(rightContent, "receive", $(this).attr("value"), "");
        $(this).addClass("active");
        activateSendButton($(this).attr("value"));
      }
    });

    $("#modalFrame-send").unbind().click(function() {
      input.val($(".list-group-item.active").attr("value"));
      $(button).next("span").text($(".list-group-item.active").attr("value"));
      var titleInput = $(button).parents(".mir-related-item-search").find("input[name*='mods:title']");
      $(titleInput).val($(".list-group-item.active").attr("data-title"));
      $("#modalFrame").modal("hide");
    });

    $("#modalFrame").on('hidden.bs.modal', function() {
      $("#modalFrame-body").empty();
      $("nav.col-md-4").remove();
      $("#modal-searchInput > input").val("");
      $(".modal-footer div.type-select").remove();
    });

    $("#modal-searchInput > input").typeahead({
      source: function(query, process) {
        return loadPublikation(function(data){
          var list = [];
          $(data).find("result[name='response']").children().each(function () {
            list.push({name: $(this).find("arr[name='mods.title']").find("str:first-child").text(), id: $(this).find("str[name='id']").text()});
          });
          return process(list);
        }, "select", "mods.title:*" + query + "*", "0");
      },
      updater: function(item) {
        $("#main_right_content").empty();
        sortType = "";
        loadPublikation(leftContent, "select", "id:" + item.id, "0");
        setTimeout(function() {
          $("#modalFrame").find(".list-group-item").addClass("active");
        }, 300);
        loadPublikation(rightContent, "receive", item.id, "");
        activateSendButton(item.id);
        return item;
      },
      items: 10,
      autoSelect: false
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
        loadPublikation(leftContent, "find", $("#modal-searchInput > input").val(), $(this).attr("data"), "xml");
        $("#main_right_content").empty();
        $("#modalFrame-send").attr("disabled", "");
      }
    });

    $(".modal-footer select").change(function() {
      sortType = decodeURIComponent($(this).val());
      loadPublikation(leftContent, "find",  $("#modal-searchInput > input").val(), "0", "xml");
      $("#main_right_content").empty();
      $("#modalFrame-send").attr("disabled", "");
    });

    function searchPublikation() {
      $("#main_right_content").empty();
      $("#modalFrame-send").attr("disabled", "");
      sortType = "";
      loadPublikation(leftContent, "find", $("#modal-searchInput > input").val(), "0", "xml");
    }

    function loadPublikation(callback, type, qry, start){
      var url = "";
      var dataType = "";
      switch (type) {
        case "find":
              url = "servlets/solr/find?q=" + qry + "&fq=objectType%3A\"mods\"&fq=" + sortType + "&start=" + start + "&rows=10&owner=createdby:*&XSL.Style=xml";
              dataType = "xml";
              break;
        case "select":
              url = "servlets/solr/select?q=" + qry + "&fq=objectType%3A\"mods\"&start=0&rows=10&XSL.Style=xml";
              dataType = "xml";
              break;
        case "receive":
              url = "receive/" + qry;
              dataType = "html";
              break;
        default:
              break;
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

    function loadGenres(callback) {
      if (!webApplicationBaseURL) console.log("Error: webApplicationBaseURL not set");
      $.ajax({
        method: "GET",
        url: webApplicationBaseURL + "api/v1/classifications/mir_genres",
        dataType: "xml"
      }).done(function( xml ) {
        GenreXML=xml;
        callback();
      }).fail(function () {
        console.log("Warning: could not load genres, genres will be displayed as undefined");
        callback();
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

    function activateSendButton(id) {
      if(input.val() != id && $("input[name*='/@xlink:href'][value='" + id + "']").length > 0) {
        $("#modalFrame-send").attr("disabled", "");
        $(".already-linked").removeClass("hidden");
      }
      else {
        $("#modalFrame-send").removeAttr("disabled");
        $(".already-linked").addClass("hidden");
      }
    }
  }
});