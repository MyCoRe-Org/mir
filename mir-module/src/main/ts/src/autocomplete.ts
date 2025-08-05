export type AutocompleteOptions<T> = {
  fetchData: (query: string, signal: AbortSignal) => Promise<T[]>;
  getDisplayText: (item: T) => string;
  onItemSelected: (item: T) => void;
  debounceMs?: number;
};

const DEFAULT_DEBOUNCE_MS = 300;

export class Autocomplete<T> {
  private input: HTMLInputElement;
  private dropdown: HTMLUListElement;
  private parent: HTMLElement;
  private fetchData: (query: string, signal: AbortSignal) => Promise<T[]>;
  private buildItemText: (item: T) => string;
  private onItemSelected: (item: T) => void;
  private debounceMs: number;

  private currentAbortController: AbortController | null = null;

  constructor(input: HTMLInputElement, options: AutocompleteOptions<T>) {
    this.input = input;
    this.fetchData = options.fetchData;
    this.buildItemText = options.getDisplayText;
    this.onItemSelected = options.onItemSelected;
    this.debounceMs = options.debounceMs ?? DEFAULT_DEBOUNCE_MS;

    this.dropdown = document.createElement('ul');
    this.dropdown.classList.add('dropdown-menu', 'position-absolute');
    this.dropdown.style.display = 'none';
    this.dropdown.style.width = `${input.offsetWidth}px`;

    const parent = input.parentElement;
    if (!parent) throw new Error('Input must have a parent element.');
    this.parent = parent;
    this.parent.appendChild(this.dropdown);
    this.parent.style.position = 'relative';

    this.bindEvents();
  }

  private bindEvents(): void {
    let timeoutId: number | null = null;

    const handler = async () => {
      const query = this.input.value.toLowerCase();
      this.clearDropdown();

      if (!query) return;

      if (this.currentAbortController) {
        this.currentAbortController.abort();
      }
      this.currentAbortController = new AbortController();
      const signal = this.currentAbortController.signal;

      try {
        this.performFetch(query, signal);
      } catch (error) {
        if (error instanceof DOMException && error.name === 'AbortError') {
          return;
        }
        if (error instanceof Error) {
          console.error('Autocomplete fetch error:', error.message);
        } else {
          console.error('Unknown error:', error);
        }
      }
    };

    this.input.addEventListener('input', () => {
      if (this.debounceMs > 0) {
        if (timeoutId !== null) {
          clearTimeout(timeoutId);
        }
        timeoutId = window.setTimeout(handler, this.debounceMs);
      } else {
        handler();
      }
    });

    document.addEventListener('click', e => {
      const target = e.target as HTMLElement;
      if (!this.input.contains(target) && !this.dropdown.contains(target)) {
        this.clearDropdown();
      }
    });
  }

  private async performFetch(
    query: string,
    signal: AbortSignal
  ): Promise<void> {
    const items = await this.fetchData(query, signal);
    items.forEach(item => {
      const li = document.createElement('li');
      li.classList.add('dropdown-item', 'text-wrap');
      li.textContent = this.buildItemText(item);
      li.addEventListener('click', () => {
        this.onItemSelected(item);
        this.clearDropdown();
      });
      this.dropdown.appendChild(li);
    });
    this.dropdown.style.display = 'block';
  }

  private clearDropdown(): void {
    this.dropdown.innerHTML = '';
    this.dropdown.style.display = 'none';
  }
}
