document.addEventListener("DOMContentLoaded", function () {
    (function (factory) {
        const dependencies = {
            jQuery: typeof jQuery !== 'undefined' ? jQuery : null,
            moment: typeof moment !== 'undefined' ? moment : null,
            bootstrap: typeof bootstrap !== 'undefined' ? bootstrap : null,
            bootstrapDatepicker: typeof $.fn.datepicker !== 'undefined' ? $.fn.datepicker : null

        };
        const missingDependencies = Object.keys(dependencies)
            .filter((key) => dependencies[key] === null)
            .map((key) => key);

        if (missingDependencies.length > 0) {
            console.error(
                "The plugin cannot load because the following dependencies are missing:\n" +
                missingDependencies.join("\n")
            );
            return;
        }
        if (typeof define === 'function' && define.amd) {
            define(['jquery'], factory);
        } else if (typeof exports === 'object') {
            factory(require('jquery'));
        } else {
            factory(jQuery);
        }

    }(function ($) {
            $.fn.timepicker = function (options) {
                return this.each(function () {
                    const timepicker = new TimePicker(this, options);
                    $(this).data('timepicker', timepicker);
                });
            };
            $.fn.timepicker.localisation = {
                en: {
                    timeTxt: "Select Time",
                    calenderTxt: "Calender"
                }
            }

            function TimePicker(element, options) {
                this.$element = $(element);
                TimePicker.DEFAULTS.language = this.$element.datepicker().data().datepicker.o.language;
                TimePicker.DEFAULTS.bootstrapDatepicker = this.$element.datepicker();
                TimePicker.dateTimeDate = this.$element.datepicker().data().datepicker.viewDate;
                this.options = $.extend({}, TimePicker.DEFAULTS, options);
                this.date = $.extend({}, TimePicker.date);
                this.init();
            }

            TimePicker.DEFAULTS = {
                pattern: 'YYYY-MM-DDTHH:mm:ss'
            };

            TimePicker.prototype.init = function () {
                this.options.timeformat = setTimeFormat(this.options.pattern);
                this.modifyDatepicker();
                this.createTimePickerUI();
                this.bindEvents();
            };
            TimePicker.prototype.createTimePickerUI = function () {
                let $timepickerContainer = $('<span class="timepicker-clock" style="display: contents">');
                let $incrementRow = $('<tr>');
                $('<td><button class="btn btn-sm btn-timepicker" data-action="incrementHours">' +
                    '<i class="fas fa-arrow-up"></i></button></td>').appendTo($incrementRow);
                $('<td class="separator"></td>').appendTo($incrementRow);
                $('<td><button class="btn btn-sm btn-timepicker" data-action="incrementMinutes">' +
                    '<i class="fas fa-arrow-up"></i></button></td>').appendTo($incrementRow);
                $('<td class="separator"></td>').appendTo($incrementRow);
                $('<td><button class="btn btn-sm btn-timepicker" data-action="incrementSeconds">' +
                    '<i class="fas fa-arrow-up"></i></button></td>').appendTo($incrementRow);

                let $timeRow = $('<tr>');
                $('<td class="timepickertext timepicker-hour" data-action="showHours">00</td>').appendTo($timeRow);
                $('<td class="separator timepickertext">:</td>').appendTo($timeRow);
                $('<td class="timepickertext timepicker-minute" data-action="showMinutes">00</td>').appendTo($timeRow);
                $('<td class="separator timepickertext">:</td>').appendTo($timeRow);
                $('<td class="timepickertext timepicker-second" data-action="showSeconds">00</td>').appendTo($timeRow);

                let $decrementRow = $('<tr>');
                $('<td><button class="btn btn-sm btn-timepicker" data-action="decrementHours">' +
                    '<i class="fas fa-arrow-down"></i></button></td>').appendTo($decrementRow);
                $('<td class="separator"></td>').appendTo($decrementRow);
                $('<td><button class="btn btn-sm btn-timepicker" data-action="decrementMinutes">' +
                    '<i class="fas fa-arrow-down"></i></button></td>').appendTo($decrementRow);
                $('<td class="separator"></td>').appendTo($decrementRow);
                $('<td><button class="btn btn-sm btn-timepicker" data-action="decrementSeconds">' +
                    '<i class="fas fa-arrow-down"></i></button></td>').appendTo($decrementRow);

                $incrementRow.appendTo($timepickerContainer);
                $timeRow.appendTo($timepickerContainer);
                $decrementRow.appendTo($timepickerContainer);
                this.$timepickerContainer = $timepickerContainer;
                this.options.bootstrapDatepicker
                    .data().datepicker.picker
                    .find('.datepicker-time tbody')
                    .html($timepickerContainer[0]);
            };

            TimePicker.prototype.bindEvents = function () {
                let that = this;
                let datepicker = that.options.bootstrapDatepicker;
                let minViewMode = datepicker.data().datepicker.o.minViewMode;
                let picker = datepicker.data().datepicker.picker;
                this.$element.on('input', function () {
                    that.handleInput();
                });
                this.$timepickerContainer.on('click', '.btn[data-action]', function (e) {
                    that.handleButtonClick(e);
                });
                picker.on('click', '.time', function () {
                    datepicker.datepicker('setViewMode', 5);
                });
                picker.on('click', '.calender', function () {
                    datepicker.datepicker('setViewMode', minViewMode);
                });
                picker.on('click', '.today-tp', function () {
                    $(that.$element[0]).val(moment().format(that.options.pattern));
                    that.date.dateTimeDate = new Date();
                    datepicker.data().datepicker.viewDate.setTime(that.date.dateTimeDate.getTime());
                    that.setTimeComponents(that.date.dateTimeDate);
                });

                picker.on('click', '.clear', function () {
                    that.setTimeComponents(new Date(new Date().setHours(0, 0, 0, 0)));
                });
            };

            TimePicker.prototype.handleInput = function () {
                let dateTimeInput = new Date(this.$element.val());
                if (!isNaN(dateTimeInput.getDate())) {
                    this.setTimeComponents(dateTimeInput);
                    this.date = {
                        dateTimeDate: new Date(dateTimeInput),
                    };
                }
            }
            TimePicker.prototype.setTimeComponents = function (date) {
                this.$timepickerContainer.find('.timepicker-hour')
                    .text(date.getHours().toString().padStart(2, '0'));
                this.$timepickerContainer.find('.timepicker-minute')
                    .text(date.getMinutes().toString().padStart(2, '0'));
                this.$timepickerContainer.find('.timepicker-second')
                    .text(date.getSeconds().toString().padStart(2, '0'));
            };


            TimePicker.prototype.modifyDatepicker = function () {
                const datepicker = this.options.bootstrapDatepicker;
                const viewModes = datepicker.datepicker.DPGlobal.viewModes;
                const language = this.options.language;
                let timeTxt, calenderTxt;
                if ($.fn.timepicker.localisation[language]) {
                    const localisation = $.fn.timepicker.localisation[language];
                    timeTxt = localisation.timeTxt;
                    calenderTxt = localisation.calenderTxt;
                } else {
                    const defaultLocalisation = $.fn.timepicker.localisation["en"];
                    timeTxt = defaultLocalisation.timeTxt;
                    calenderTxt = defaultLocalisation.calenderTxt;
                    console.warn("No language configuration was found. Setting back to default language");
                }
                if (viewModes.length <= 5) {
                    viewModes.push({
                        names: ['time', 'time'],
                        clsName: 'time'
                    });
                }
                const dPicker = datepicker.data().datepicker.picker;
                const tempDiv = document.createElement('div');
                tempDiv.innerHTML = dPicker.html();
                tempDiv.querySelectorAll('.today').forEach(element => {
                    element.classList.remove('today');
                    element.classList.add('today-tp');
                });
                const tfootElement = tempDiv.querySelector('tfoot');
                const tfootElementCalender =
                    tfootElement.innerHTML
                    + '<th colSpan="7" class="calender" style="display: table-cell;">'
                    + calenderTxt + '</th>';
                const tfootElementClock =
                    '<th colSpan="7" class="time" style="display: table-cell;">'
                    + timeTxt
                    + '</th>';
                tempDiv.querySelectorAll('tfoot').forEach
                (footerElement => footerElement.innerHTML += tfootElementClock);
                addTimepickerWindow(tempDiv, tfootElementCalender);
                datepicker.data().datepicker.picker.html(tempDiv.innerHTML);

                function addTimepickerWindow(tempDiv, tfootElementCalender) {
                    const newEl = document.createElement('div');
                    newEl.style.display = 'none';
                    newEl.classList.add('datepicker-time');
                    newEl.innerHTML =
                        '<table>' +
                        '<thead>' +
                        '<tr>' +
                        '<th style="width:20%"></th>' +
                        '<th style="width:20%"></th>' +
                        '<th style="width:20%"></th>' +
                        '<th style="width:20%"></th>' +
                        '<th style="width:20%"></th>' +
                        '</tr>' +
                        '</thead>' +
                        '<tbody></tbody>' +
                        '<tfoot>' + tfootElementCalender + '</tfoot>' +
                        '</table>';

                    tempDiv.appendChild(newEl);
                }
            }

            TimePicker.prototype.handleButtonClick = function (e) {
                if (this.date.dateTimeDate !== undefined) {
                    $(this.options.bootstrapDatepicker).data().datepicker.viewDate.setHours(this.date.dateTimeDate.getHours());
                    $(this.options.bootstrapDatepicker).data().datepicker.viewDate.setMinutes(this.date.dateTimeDate.getMinutes());
                    $(this.options.bootstrapDatepicker).data().datepicker.viewDate.setSeconds(this.date.dateTimeDate.getSeconds());

                }
                let datePickerDateTime = $(this.options.bootstrapDatepicker).data().datepicker.viewDate;
                const $target = $(e.currentTarget);
                const $hourElement = this.$timepickerContainer.find('.timepicker-hour');
                const $minuteElement = this.$timepickerContainer.find('.timepicker-minute');
                const $secondElement = this.$timepickerContainer.find('.timepicker-second');
                let currentMinute = parseInt($minuteElement.text(), 10);
                let currentSecond = parseInt($secondElement.text(), 10);
                let currentHour = parseInt($hourElement.text(), 10);
                const action = $target.data('action');

                switch (action) {
                    case 'incrementHours':
                        currentHour = (currentHour + 1) % 24;
                        datePickerDateTime.setHours(currentHour);

                        break;
                    case 'decrementHours':
                        currentHour = (currentHour - 1 + 24) % 24;
                        datePickerDateTime.setHours(currentHour);

                        break;
                    case 'incrementMinutes':
                        currentMinute = (currentMinute + 1) % 60;
                        if (currentMinute === 0) {
                            currentHour = (currentHour + 1) % 24;
                            datePickerDateTime.setHours(currentHour);
                        }
                        datePickerDateTime.setMinutes(currentMinute);
                        break;
                    case 'decrementMinutes':
                        currentMinute = (currentMinute - 1 + 60) % 60;
                        if (currentMinute === 59) {
                            currentHour = (currentHour - 1 + 24) % 24;
                            datePickerDateTime.setHours(currentHour);
                        }
                        datePickerDateTime.setMinutes(currentMinute);
                        break;
                    case 'incrementSeconds':
                        currentSecond = (currentSecond + 1) % 60;
                        if (currentSecond === 0 && currentMinute === 59) {
                            currentHour = (currentHour + 1) % 24;
                            datePickerDateTime.setHours(currentHour);
                        }
                        if (currentSecond === 0) {
                            currentMinute = (currentMinute + 1) % 60;
                            datePickerDateTime.setMinutes(currentMinute);
                        }
                        datePickerDateTime.setSeconds(currentSecond);
                        break;
                    case 'decrementSeconds':
                        currentSecond = (currentSecond - 1 + 60) % 60;
                        if (currentSecond === 59 && currentMinute === 0) {
                            currentHour = (currentHour - 1 + 24) % 24;
                            datePickerDateTime.setHours(currentHour);
                        }
                        if (currentSecond === 59) {
                            currentMinute = (currentMinute - 1 + 60) % 60;
                            datePickerDateTime.setMinutes(currentMinute);
                        }
                        datePickerDateTime.setSeconds(currentSecond);
                        break;
                }
                if (this.options.timeformat === 12) {
                    $hourElement.text((datePickerDateTime.getHours() % 12 || 12).toString().padStart(2, '0'));
                } else {
                    $hourElement.text(datePickerDateTime.getHours().toString().padStart(2, '0'));
                }
                $minuteElement.text(datePickerDateTime.getMinutes().toString().padStart(2, '0'));
                $secondElement.text(datePickerDateTime.getSeconds().toString().padStart(2, '0'));
                this.$element[0].value = moment(datePickerDateTime).format(this.options.pattern);
                this.date.dateTimeDate= datePickerDateTime;
            };

            function setTimeFormat(pattern) {
                let isTwentyFourHours = pattern.includes("h") ||
                (
                    moment("24", pattern)._locale._longDateFormat[pattern] &&
                    moment("24", pattern)._locale._longDateFormat[pattern].includes('h')) ?
                    12 : 24;
                return isTwentyFourHours;
            }
        }
    ));
});