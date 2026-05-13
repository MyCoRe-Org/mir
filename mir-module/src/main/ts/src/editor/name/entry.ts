import { Autocomplete } from '../../autocomplete';
import { Affiliation } from './affiliation/types';
import { fetchAffiliation } from './affiliation/ror';

function setupAffiliationPicker(container: Element): void {
  const textInput =
    container.querySelector<HTMLInputElement>('input[type="text"]');
  const idInput = container.querySelector<HTMLInputElement>(
    'input[type="hidden"]'
  );
  const badge = container.querySelector<HTMLElement>('[data-badge]');
  const badgeLabel = container.querySelector<HTMLElement>('[data-badge-label]');

  if (!textInput || !idInput) {
    console.error('affiliation-picker: text and hidden id inputs are required');
    return;
  }

  function setAffiliation(item: Affiliation) {
    textInput!.value = item.name;
    idInput!.value = item.id;
    if (badgeLabel) {
      badgeLabel.textContent = 'ROR';
      badgeLabel.title = item.id;
    }
    (container as HTMLElement).classList.add('is-locked');
    textInput!.readOnly = true;
  }

  function clearAffiliation() {
    idInput!.value = '';
    (container as HTMLElement).classList.remove('is-locked');
    textInput!.readOnly = false;
    textInput!.focus();
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

  badge?.addEventListener('click', clearAffiliation);
}

export function initAffiliationPicker(): void {
  document
    .querySelectorAll('.personExtended-container .mir-affiliation-picker')
    .forEach(setupAffiliationPicker);
}

document.addEventListener('DOMContentLoaded', initAffiliationPicker);
