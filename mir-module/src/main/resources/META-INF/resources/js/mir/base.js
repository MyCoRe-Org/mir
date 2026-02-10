(function ($) {
    $(document).ready(function () {
        const iiifSearchSelector = "data-iiif-jwt";

        if ($("[" + iiifSearchSelector + "]").length > 0) {
            $.ajax({
                url: webApplicationBaseURL + "rsc/jwt",
                type: "GET",
                traditional: true,
                dataType: "json",
                success: function (data) {
                    if (data.login_success) {
                        loadImages(data);
                    }
                },
                error: function (resp, title, message) {
                    console.log(resp);
                    console.log("Token request failed.");
                }
            });
        }

        function loadImages(token) {
            $("[" + iiifSearchSelector + "]").each(function (i, div) {
                let url = div.getAttribute(iiifSearchSelector);
                var xhr = new XMLHttpRequest();
                xhr.onreadystatechange = function () {
                    if (this.readyState === 4 && this.status === 200) {
                        //console.log(this.response, typeof this.response);
                        var url = window.URL || window.webkitURL;
                        div.style.backgroundImage = "url(\"" + url.createObjectURL(this.response) + "\")";
                    }
                }
                xhr.open('GET', url);
                xhr.responseType = 'blob';
                xhr.setRequestHeader("Authorization", token.token_type + " " + token.access_token);
                xhr.send();
            });
        }

        document.querySelectorAll(".personPopover, .boxPopover").forEach(function (popoverElement) {
            let id = popoverElement.getAttribute("id");
            let contentID = id + "-content";
            let contentElement = document.getElementById(contentID);
            if (!contentElement) return;
            contentElement.classList.remove("d-none");
            contentElement.remove();
            let closeButton = document.createElement("div");
            closeButton.classList.add("popoverclose", "position-absolute", "top-0", "end-0", "p-2");
            closeButton.innerHTML = '<button class="btn-close btn-close-white"></button>';
            contentElement.prepend(closeButton);
            new bootstrap.Popover(popoverElement, {
                content: contentElement,
                html: true
            });
        });

        $("body").on("click", ".popoverclose", function(e) {
            let popoverElement = $(this).closest(".popover")[0];
            if (popoverElement) {
                let triggerElement = document.querySelector(`[aria-describedby="${popoverElement.id}"]`);
                if (triggerElement) {
                    let popoverInstance = bootstrap.Popover.getInstance(triggerElement);
                    if (popoverInstance) {
                        popoverInstance.hide();
                    }
                }
            }
        });

        $('.dropdown-submenu a.submenu').on("click", function(e){
            $(this).next('ul').toggle();
            e.stopPropagation();
            e.preventDefault();
          });

        $(".mir_metadata a.ppn").each(function () {
            if ($(this).attr('href').indexOf(":ppn:") > -1) {
                resolvePPN($(this));
            }
        });

        if(window.location.search.indexOf("XSL.Status") > -1) {
            let paramString = window.location.search.substring(1);
            let newParamString = "";
            $.each(paramString.split("&"), function (index, param) {
                if (param.indexOf("XSL.Status.Message") === -1 && param.indexOf("XSL.Status.Style") === -1) {
                    if(newParamString === "") {
                        newParamString += "?" + param;
                    }
                    else {
                        newParamString += "&" + param;
                    }
                }
            });
            window.history.replaceState({}, document.title, window.location.origin + window.location.pathname + newParamString);
        }


//--- in metadata view the select/video controller
        // on start load the first source


        var videoChooserElement = $("#videoChooser");


        $(".mir-player video, .mir-player audio").ready(function () {

            var videoOptions = videoChooserElement.find("option");
            if(videoOptions.length===1){
                videoChooserElement.hide();
            } else {
              videoOptions.filter("[data-is-main-doc=true]").first().prop("selected",true);
            }

            videoChooserElement.change();
        });

        //get all sources of selected item in a var and give it to player
        var hidePlayer = function (player) {
            if (typeof player !== "undefined") {
                player.hide();
                player.pause();
            }
        };

        var sourceCache = {};

        var getVideo = function (currentOption) {
            var src = currentOption.attr("data-src");
            var mimeType = currentOption.attr("data-mime-type");
            var sourceArr = [];
            var lookupKey = currentOption.parent().index() + "_" + currentOption.index();

            if (lookupKey in sourceCache) {
                return sourceCache[lookupKey];
            }

            if (typeof src === "undefined" || typeof mimeType === "undefined") {
                var sources = currentOption.attr("data-sources");
                if (typeof sources === "undefined") {
                    console.warn("No video sources found!");
                    return [];
                }

                var pairs = sources.split(";");
                for (var i in pairs) {
                    var pair = pairs[i];
                    if (pair.indexOf(",") === -1) {
                        continue;
                    }
                    var typeSrcArr = pair.split(",");
                    var type = typeSrcArr[0];
                    var src = typeSrcArr[1];

                    sourceArr.push({type: type.trim(), src: src.trim()});
                }
            } else {
                sourceArr.push({type: mimeType.trim(), src: src.trim()});
            }
            sourceCache[lookupKey] = sourceArr;
            return sourceArr;
        };

        videoChooserElement.change(function () {
            // reuse player
            var myPlayerVideo, myPlayerAudio;
            var selectElement = $(this);
            var currentOption = selectElement.find(":selected");

            if ($(".mir-player video").length > 0) {
                myPlayerVideo = selectElement.data("playerVideo");
                if (!myPlayerVideo) {
                    myPlayerVideo = videojs($(".mir-player video").attr("id"));
                    selectElement.data("playerVideo", myPlayerVideo);
                }
            }

            if ($(".mir-player audio").length > 0) {
                myPlayerAudio = selectElement.data("playerAudio");
                if(!myPlayerAudio){
                    myPlayerAudio = videojs($(".mir-player audio").attr("id"));
                    selectElement.data("playerAudio", myPlayerAudio);
                }
            }

            var playerToHide, playerToShow;
            var sourceArr = getVideo(currentOption);
            var isAudio = currentOption.attr("data-audio") == "true";
            var htmlEmbed = jQuery(".mir-player");

            if (isAudio) {
                playerToHide = myPlayerVideo;
                playerToShow = myPlayerAudio;
            } else {
                playerToShow = myPlayerVideo;
                playerToHide = myPlayerAudio;
            }


            hidePlayer(playerToHide);
            playerToShow.show();


            playerToShow.src(sourceArr);

        });

//--------

    $("body").on("click", ".mir_mainfile", function (event) {
      event.preventDefault();
      var that = $(this);
      var oldMainFile = $(that).closest(".file_set.active_file");
      $(that).closest(".file_set.active_file").removeClass("active_file");
      $(that).closest(".file_set").addClass("waiting_file");
      var path = $(this).data("path");
      path = (path.charAt(0) == "/" ? path.substr(1) : path);
      $.ajax({
        type: 'GET',
        url: webApplicationBaseURL + "servlets/MCRDerivateServlet?derivateid=" + $(this).data("derivateid") + "&objectid=" + $(this).data("objectid") + "&todo=ssetfile&file=" + path,
      }).done(function (result) {
        $(that).closest(".file_set").removeClass("waiting_file");
        $(that).closest(".file_set").addClass("active_file");
      }).fail(function (result) {
        $(that).closest(".file_set").removeClass("waiting_file");
        $(oldMainFile).addClass("active_file");
        console.log("Error while changing mainfile!");
      });
    });

    $('#copy_cite_link').click(function(event){
      event.preventDefault();
      $("#identifierModal").modal("show");
    });

    $("body").on("click", ".mir_copy_identifier", function () {
      var input = $(this).parents(".mir_identifier").find(".mir_identifier_hidden_input");
      $(input).removeClass("d-none");
      $(input).first().select();
      try {
        var successful = document.execCommand('copy');
        if (successful){
          $(this).attr('data-original-title', 'Copied!').tooltip('show');
        }
        else {
          $(this).attr('data-original-title', 'Oops, unable to copy').tooltip('show');
        }
      } catch (err) {
        $(this).attr('data-original-title', 'Oops, unable to copy').tooltip('show');
      }
      $(input).addClass("d-none");
    });

    $('.mir_copy_identifier').on('hidden.bs.tooltip', function () {
      $(this).attr('data-original-title', $(this).attr("data-org-title"));
    });

    $("body").on("focus", ".search-organization input[name*='mods:displayForm']", function() {
      $(".name-modal textarea").val($(this).val());
      $(this).addClass("inModal");
      $(".name-modal").modal("show");
    });

    $("body").on("keydown", ".name-modal textarea", function(event) {
      if (event.which == 27) {
        $(this).modal("hide");
      }
    });

    $("body").on("hide.bs.modal", ".name-modal", function() {
      var input = $(this).find("textarea").val().replace(/\n/g, " ");
      $(".inModal").val(input);
      $(".inModal").attr("title", input);
      $(".inModal").removeClass("inModal");
    });

    $("#mir_relatedItem > li > ul").hide();
    $("#mir_relatedItem_hideAll").hide();

    //show full version history in metadata view
    $("#historyStarter").click(function() {
      $("#historyModal").modal("show");
    });

    //define the primary button in a form with multiple submit buttons
    $("[order=primary-button]").ready(function() {
      var myForm = $("[order=primary-button]").parents("form:first");
      $(myForm).find("input[type=text]").keypress(function(event) {
        if(event.keyCode == 13 || event.which == 13) {
          $("[order=primary-button]").click();
        }
      });
    });

    // Input element in the mir-flatmir-layout-utils.xsl search
    const mirFlatmirLayoutSearchInputElement = "#searchInput";
    // Selector for the second search form
    const subSearchFormName = "form.search_form";
    // The submit button in the second search form
    const secondSearchFormSubmitButtonElement = subSearchFormName + ' button[type="submit"]';
    // ID of the input field for the second search text
    const qrySelector = "#qry";
    // ID of the dropdown element with the filter query key
    const selectMods = "#select_mods";
    // ID of the dropdown element with the filter query key
    const selectModsLabel = "#select_mods_label";
    // Selector of a dropdown-menu item
    const selectModsItem = ".select_mods_type .dropdown-item";
    // ID of the hidden element with the fq parameter
    const fqElement = "#fq";
    // ID of the hidden element with the initial condQuery parameter in the mir-flatmir-layout-utils.xsl search form
    const initialCondQueryMirFlatmirLayout = "#initialCondQueryMirFlatmirLayout";
    // ID of the hidden element with the initial condQuery parameter in the second search form
    const initialCondQuerySecond = "#initialCondQuerySecond";
    // ID of the hidden element 'condQuery' for the query parameter 'condQuery'
    const condQuery = "#condQuery";

    // Input element's changes in the mir-flatmir-layout-utils.xsl search
    $(mirFlatmirLayoutSearchInputElement).change(() => {
        if ($(initialCondQueryMirFlatmirLayout).length) {
            let initialCondQueryValue = $(mirFlatmirLayoutSearchInputElement).val().trim();
            if (initialCondQueryValue === '') {
                initialCondQueryValue = '*';
            }
            $(initialCondQueryMirFlatmirLayout).attr('value', initialCondQueryValue);
        }
    });

    // Select one of the dropdown-menu items
    $(selectModsItem).click(function() {
      if ($(selectModsLabel).length) {
        // Change the dropdowns label
        $(selectModsLabel).html( $( this ).html() );
      }
      if ($(selectMods).length) {
        // Change the dropdowns value
        $(selectMods).attr( 'value', $( this ).attr('value') );

        setFQAndCondQueryElementsValues('selectMods');
      }
    });

    // Changes in the input field of the filter query
    $(qrySelector).change(() => {
        setFQAndCondQueryElementsValues('changeQry');
    });

    // Key up changes in the second search input element
    $(qrySelector).keyup(() => {
        if ($(selectMods).length) {
            const queryText = $(qrySelector).val().trim();
            const selectModsValue = $(selectMods).val();
            // Case if selectMods is 'all' - 'everything'
            if (selectModsValue !== 'all') {
                if (queryText !== '') {
                    // Enable the submit button in the second search form
                    enableButton(secondSearchFormSubmitButtonElement);
                } else {
                    // Disable the submit button in the second search form
                    disableButton(secondSearchFormSubmitButtonElement);
                }
            }
        }
    });

    // Changes for the fq element and condQuery element
    function setFQAndCondQueryElementsValues(eventType = 'selectMods') {
        if ($(selectMods).length && $(qrySelector).length && $(fqElement).length && $(initialCondQuerySecond).length
          && $(condQuery).length) {
            let queryText = '';
            queryText = $(qrySelector).val().trim();
            // Remove all duplicate spaces, tabs, newlines etc
            queryText = queryText.replace(/\s\s+/g, ' ');
            const initialCondQueryValue = $(initialCondQuerySecond).val().trim();

            const selectModsValue = $(selectMods).val();
            // Case if selectMods is 'all' - 'everything'
            if (selectModsValue === 'all') {
                $(fqElement).attr('value', '');
                let condQueryValue = initialCondQueryValue;
                if (queryText !== '') {
                    condQueryValue += ' AND ' + preparingQueryStringForSolr(queryText);
                } else {
                    condQueryValue += queryText;
                }
                $(condQuery).attr('value', condQueryValue);
                if (eventType === 'selectMods') {
                    // Enable the submit button in the second search form
                    enableButton(secondSearchFormSubmitButtonElement);
                }
            } else {
                const filterQuery = selectModsValue + ':' + preparingQueryStringForSolr(queryText);
                $(fqElement).attr('value', filterQuery);
                $(condQuery).attr('value', initialCondQueryValue);
                if (eventType === 'selectMods') {
                    if (queryText !== '') {
                        // Enable the submit button in the second search form
                        enableButton(secondSearchFormSubmitButtonElement);
                    } else {
                        // Disable the submit button in the second search form
                        disableButton(secondSearchFormSubmitButtonElement);
                    }
                }
            }
        }
    }

    // Add special characters to the query string for the SOLR request and remove all quotes from the query string
    function preparingQueryStringForSolr(queryStr) {
        return queryStr ? '"' + queryStr.replace(/"|%22/g, '') + '"' : queryStr;
    }

    // Disable the button
    function disableButton(element) {
        if (element) {
            $(element).attr('disabled','disabled');
        }
    }

    // Enable the button
    function enableButton(element) {
        if (element) {
            $(element).removeAttr('disabled');
        }
    }

    // Element with the link to toggle to show/hide md5 sums
    const toggleMD5LinkElement = '.toggleMD5Link';
    // Derivate action dropdown toggle button element
    const derivateActionDropdownToggleButton = '.headline .dropdown.options .dropdown-toggle';
    // Element selector with md5 information
    const md5ElementSelector = '.file_md5';
    // Element selector for the derivate file box
    const fileBoxSelector = '.file_box';

    // Show/hide md5 sums by derivate files by clicking on the 'toggleMD5LinkElement' element
    $(toggleMD5LinkElement).click((evt) => {
      evt.preventDefault();
      // Get a current derivate parent element
      const currentDerivateIdParentElements = $(evt.currentTarget).closest(fileBoxSelector);
      if (currentDerivateIdParentElements.length) {
        // Get all elements for all files with the md5 sum
        const currentMd5Elements = $(currentDerivateIdParentElements.get(0)).find(md5ElementSelector);
        if (currentMd5Elements.length) {
          // Show/hide every element
          currentMd5Elements.each((index, element) => {
            $(element).toggleClass('hidden');
          });
        }
      }
    });

    // Getting i18n translation for the link to switch state 'show/hide MD5 amounts' depending on the visibility of the
    // message with this amount when clicking on the 'derivateActionDropdownToggleButton' element
    $(derivateActionDropdownToggleButton).click((evt) => {
      // Get a current derivate parent element
    	const currentDerivateIdParentElements = $(evt.currentTarget).closest(fileBoxSelector);
    	if (currentDerivateIdParentElements.length) {
        // Get all elements for all files with the md5 sum
    		const currentMd5Elements = $(currentDerivateIdParentElements.get(0)).find(md5ElementSelector);
    		if (currentMd5Elements.length) {
          // only the first element is checked for the presence/absence of a hidden class,
          // assuming that the remaining elements of the current derivate meet this condition
    			const i18nKey = ($(currentMd5Elements.get(0)).hasClass('hidden'))
        	  		? ('component.mods.metaData.options.MD5.show')
        	  		: ('component.mods.metaData.options.MD5.hide');

          // Get a current toggle element
          const currentToggleMD5LinkElement = $(currentDerivateIdParentElements.get(0)).find(toggleMD5LinkElement);

          if (currentToggleMD5LinkElement.length) {
            getI18n(i18nKey, currentToggleMD5LinkElement.get(0));
          }
    		}
    	}
    });

    var languageList = jQuery('#topnav .languageList');
    jQuery('#topnav .languageSelect').click(function() {
      languageList.toggleClass('hide');
    });
    // editor fix (to many tables)
    $('table.editorPanel td:has(table)').css('padding', '0');

    $('.confirm_deletion').confirm();


    $(".searchfield_box").submit(function () {
      let input = $("input.search-query").val();
      input = input.replace(/[^\w\s]/gi, " ");
      $("input.search-query").val(input);
    });

    // search person index
    // makes sure the query ends with .* on submit
    $("#index_search_form").submit( function () {
      // define regEx pattern
      var endsNotWithDotAsterisk = /^((?!\.\*).)*$/;  // (?!xxx) expression is not allowed to follow prevoius expression
      var endsWithAsteriskOnly   = /[^\.]\*$/;        // last char is a asterisk, with no dot before
      // check if query string ends not with .* already
      if ($('#index_search').val().match(endsNotWithDotAsterisk)) {
        // check if query string ends with a asterisk or has a asterisk only
        if (
            $('#index_search').val().match(endsWithAsteriskOnly) ||
            $('#index_search').val() === "*"
          ){
          // replace the * by .*
          $('#index_search').val($('#index_search').val().replace('*','.*'));
        } else {
          // query string ends not with a asterisk
          // add a .* to the query string
          $('#index_search').val($('#index_search').val()+".*");
        }
      } // no need for actions, query ends already with .*
    });

    //date filter option
    $('.mir-search-options-date input').ready(function() {
      var currentURL = window.location.href;
      if(currentURL.indexOf('&fq=mods.dateIssued') > 0) {
        var fqDate = currentURL.substr(currentURL.indexOf('&fq=mods.dateIssued'));
        fqDate = decodeURIComponent(fqDate.split('&')[1]);

        //comparison val
        if(fqDate.indexOf('"') > 0) {
          $(".mir-search-options-date .list-group a").append(' = ');
        }
        if(fqDate.indexOf('+TO+*') > 0 && fqDate.indexOf('{') > 0) {
          $(".mir-search-options-date .list-group a").append(' > ');
        }
        if(fqDate.indexOf('+TO+*') > 0 && fqDate.indexOf('[') > 0) {
          $(".mir-search-options-date .list-group a").append(' >= ');
        }
        if(fqDate.indexOf('*+TO+') > 0 && fqDate.indexOf('}') > 0) {
          $(".mir-search-options-date .list-group a").append(' < ');
        }
        if(fqDate.indexOf('*+TO+') > 0 && fqDate.indexOf(']') > 0) {
          $(".mir-search-options-date .list-group a").append(' <= ');
        }

        //date val
        fqDate = fqDate.replace(/[a-zA-Z.:"+*={}/\]/\[]/g, '');
        $(".mir-search-options-date .list-group a").append(fqDate);
      }
    });

    //date filter option
    $('.mir-search-options-date #dateSearch').click(function() {
        var currentURL = window.location.href;
        var fqDate = '';
        var newURL = currentURL;
        var dateInput = $('.mir-search-options-date .dateContainer :input');
        var date = '';
        //piece together date
        if(!!$(dateInput[2]).val()) {
          date = $(dateInput[2]).val();
          if(!!$(dateInput[1]).val()) {
            date = date + '-' + $(dateInput[1]).val();
            if(!!$(dateInput[0]).val()) {
              date = date + '-' + $(dateInput[0]).val();
            }
          }
        }

        if(date != '') {
          if(currentURL.indexOf('&fq=mods.dateIssued') > 0) {
            fqDate = currentURL.substr(currentURL.indexOf('&fq=mods.dateIssued'));
            fqDate = fqDate.split('&')[1];
            newURL = currentURL.replace('&' + fqDate, '');
          }
          var operator = $('.mir-search-options-date select').val();
          if(operator == '=') {
            newURL = newURL + '&fq=mods.dateIssued%3A"' + date + '"';
          }
          if(operator == '>') {
            newURL = newURL + '&fq=mods.dateIssued%3A{' + date + '+TO+*]';
          }
          if(operator == '>=') {
            newURL = newURL + '&fq=mods.dateIssued%3A[' + date + '+TO+*]';
          }
          if(operator == '<') {
            newURL = newURL + '&fq=mods.dateIssued%3A[*+TO+' + date + '}';
          }
          if(operator == '<=') {
            newURL = newURL + '&fq=mods.dateIssued%3A[*+TO+' + date + ']';
          }
          window.location.href = newURL;
        }
    });

    $('.stopAutoclose').click(function(event) {
      event.stopPropagation()
    });

    //colapse the next element
    $('[data-mcr-toggle=collapse-next]').click(function() {
      $(this).next().collapse('toggle');
    });

    if ($("#mir-abstract-tabs, #mir-abstract").length > 0) {
      $(".ellipsis").each(function( i ) {
          $(this).addClass("hidden-calc");
          console.log( $(this)[0].scrollHeight + '>' + Math.ceil($(this).innerHeight()) );
          if( $(this)[0].scrollHeight > Math.ceil($(this).innerHeight()) ) {
              $(this).addClass("overflown");
              $(this).css("overflow-y", "hidden");
              $("#mir-abstract-overlay").find(".readmore").removeClass("d-none");
          }
          $(this).removeClass("hidden-calc");
      });

      $("body").on("click", "#mir-abstract-overlay a.readmore" , function(evt) {
          evt.preventDefault();
          let abstract = $("#mir-abstract-tabs .tab-content .active, #mir-abstract .ellipsis");
          $(abstract).data("oldHeight", $(abstract).height());
          $(abstract).css("max-height",$(abstract)[0].scrollHeight);
          $(abstract).addClass("expanded");
          $(this).parent().find(".readless").removeClass("d-none");
          $(this).parent().find(".readmore").addClass("d-none");
      });

      $("body").on("click", "#mir-abstract-overlay a.readless" , function(evt) {
          evt.preventDefault();
          let abstract = $("#mir-abstract-tabs .tab-content .active, #mir-abstract .ellipsis");
          $(abstract).css("max-height",$(abstract).data("oldHeight"));
          $(this).parent().find(".readmore").removeClass("d-none");
          $(abstract).removeClass("expanded");
          $(this).parent().find(".readless").addClass("d-none");
      });

      $("body").on("click", "#mir-abstract-tabs .nav-tabs a" , function(evt) {
        let abstract = $($(this).attr("href"));
        if ($(abstract).hasClass("overflown")){
            if ($(abstract).hasClass("expanded")){
                $("#mir-abstract-overlay .readless").removeClass("d-none");
                $("#mir-abstract-overlay .readmore").addClass("d-none");
            }
            else {
                $("#mir-abstract-overlay .readmore").removeClass("d-none");
                $("#mir-abstract-overlay .readless").addClass("d-none");
            }
        }
        else {
            $("#mir-abstract-overlay .readmore").addClass("d-none");
            $("#mir-abstract-overlay .readless").addClass("d-none");
        }
      });

    }

    $("#mir_relatedItem > li > span").click(function(){
      if( $(this).parent().children("ul").is(":visible") ){
        $(this).parent().children("ul").hide();
        $(this).parent().children("span.fa").removeClass('fa-chevron-down');
        $(this).parent().children("span.fa").addClass('fa-chevron-right');
      } else {
        $(this).parent().children("ul").show();
        $(this).parent().children("span.fa").removeClass('fa-chevron-right');
        $(this).parent().children("span.fa").addClass('fa-chevron-down');
      }
    });

    $("#mir_relatedItem_showAll").click(function(event){
      event.preventDefault();
      $("#mir_relatedItem > li > ul").show();
      $("#mir_relatedItem > li > span.fa").removeClass('fa-chevron-right');
      $("#mir_relatedItem > li > span.fa").addClass('fa-chevron-down');
      $("#mir_relatedItem_showAll").hide();
      $("#mir_relatedItem_hideAll").show();
    });

    $("#mir_relatedItem_hideAll").click(function(event){
      event.preventDefault();
      $("#mir_relatedItem > li > ul").hide();
      $("#mir_relatedItem > li > span.fa").removeClass('fa-chevron-down');
      $("#mir_relatedItem > li > span.fa").addClass('fa-chevron-right');
      $("#mir_relatedItem_showAll").show();
      $("#mir_relatedItem_hideAll").hide();
    });

    $("#modal-pi-add").click(function () {
        let button = jQuery(this);
        let mcrId = button.attr("data-mycoreID");
        let baseURL = button.attr("data-baseURL");
        let service = button.attr("data-register-pi");
        let resource = baseURL + "rsc/pi/registration/service/" + service + "/" + mcrId;
        let type = button.attr("data-type");

        $.ajax({
            type: 'POST',
            url: resource,
            data: {}
        }).done(function (result) {
            window.location.search = "XSL.Status.Message=component.pi.register." + type + ".success&XSL.Status.Style=success";
        }).fail(function (result) {
            if ("responseJSON" in result && "code" in result.responseJSON) {
                window.location.search = "XSL.Status.Message=component.pi.register.error." + result.responseJSON.code + "&XSL.Status.Style=danger";
            } else {
                window.location.search = "XSL.Status.Message=component.pi.register." + type + ".error&XSL.Status.Style=danger";
            }
        });
    });

    $("[data-register-pi]").click(function () {
        let registerButton = $(this);
        replaceI18n($("#modal-pi"), $(this).attr("data-register-pi")).then(function () {
            setPiModalDataAndShow(registerButton);
        });
    });

    $(".searchfield_box form").submit(function() {
      $("input").each(function(i,elem){ if($(elem).prop("value").length==0){ $(elem).prop("disabled", "disabled"); } });
    });

  }); // END $﻿(document).ready()

    function setPiModalDataAndShow(button) {
        let modalButton = $("#modal-pi-add");
        button.attr("data-mycoreID") ? modalButton.attr("data-mycoreID", button.attr("data-mycoreID")) : modalButton.removeAttr("data-mycoreID");
        button.attr("data-baseURL") ? modalButton.attr("data-baseURL", button.attr("data-baseURL")) : modalButton.removeAttr("data-baseURL");
        button.attr("data-register-pi") ? modalButton.attr("data-register-pi", button.attr("data-register-pi")) : modalButton.removeAttr("data-register-pi");
        button.attr("data-type") ? modalButton.attr("data-type", button.attr("data-type")) : modalButton.removeAttr("data-type");
        $("#modal-pi").modal("show");
    }

    function replaceI18n(element, suffix) {
        var requests = [];
        $(element).find("[data-i18n]").each(function () {
            requests.push(getI18n($(this).attr("data-i18n") + suffix, $(this)));
        });
        return $.when.apply($, requests);
    }

    function getI18n(i18nKey, currentElm) {
        return $.ajax({
            url: webApplicationBaseURL + "rsc/locale/translate/" + $("html").attr("lang") + "/" + i18nKey,
            type: "GET"
        }).done(function (text) {
            $(currentElm).html(text);

        }).fail(function () {
            console.log("Can not get i18nKey: " + i18nKey);
            $(currentElm).html(i18nKey);
        });
    }

    function trimPPNUrl(ppnUrl) {
        if (ppnUrl) {
            try {
                let url = new URL(ppnUrl);
                return (url && url.protocol + "//" + url.host + url.pathname) || ppnUrl;
            } catch (e) {
                console.error(e);
            }
        }
        return ppnUrl;
    }

    function resolvePPN(element) {
        $.ajax({
            url: "https://daia.gbv.de/?id=" + trimPPNUrl($(element).attr("href")) + "&format=json",
            type: "GET",
            dataType: "json",
            success: function(data) {
                if (data.document !== undefined && data.document.length > 0 && data.document[0].href !== undefined) {
                    $(element).attr("href", data.document[0].href)
                }
                else {
                    console.warn("Can not resolve PPN: " +  $(element).text());
                }
            },
            error: function(error) {
                console.warn("Can not resolve PPN: " +  $(element).text());
            }
        });
    }

  function dotdotdotCallback(isTruncated, originalContent) {
    if (!isTruncated) {
      $("a.readmore", this).remove();
      $("a.readless", this).remove();
    }
  }
    window.solrEscapeSearchValue = function base_solrEscapeSearchValue(text){
    return text.replace(/([\\!&|+\\-\\(\\)\\{\\}\\\[\\\]~:\\\\/^])/g, "\\$1"); // special chars: "!&|+-(){}[]~:\\/^"
  };


  window.fireMirSSQuery = function base_fireMirSSQuery(form) {
    $(form).find(':input[value=""]').attr('disabled', true);
    return true;
  };

  // initiate bs tooltips
  // https://getbootstrap.com/docs/5.3/components/tooltips/#enable-tooltips
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));

  // iniate bs popovers
  // https://getbootstrap.com/docs/5.3/components/popovers/
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]');
  const popoverList = [...popoverTriggerList].map(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl, {html:true}));

  /* =================
  /   go back to top
  /  ================= */
  // create html code for button
  var back_to_top_button = ['<button class="btn back-to-top" aria-label="UP button"><i class="fas fa-chevron-circle-up"></i></button>'].join("");
  // add button to page
  $("#page").append(back_to_top_button);
  // hide button
  $(".back-to-top").hide();
  // on scroll
  $(function () {
    $(window).scroll(function () {
      // if scrolled down
      if ($(this).scrollTop() > 100) {
        $('.back-to-top').fadeIn();
      } else {
        $('.back-to-top').fadeOut();
      }
    });
  });
  // click button
  $('.back-to-top').click(function () {
    $('body,html').animate({
      scrollTop: 0
    }, 800);
    return false;
  });
  /* end: go back to top */

})(jQuery);

// Back to top button functionality
(() => {
    const btns = document.getElementsByClassName("back-to-top");
    if (btns.length === 0) return;
    const isReduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches === true;
    const topAnchor = document.getElementById("top");
    if (!topAnchor) {
        console.warn("No top anchor found for back to top button functionality.");
        return;
    }

    btns[0].onclick = (e) => {
        //get position of the top anchor
        const topAnchorPosition = topAnchor.getBoundingClientRect().top + window.scrollY;
        if (isReduced) {
            window.scrollTo(0, topAnchorPosition);
        } else {
            window.scrollTo({top: topAnchorPosition, behavior: "smooth"});
        }
        e.preventDefault();
    };

    const toggle = (show) => btns[0].classList.toggle("is-visible", show);

    const io = new IntersectionObserver(
        (e) => toggle(!e.at(-1).isIntersecting),
        {rootMargin: "100px 0px 0px 0px"}
    );
    io.observe(topAnchor);
})();
