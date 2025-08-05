import { Autocomplete } from '../../autocomplete';
import { fetchFunder } from './crossref';
import { fetchProjectByTitle } from './openaire';
import { Funder, Project } from './types';

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

function setupProjectAutocomplete(container: Element): void {
  try {
    const titleInput = getRequiredElement<HTMLInputElement>(
      container,
      'input.project-title'
    );
    const idInput = getRequiredElement<HTMLInputElement>(
      container,
      'input.project-id'
    );
    const uriInput = getRequiredElement<HTMLInputElement>(
      container,
      'input.project-uri'
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
    new Autocomplete<Project>(titleInput, {
      fetchData: fetchProjectByTitle,
      getDisplayText: item => item.title,
      onItemSelected: item => {
        titleInput.value = item.title;
        funderNameInput.value = item.funder?.name ?? '';
        funderIdTypeInput.value = item.funder?.id.type ?? '';
        funderIdValueInput.value = item.funder?.id.value ?? '';
        idInput.value = item.id;
        uriInput.value = item.uri ?? '';
      },
    });

    new Autocomplete<Funder>(funderNameInput, {
      fetchData: fetchFunder,
      getDisplayText: item => item.name,
      onItemSelected: item => {
        funderNameInput.value = item.name;
        funderIdValueInput.value = item.id.value;
        funderIdTypeInput.value = item.id.type;
      },
    });
  } catch (error) {
    console.warn('Error setting up project autocomplete:', error);
    return;
  }
}

export function initProjectAutocomplete(): void {
  document
    .querySelectorAll('.mir-editor-project-container')
    .forEach(setupProjectAutocomplete);
}

document.addEventListener('DOMContentLoaded', initProjectAutocomplete);
