import { Autocomplete } from '../autocomplete';
import { fetchFunder } from './crossref';
import { fetchFunding } from './openaire';
import { Funder, Funding } from './types';

function getRequiredElement<T extends HTMLElement>(
  container: Element,
  selector: string
): T {
  const el = container.querySelector<T>(selector);
  if (!el) {
    throw new Error(`Missing required element: ${selector}`);
  }
  return el;
}

function setupFundingContainer(container: Element): void {
  try {
    const awardTitleInput = getRequiredElement<HTMLInputElement>(
      container,
      'input.award-title'
    );
    const funderNameInput = getRequiredElement<HTMLInputElement>(
      container,
      'input.funder-name'
    );
    const funderIdTypeInput = getRequiredElement<HTMLSelectElement>(
      container,
      'select.funder-id-type'
    );
    const funderIdValueInput = getRequiredElement<HTMLInputElement>(
      container,
      'input.funder-id-value'
    );
    const awardNumberInput = getRequiredElement<HTMLInputElement>(
      container,
      'input.award-number'
    );
    const awardUriInput = getRequiredElement<HTMLInputElement>(
      container,
      'input.award-uri'
    );

    new Autocomplete<Funding>(awardTitleInput, {
      fetchData: fetchFunding,
      getDisplayText: item => item.award.title,
      onItemSelected: item => {
        awardTitleInput.value = item.award.title;
        funderNameInput.value = item.funder.name;
        funderIdTypeInput.value = item.funder.id.type;
        funderIdValueInput.value = item.funder.id.value;
        awardNumberInput.value = item.award.number;
        if (item.award.uri) {
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
  } catch (error) {
    console.warn('Error setting up funding autocomplete:', error);
    return;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  document
    .querySelectorAll('.mir-funding-reference-container')
    .forEach(setupFundingContainer);
});
