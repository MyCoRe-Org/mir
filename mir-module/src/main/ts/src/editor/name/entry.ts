import { Autocomplete } from '../../autocomplete';
import { Affiliation } from './affiliation/types';
import { fetchAffiliation } from './affiliation/ror';

function setupAffiliationPicker(container: HTMLElement): void {
  const textInput =
    container.querySelector<HTMLInputElement>('input[type="text"]');
  const hiddenInput = container.querySelector<HTMLInputElement>(
    'input[type="hidden"]'
  );
  const badge = container.querySelector<HTMLElement>('[data-badge]');
  const badgeLabel = container.querySelector<HTMLElement>('[data-badge-label]');

  if (!textInput || !hiddenInput) {
    console.error('affiliation-picker: text and hidden id inputs are required');
    return;
  }

  const nameInput = textInput!;
  const idInput = hiddenInput!;

  function setAffiliation(item: Affiliation) {
    nameInput.value = item.name;
    idInput.value = item.id;
    if (badgeLabel) {
      badgeLabel.textContent = 'ROR';
      badgeLabel.title = item.id;
    }
    container.classList.add('is-locked');
    nameInput.readOnly = true;
  }

  function clearAffiliation() {
    idInput.value = '';
    container.classList.remove('is-locked');
    nameInput.readOnly = false;
    nameInput.focus();
    nameInput.select();
  }

  if (idInput.value) {
    setAffiliation({ id: idInput.value, name: nameInput.value });
  }

  new Autocomplete<Affiliation>(nameInput, {
    container: container,
    fetchData: fetchAffiliation,
    getDisplayText: item => item.name,
    onItemSelected: setAffiliation,
  });

  badge?.addEventListener('click', clearAffiliation);
}

function initAffiliationPicker(): void {
  document
    .querySelectorAll('.personExtended-container .mir-affiliation-picker')
    .forEach(el => setupAffiliationPicker(el as HTMLElement));
}

document.addEventListener('DOMContentLoaded', initAffiliationPicker);
