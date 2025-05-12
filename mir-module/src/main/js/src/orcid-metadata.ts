import { getOrcidExportModalHandler } from './orcid/orcid-export-modal-handler.helper';

const appendMenuButton = (): void => {
  const MENU_SELECTOR = 'div#mir-edit-div ul.dropdown-menu';
  const ITEM_SELECTOR = 'li#exportToOrcidMenuItem';
  const menu = document.querySelector<HTMLDivElement>(MENU_SELECTOR);
  const item = document.querySelector<HTMLLIElement>(ITEM_SELECTOR);
  if (menu && item) {
    menu.append(item);
  }
};

document.addEventListener('DOMContentLoaded', (): void => {
  const OPEN_MODAL_SELECTOR = '#openExportToOrcidModal';
  const openModalBtn =
    document.querySelector<HTMLButtonElement>(OPEN_MODAL_SELECTOR);
  if (!openModalBtn) return;
  appendMenuButton();
  openModalBtn.addEventListener('click', (): void => {
    try {
      const { objectId } = openModalBtn.dataset;
      if (objectId) getOrcidExportModalHandler().open(objectId);
    } catch (error) {
      console.error('Error opening ORCID modal:', error);
    }
  });
});
