class UiHandler {
  static toggleElement(element, shouldShow) {
    if (element) element.classList.toggle('d-none', !shouldShow);
  }

  static setDisabled(element, isDisabled) {
    if (element) element.disabled = isDisabled;
  }
}

export { UiHandler };