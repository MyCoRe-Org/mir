export type AutocompleteOptions<T> = {
  fetchData: (query: string) => Promise<T[]>;
  getDisplayText: (item: T) => string;
  onItemSelected: (item: T) => void;
};

export class Autocomplete<T> {
  private input: HTMLInputElement;
  private dropdown: HTMLUListElement;
  private parent: HTMLElement;
  private fetchData: (query: string) => Promise<T[]>;
  private buildItemText: (item: T) => string;
  private onItemSelected: (item: T) => void;

  constructor(input: HTMLInputElement, options: AutocompleteOptions<T>) {
    this.input = input;
    this.fetchData = options.fetchData;
    this.buildItemText = options.getDisplayText;
    this.onItemSelected = options.onItemSelected;

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
    this.input.addEventListener('input', async () => {
      const query = this.input.value.toLowerCase();
      this.clearDropdown();

      if (!query) return;

      const items = await this.fetchData(query);
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
    });

    document.addEventListener('click', e => {
      const target = e.target as HTMLElement;
      if (!this.input.contains(target) && !this.dropdown.contains(target)) {
        this.clearDropdown();
      }
    });
  }

  private clearDropdown(): void {
    this.dropdown.innerHTML = '';
    this.dropdown.style.display = 'none';
  }
}
