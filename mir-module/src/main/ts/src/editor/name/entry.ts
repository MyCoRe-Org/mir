import { Autocomplete } from '../../autocomplete';
import { Affiliation } from './affiliation/types';
import { fetchAffiliation } from './affiliation/ror';

function setupAffiliationPicker(container: Element): void {
  const textInput =
    container.querySelector<HTMLInputElement>('input[type="text"]');
  const idInput = container.querySelector<HTMLInputElement>(
    'input[type="hidden"]'
  );
  const badgeSlot = container.querySelector<HTMLElement>('[data-badge-slot]');
  const badgeLabel = container.querySelector<HTMLElement>('[data-badge-label]');
  const clearBtn =
    container.querySelector<HTMLButtonElement>('[data-badge-clear]');

  if (!textInput || !idInput) {
    console.error('affiliation-picker: text and hidden id inputs are required');
    return;
  }

  function setAffiliation(item: Affiliation) {
    textInput!.value = item.name;
    idInput!.value = item.id;
    if (badgeLabel) {
      badgeLabel.textContent = 'ROR';
      badgeLabel.title = `${item.name} (${item.id})`;
    }
    if (badgeSlot) {
      badgeSlot.classList.remove('d-none');
      textInput!.classList.remove('rounded-end');
      textInput!.classList.add('border-end-0');
    }
    textInput!.readOnly = true;
  }

  const initialValue = idInput.value
    ? ({ id: idInput.value, name: textInput.value } as Affiliation)
    : undefined;

  if (initialValue) setAffiliation(initialValue);

  new Autocomplete<Affiliation>(textInput, {
    container: container as HTMLElement,
    fetchData: fetchAffiliation,
    getDisplayText: item => item.name,
    onItemSelected: setAffiliation,
  });

  clearBtn?.addEventListener('click', () => {
    idInput.value = '';
    if (badgeSlot) {
      badgeSlot.classList.add('d-none');
      textInput.classList.remove('border-end-0');
      textInput.classList.add('rounded-end');
    }
    textInput.readOnly = false;
    textInput.focus();
  });
}

export function initAffiliationPicker(): void {
  document
    .querySelectorAll('.personExtended-container .mir-affiliation-picker')
    .forEach(setupAffiliationPicker);
}

document.addEventListener('DOMContentLoaded', initAffiliationPicker);
