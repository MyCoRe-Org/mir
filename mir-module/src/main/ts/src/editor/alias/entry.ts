import { getBaseUrl } from '../../utils/config';

const RELATED_ITEM_SELECTOR = '.mir-related-item-search';
const REFRESH_DELAY = 300;

function getRelatedItemIds(): string[] {
  return Array.from(
    document.querySelectorAll<HTMLInputElement>(
      `${RELATED_ITEM_SELECTOR} input[name$='@xlink:href']`
    )
  )
    .map(input => input.value)
    .filter(id => id.includes('_mods_'));
}

/**
 * Fetches the paths the object is reachable with, without its own alias,
 * e.g. ['go/oa/journal/volume-1'].
 */
async function fetchPaths(relatedItemIds: string[]): Promise<string[]> {
  const url = new URL('rsc/mir/alias/paths', getBaseUrl());
  relatedItemIds.forEach(id => url.searchParams.append('relatedItem', id));
  const response = await fetch(url, { cache: 'no-store' });
  if (!response.ok) {
    throw new Error(`Could not load alias paths: ${response.status}`);
  }
  return (await response.json()) as string[];
}

function renderUrls(row: HTMLElement, urls: string[]): void {
  const items = urls.map(url => {
    const link = document.createElement('a');
    link.href = url;
    link.textContent = url;
    const item = document.createElement('li');
    item.append(link);
    return item;
  });
  row.querySelector('ul')?.replaceChildren(...items);
  row.hidden = urls.length === 0;
}

/**
 * Shows the URLs the object will be reachable with, built from the paths of
 * the related items and the alias part.
 */
function setupAliasUrls(container: HTMLElement): void {
  const aliasInput = container.querySelector<HTMLInputElement>(
    "input[id^='mir-aliaspart']"
  );
  const urlRow = container.querySelector<HTMLElement>('.generated-alias-urls');
  if (!aliasInput || !urlRow) {
    console.warn('Missing alias input or URL list in', container);
    return;
  }

  let paths: string[] = [];
  let refreshTimeout: number | undefined;

  const render = (): void => {
    const alias = aliasInput.value.trim();
    // without an alias the object is not reachable via an alias URL
    const urls = alias
      ? paths.map(path => new URL(`${path}/${alias}`, getBaseUrl()).toString())
      : [];
    renderUrls(urlRow, urls);
  };

  const refresh = async (): Promise<void> => {
    try {
      paths = await fetchPaths(getRelatedItemIds());
    } catch (error) {
      console.warn(error);
      paths = [];
    }
    render();
  };

  // collects changes in quick succession into one request
  const scheduleRefresh = (): void => {
    window.clearTimeout(refreshTimeout);
    refreshTimeout = window.setTimeout(refresh, REFRESH_DELAY);
  };

  aliasInput.addEventListener('input', render);
  // the related item modal updates the hidden xlink:href input and the text of the span next to it
  document.querySelectorAll(RELATED_ITEM_SELECTOR).forEach(element => {
    new MutationObserver(scheduleRefresh).observe(element, {
      childList: true,
      subtree: true,
      characterData: true,
    });
  });

  // scheduled as well, because the related item modal also updates the spans on page load
  scheduleRefresh();
}

document.addEventListener('DOMContentLoaded', () => {
  document
    .querySelectorAll<HTMLElement>('.mir-editor-alias-container')
    .forEach(setupAliasUrls);
});
