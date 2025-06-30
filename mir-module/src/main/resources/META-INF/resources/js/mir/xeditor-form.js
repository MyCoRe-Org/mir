$(document).ready(function () {

    select2()
      .then(() => $('.mir-select-searchable').on('select2:open', function (e) {
            $(".select2-container--default .select2-results > .select2-results__options")[0].style = "max-height:400px";
        })
      )
      .catch(Error => {
          console.warn("select2 is not available")
      });

    /**
     * Initializes select2 on the webpage for elements with class attribute 'mir-select-searchable'.
     * */
    async function select2() {
        if (typeof jQuery.fn.select2 === "function") {
            $(".mir-select-searchable").select2();
        } else {
            throw new Error("select2 not available");
        }
    }


    function pickDatePickerFormatAndAdd(elm) {
        if (moment($(elm).val(), "YYYY-MM-DD", true).isValid()){
            addDatePicker(elm, 0);
        }
        else {
            if (moment($(elm).val(), "YYYY-MM", true).isValid()){
                addDatePicker(elm, 1);
            }
            else {
                addDatePicker(elm, 2);
            }
        }
    }

    function addDatePicker(elm, startView, format) {
        $(elm).datepicker({
            format: {
                toDisplay: function (date, format, language) {
                    var d = moment(date);
                    return d.format("YYYY-MM-DD");
                },
                toValue: function (date, format, language) {
                    var d = moment.utc(date, ["YYYY-MM-DD", "YYYY-MM", "YYYY"]);
                    return d.startOf('day').toDate();
                }
            },
            startView: startView,
            clearBtn: true,
            todayBtn: "linked",
            language: $("html").attr("lang"),
            forceParse: false,
            autoclose: true,
            todayHighlight: true,
            daysOfWeekHighlighted: "0"
        }).on("changeYear", function(e) {
            $(this).val(moment(e.date).format("YYYY"))
        }).on("changeMonth", function(e) {
            $(this).val(moment(e.date).format("YYYY-MM"));
        }).on("hide", function(e) {
            updateDatePicker($(this));
        });
    }

    function updateDatePicker(elm) {
        $(elm).datepicker("remove");
        $(elm).off("hide");
        pickDatePickerFormatAndAdd($(elm));
    }

    function getDate(parent, point) {
        if (point == "simple") {
            return $(parent).find(".date-changeable:not('.d-none') .date-simple input").val();
        }
        return $(parent).find(".date-changeable:not('.d-none') .date-range input").filter(function () {
            return $(this).attr("data-point") == point;
        }).val();
    }

    function setDate(parent, point, date) {
        if (point == "simple") {
            $(parent).find(".date-changeable:not('.d-none') .date-simple input").val(date);
            updateDatePicker($(parent).find(".date-changeable:not('.d-none') .date-simple input"));
        }
        var elm = $(parent).find(".date-changeable:not('.d-none') .date-range input").filter(function () {
            return $(this).attr("data-point") == point;
        });
        $(elm).val(date);
        updateDatePicker(elm);

    }

    function setDateToRange(elm){
        $(elm).find("div.date-range").removeClass("d-none");
        $(elm).find("div.date-simple").addClass("d-none");
        $(elm).attr("data-format", "range");
        var input = $(elm).find("div.date-simple > input");
        var simpleVal = $(input).val();
        if (simpleVal != "") {
            $(elm).find("div.date-range > input.startDate").val(simpleVal);
            $(input).val("");
            updateDatePicker($(elm).find("div.date-range > input.startDate"));
            updateDatePicker($(input));
        }
        var endDate = $(input).attr("data-end");
        if(endDate != "" && endDate != undefined){
            $(elm).find("div.date-range > input.endDate").val(endDate);
            updateDatePicker($(elm).find("div.date-range > input.endDate"));
        }
    }

    function setDateToSimple(elm){
        $(elm).find("div.date-simple").removeClass("d-none");
        $(elm).find("div.date-range").addClass("d-none");
        $(elm).attr("data-format", "simple");
        var inputStart = $(elm).find("div.date-range > input.startDate");
        var inputEnd = $(elm).find("div.date-range > input.endDate");
        var startVal = $(inputStart).val();
        var endVal = $(inputEnd).val();
        if (startVal != "") {
            $(elm).find("div.date-simple > input").val(startVal);
            $(inputStart).val("");
            updateDatePicker($(elm).find("div.date-simple > input"));
            updateDatePicker($(inputStart));
        }
        if(endVal != ""){
            $(elm).find("div.date-simple > input").attr("data-end", endVal);
            $(inputEnd).val("");
            updateDatePicker($(inputEnd));
        }
    }

    function rejumpToLocationHash(el) {
        if(window.location.hash!==null && window.location.hash!==""){
            let element = document.querySelector(window.location.hash);
            if(element!==null){
                if(el != null){
                    if(el.parent().find(window.location.hash).length>0){
                        element.scrollIntoView(true);
                    }
                } else {
                    element.scrollIntoView(true);
                }
            }
        }
    }

    if ($(".personExtended-container input:text[value='']").length > 0) {
        let el = $(".personExtended-container input:not(:text[value=''])").closest(".personExtended-container").removeClass("d-none").prev();
        el.removeClass("hiddenDetail");
        rejumpToLocationHash(el);
    }

    if ($(".dateExtended-container input:not(:text[value=''])").length > 0) {
        $(".dateExtended-container").closest(".dateExtended-container").removeClass("d-none").prev().removeClass("d-none");
        rejumpToLocationHash();
    }

    if ($(".date-select").length > 0) {
        $(".date-select").each(function() {
            var type = $(this).val();
            var parent = $(this).closest(".form-group");
            $(parent).find(".date-changeable").addClass("d-none");
            $(parent).find(".date-changeable").filter(function () {
                return $(this).attr("data-type") == type;
            }).removeClass("d-none");
        });
    }

    if ($("div.date-format").length > 0) {
        $("div.date-format").each(function() {
            notEmpty = false;
            $(this).find("div.date-range input").each(function(){
                if($(this).val() != '') {
                    notEmpty = true;
                }
            });
            if (notEmpty) {
                setDateToRange($(this));
            }
        });
    }

    function setLabelForClassification(parent) {
        $.ajax({
            url: webApplicationBaseURL + 'servlets/solr/select',
            data: {
                    q: optionsToQuery(parent),
                    fq: 'classification:rfc5646',
                    wt: 'json',
                    core: 'classification'
            },
            dataType: 'json'
        }).done(function(data) {
            $.each(data.response.docs, function (i, cat) {
                let text = cat['label.' + $("html").attr("lang")][0];
                if (text === undefined) {
                    text = cat['label.en'][0]
                }
                getOptionWithVal(parent, cat.category).html(text);
            });
            setSelect2(parent);
        });
    }

    function setSelect2(elm) {
        $(elm).select2({
            ajax: {
                url: webApplicationBaseURL + 'servlets/solr/select',
                data: function (params) {
                    let term = (params.term !== "") ? params.term : undefined;
                    return {
                        q: 'label.en:' + term + "* OR " + 'label.de:' + term + "* OR " + 'category:' + term + "* OR " + 'label.x-bibl:' + term + "* OR " + 'label.x-term:'  + term,
                        fq: 'classification:rfc5646',
                        wt: 'json',
                        core: 'classification'
                    };
                },
                dataType: 'json',
                processResults: function (data) {
                    let res = {
                        results: $.map(data.response.docs, function(obj) {
                            let text = obj['label.' + $("html").attr("lang")];
                            if (text === undefined) {
                                text = obj['label.en'][0]
                            }
                            else {
                                text = text[0];
                            }
                            return { id: obj.category, text: text };
                        })
                    };
                    addDefautlLang(elm, res);
                    return res;
                },
            },
            minimumInputLength: 0,
            language: $("html").attr("lang")
        });
    }

    function addDefautlLang(elm, res) {
        $(elm).children().each(function (i, option) {
            let found = false;
            $.each(res.results, function (i, solrOption) {
                if (solrOption.id === $(option).val()) {
                    found = true;
                    return false;
                }
            });
            if (!found) {
                if ($(option).val() !== "") {
                    res.results.push({id: $(option).val(), text: $(option).html()})
                }
            }
        })
    }

    function setDefaultLang(elm) {
        let langs = $(elm).attr("data-langs").split(",");
        let dlang = $(elm).attr("data-dlang");
        if (!optionPresent(elm, dlang)) {
            $(elm).append(new Option(dlang, dlang, false, false));
        }
        $.each(langs, function (i, lang) {
            if (!optionPresent(elm, lang)) {
                $(elm).append(new Option(lang, lang, false, false));
            }
        });
    }

    function optionPresent(elm, val) {
        return getOptionWithVal(elm, val).length !== 0;
    }

    function getOptionWithVal(elm, val) {
        return $(elm).find("option[value='" + val + "']");
    }

    function optionsToQuery(elm) {
        let query = [];
        $(elm).children().each(function (i, option) {
            if ($(option).val() !== "") {
                query.push('category:' + $(option).val());
            }
        });
        return query.join(" OR ");
    }

   $(".lang-select").each(function () {
       setDefaultLang($(this));
        if ($(this).children("option").length > 0) {
            setLabelForClassification($(this));
        }
        else {
            setSelect2($(this));
        }
    });

    $(document).popover({
        selector: "[data-toggle=popover]",
        container: "body",
        html: true,
        trigger: "focus"
    });

     // Enables the datetimepicker
     if (jQuery.fn.datepicker) {
         $('.datetimepicker').find('input').each( function(index, elm){
             pickDatePickerFormatAndAdd(elm);
         });
     }

     $("body").on("click", ".expand-item", function () {
         if($(this).attr("data-target")){
             $(this).closest(".form-group").next($(this).attr("data-target")).toggleClass("d-none");
         }
         else {
             $(this).closest("legend").toggleClass("hiddenDetail").next().toggleClass("d-none");
         }
         if($(this).hasClass("fa-chevron-down")) {
             $(this).removeClass("fa-chevron-down");
             $(this).addClass("fa-chevron-up");
         }
         else {
             $(this).removeClass("fa-chevron-up");
             $(this).addClass("fa-chevron-down");
         }
     });

     $("body").on("click", "div.date-selectFormat a.date-rangeOption", function (event) {
         event.preventDefault();
         setDateToRange($(this).closest("div.date-format"));
     });

     $("body").on("click", "div.date-selectFormat a.date-simpleOption", function (event) {
         event.preventDefault();
         setDateToSimple($(this).closest("div.date-format"));
     });

     $("body").on("change", ".date-select", function () {
         var type = $(this).val();
         var parent = $(this).closest(".form-group");
         var start = getDate(parent, "start");
         var end = getDate(parent, "end");
         var simple = getDate(parent, "simple");
         var format = $(parent).find(".date-changeable:not('.d-none') div.date-format").attr("data-format");
         setDate(parent, "start", "");
         setDate(parent, "end", "");
         setDate(parent, "simple", "");
         $(parent).find(".date-changeable").addClass("d-none");
         $(parent).find(".date-changeable").filter(function () {
             return $(this).attr("data-type") === type;
         }).removeClass("d-none");
         setDate(parent, "start", start);
         setDate(parent, "end", end);
         setDate(parent, "simple", simple);
         if (format === "simple") {
             setDateToSimple($(parent).find(".date-changeable:not('.d-none') div.date-format"));
         }
         if (format === "range") {
             setDateToRange($(parent).find(".date-changeable:not('.d-none') div.date-format"));
         }
     });

     $("body").on("focusout", ".personExtended-container input[name*='mods:nameIdentifier']:first", function() {
         if($(this).val() === "") {
             $(this).parents(".personExtended_box").find(".search-person .input-group > a").remove();
         }
     });
 });
