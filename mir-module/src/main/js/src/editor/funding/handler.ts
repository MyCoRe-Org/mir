import { Autocomplete } from '../autocomplete';
import { fetchFunder } from './crossref';
import { fetchFunding } from './openaire';
import { Funder, Funding } from './types';

function setupFundingAutocomplete(container: Element): void {
  const awardTitleInput =
    container.querySelector<HTMLInputElement>('input.award-title');
  const funderNameInput =
    container.querySelector<HTMLInputElement>('input.funder-name');
  const funderIdTypeInput = container.querySelector<HTMLInputElement>(
    'select.funder-id-type'
  );
  const funderIdValueInput = container.querySelector<HTMLInputElement>(
    'input.funder-id-value'
  );
  const awardNumberInput =
    container.querySelector<HTMLInputElement>('input.award-number');
  const awardUriInput =
    container.querySelector<HTMLInputElement>('input.award-uri');

  if (
    !awardTitleInput ||
    !funderNameInput ||
    !funderIdTypeInput ||
    !funderIdValueInput ||
    !awardNumberInput ||
    !awardUriInput
  ) {
    console.warn('One or more input fields are missing:', container);
    return;
  }

  new Autocomplete<Funding>(awardTitleInput, {
    fetchData: fetchFunding,
    getDisplayText: item => item.award.title,
    onItemSelected: item => {
      awardTitleInput.value = item.award.title;
      funderNameInput.value = item.funder.name;
      funderIdTypeInput.value = item.funder.id.type!;
      funderIdValueInput.value = item.funder.id.value;
      awardNumberInput.value = item.award.number;
      if (item.award?.uri) {
        awardUriInput.value = item.award.uri;
      }
    },
  });

  new Autocomplete<Funder>(funderNameInput, {
    fetchData: async query => {
      const items = await fetchFunder(query);
      return items.map(r => ({
        name: r.name,
        id: {
          type: 'Crossref Funder ID',
          value: r.uri,
        },
      }));
    },
    getDisplayText: item => item.name,
    onItemSelected: item => {
      funderNameInput.value = item.name;
      funderIdValueInput.value = item.id.value;
      funderIdTypeInput.value = item.id.type;
    },
  });
}

document.addEventListener('DOMContentLoaded', () => {
  document
    .querySelectorAll('.mir-funding-reference-container')
    .forEach(setupFundingAutocomplete);
});
