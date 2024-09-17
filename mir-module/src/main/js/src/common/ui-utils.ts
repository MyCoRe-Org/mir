class UiHandler {
  static toggleElement(element: HTMLElement, shouldShow: boolean) {
    element.classList.toggle('d-none', !shouldShow);
  }

  static setDisabled(
    e: HTMLInputElement | HTMLButtonElement | HTMLSelectElement,
    isDisabled: boolean
  ) {
    e.disabled = isDisabled;
  }
}

export { UiHandler };
