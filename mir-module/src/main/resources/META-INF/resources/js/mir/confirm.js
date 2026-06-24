/*!
 * MIR Bootstrap 5 confirm dialog
 */
(function () {
  "use strict";

  const clickHandlers = new WeakMap();
  const defaultOptions = {
    text: "Are you sure?",
    title: "",
    confirmButton: "Yes",
    cancelButton: "Cancel",
    post: false,
    submitForm: false,
    confirmButtonClass: "btn-primary",
    cancelButtonClass: "btn-secondary",
    dialogClass: "modal-dialog",
    modalOptionsBackdrop: true,
    modalOptionsKeyboard: true
  };
  const dataOptionsMapping = {
    "title": "title",
    "text": "text",
    "confirm-button": "confirmButton",
    "submit-form": "submitForm",
    "cancel-button": "cancelButton",
    "confirm-button-class": "confirmButtonClass",
    "cancel-button-class": "cancelButtonClass",
    "dialog-class": "dialogClass",
    "modal-options-backdrop": "modalOptionsBackdrop",
    "modal-options-keyboard": "modalOptionsKeyboard"
  };

  function normalizeDataValue(value) {
    if (value === "true") {
      return true;
    }
    if (value === "false") {
      return false;
    }
    return value;
  }

  function readDataOptions(element) {
    const dataOptions = {};
    if (!element) {
      return dataOptions;
    }
    Object.entries(dataOptionsMapping).forEach(([attributeName, optionName]) => {
      const value = element.getAttribute("data-" + attributeName);
      if (value !== null) {
        dataOptions[optionName] = normalizeDataValue(value);
      }
    });
    return dataOptions;
  }

  function shouldSubmitForm(dataOptions, options) {
    return dataOptions.submitForm
      || (typeof dataOptions.submitForm === "undefined" && options.submitForm)
      || (typeof dataOptions.submitForm === "undefined"
        && typeof options.submitForm === "undefined"
        && window.MIRConfirm.options.submitForm);
  }

  function confirmDefault(event, settings, dataOptions, options) {
    if (shouldSubmitForm(dataOptions, options)) {
      const form = options.button && options.button.closest("form");
      if (form) {
        form.submit();
      }
      return;
    }

    const url = event && (typeof event === "string"
      ? event
      : options.button && options.button.getAttribute("href"));
    if (!url) {
      return;
    }
    if (settings.post) {
      const form = document.createElement("form");
      form.method = "post";
      form.action = url;
      form.className = "d-none";
      document.body.appendChild(form);
      form.submit();
    } else {
      window.location = url;
    }
  }

  function createElement(tagName, attributes, html) {
    const element = document.createElement(tagName);
    Object.entries(attributes || {}).forEach(([name, value]) => {
      element.setAttribute(name, value);
    });
    if (typeof html !== "undefined") {
      element.innerHTML = html;
    }
    return element;
  }

  function createModal(settings) {
    const modal = createElement("div", {
      class: "confirmation-modal modal fade",
      tabindex: "-1",
      role: "dialog"
    });
    const dialog = createElement("div", { class: settings.dialogClass });
    const content = createElement("div", { class: "modal-content" });
    const footer = createElement("div", { class: "modal-footer" });
    const confirmButton = createElement("button", {
      class: "confirm btn " + settings.confirmButtonClass,
      type: "button",
      "data-bs-dismiss": "modal"
    }, settings.confirmButton);

    modal.appendChild(dialog);
    dialog.appendChild(content);

    if (settings.title !== "") {
      const header = createElement("div", { class: "modal-header" });
      header.appendChild(createElement("h4", { class: "modal-title" }, settings.title));
      header.appendChild(createElement("button", {
        type: "button",
        class: "btn-close",
        "data-bs-dismiss": "modal",
        "aria-label": "Close"
      }));
      content.appendChild(header);
    }

    content.appendChild(createElement("div", { class: "modal-body" }, settings.text));
    footer.appendChild(confirmButton);

    if (settings.cancelButton) {
      footer.appendChild(createElement("button", {
        class: "cancel btn " + settings.cancelButtonClass,
        type: "button",
        "data-bs-dismiss": "modal"
      }, settings.cancelButton));
    }

    content.appendChild(footer);
    return modal;
  }

  window.MIRConfirm = {
    options: Object.assign({}, defaultOptions),

    bind: function (selector, options) {
      const elements = typeof selector === "string"
        ? document.querySelectorAll(selector)
        : selector;

      Array.prototype.forEach.call(elements, (element) => {
        const previousHandler = clickHandlers.get(element);
        if (previousHandler) {
          element.removeEventListener("click", previousHandler);
        }

        const handler = (event) => {
          event.preventDefault();
          window.MIRConfirm.show(Object.assign({ button: element }, options || {}), event);
        };
        clickHandlers.set(element, handler);
        element.addEventListener("click", handler);
      });
    },

    show: function (options, event) {
      if (document.querySelector(".confirmation-modal")) {
        return;
      }
      if (typeof bootstrap === "undefined" || typeof bootstrap.Modal === "undefined") {
        console.error("Bootstrap Modal is not available.");
        return;
      }

      const dataOptions = readDataOptions(options.button);
      const settings = Object.assign({}, defaultOptions, window.MIRConfirm.options, {
        confirm: function () {
          confirmDefault(event, settings, dataOptions, options);
        },
        cancel: function () {},
        button: null
      }, options, dataOptions);
      const modal = createModal(settings);
      const modalInstance = new bootstrap.Modal(modal, {
        backdrop: settings.modalOptionsBackdrop,
        keyboard: settings.modalOptionsKeyboard
      });

      modal.addEventListener("shown.bs.modal", function () {
        modal.querySelector(".confirm").focus();
      });
      modal.addEventListener("hidden.bs.modal", function () {
        modalInstance.dispose();
        modal.remove();
      });
      modal.querySelector(".confirm").addEventListener("click", function () {
        settings.confirm(settings.button);
      });
      const cancelButton = modal.querySelector(".cancel");
      if (cancelButton) {
        cancelButton.addEventListener("click", function () {
          settings.cancel(settings.button);
        });
      }

      document.body.appendChild(modal);
      modalInstance.show();
    }
  };
})();
