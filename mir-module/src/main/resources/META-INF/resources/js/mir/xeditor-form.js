$(document).ready(function() {
	
	  $(document).popover({
	    selector : "[data-toggle=popover]",
	    container : "body",
	    html : "true",
	    trigger: "focus"
	  });
	  
    // Enables the datetimepicker
    if (jQuery.fn.datepicker) {
      $('.datetimepicker').find('input').datepicker({
          format: "yyyy-mm-dd",
          clearBtn: true,
          language: $("html").attr("lang"),
          forceParse: false,
          autoclose: true,
          todayHighlight: true
      });
    };

    $("body").on("click", "fieldset .expand-item", function () {
        $(this).closest("legend").toggleClass("hiddenDetail").next().toggleClass("hidden");
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
        var format = $(parent).find(".date-changeable:not('.hidden') div.date-format").attr("data-format");
        setDate(parent, "start", "");
        setDate(parent, "end", "");
        setDate(parent, "simple", "");
        $(parent).find(".date-changeable").addClass("hidden");
        $(parent).find(".date-changeable").filter(function () {
            return $(this).attr("data-type") == type;
        }).removeClass("hidden");
        setDate(parent, "start", start);
        setDate(parent, "end", end);
        setDate(parent, "simple", simple);
        if (format == "simple") {
            setDateToSimple($(parent).find(".date-changeable:not('.hidden') div.date-format"));
        }
        if (format == "range") {
            setDateToRange($(parent).find(".date-changeable:not('.hidden') div.date-format"));
        }
    });

    function getDate(parent, point) {
        if (point == "simple") {
            return $(parent).find(".date-changeable:not('.hidden') .date-simple input").val();
        }
        return $(parent).find(".date-changeable:not('.hidden') .date-range input").filter(function () {
            return $(this).attr("data-point") == point;
        }).val();
    }

    function setDate(parent, point, date) {
        if (point == "simple") {
            $(parent).find(".date-changeable:not('.hidden') .date-simple input").val(date).datepicker('update');
        }
        $(parent).find(".date-changeable:not('.hidden') .date-range input").filter(function () {
            return $(this).attr("data-point") == point;
        }).val(date).datepicker('update');

    }

    function setDateToRange(elm){
        $(elm).find("div.date-range").removeClass("hidden");
        $(elm).find("div.date-simple").addClass("hidden");
        $(elm).attr("data-format", "range");
        var input = $(elm).find("div.date-simple > input");
        var simpleVal = $(input).val();
        if (simpleVal != "") {
            $(elm).find("div.date-range > input.startDate").val(simpleVal).datepicker('update');
            $(input).val("").datepicker('update');
        }
        var endDate = $(input).attr("data-end");
        if(endDate != "" && endDate != undefined){
            $(elm).find("div.date-range > input.endDate").val(endDate).datepicker('update');
        }
    }

    function setDateToSimple(elm){
        $(elm).find("div.date-simple").removeClass("hidden");
        $(elm).find("div.date-range").addClass("hidden");
        $(elm).attr("data-format", "simple");
        var inputStart = $(elm).find("div.date-range > input.startDate");
        var inputEnd = $(elm).find("div.date-range > input.endDate");
        var startVal = $(inputStart).val();
        var endVal = $(inputEnd).val();
        if (startVal != "") {
            $(elm).find("div.date-simple > input").val(startVal).datepicker('update');
            $(inputStart).val("").datepicker('update');
        }
        if(endVal != ""){
            $(elm).find("div.date-simple > input").attr("data-end", endVal);
            $(inputEnd).val("").datepicker('update');
        }
    }

    if ($(".personExtended-container input:text[value='']").length > 0) {
        $(".personExtended-container input:not(:text[value=''])").closest(".personExtended-container").removeClass("hidden").prev().removeClass("hiddenDetail");
    }

    if ($(".dateExtended-container input:not(:text[value=''])").length > 0) {
        $(".dateExtended-container").closest(".dateExtended-container").removeClass("hidden").prev().removeClass("hiddenDetail");
    }

    if ($(".date-select").length > 0) {
        $(".date-select").each(function() {
            var type = $(this).val();
            var parent = $(this).closest(".form-group");
            $(parent).find(".date-changeable").addClass("hidden");
            $(parent).find(".date-changeable").filter(function () {
                return $(this).attr("data-type") == type;
            }).removeClass("hidden");
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

});