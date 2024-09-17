export class UiHandler {
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

export const getElementByIdOrThrow = <T extends HTMLElement>(id: string): T => {
  const element = document.getElementById(id);
  if (!element) throw new Error(`Element with id ${id} not found`);
  return element as T;
};
