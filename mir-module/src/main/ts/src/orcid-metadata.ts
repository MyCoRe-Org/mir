import {
  getOrcidExportModalController,
  setupExportModalContoller,
} from './orcid/orcid-export-modal.helper';
import { setupStatusBadges } from './orcid/orcid-status-badge.helper';

const SELECTORS = {
  menu: 'div#mir-edit-div ul.dropdown-menu',
  menuItem: 'li#exportToOrcidMenuItem',
  openModalBtn: '#openExportToOrcidModal',
};

const appendMenuButton = (
  menu = document.querySelector<HTMLDivElement>(SELECTORS.menu),
  item = document.querySelector<HTMLLIElement>(SELECTORS.menuItem)
) => {
  if (menu && item) {
    menu.append(item);
  }
};

const setupOpenModalBtn = (
  openModalBtn = document.querySelector<HTMLButtonElement>(
    SELECTORS.openModalBtn
  )
) => {
  if (!openModalBtn) return;
  appendMenuButton();
  openModalBtn.addEventListener('click', (): void => {
    try {
      const { objectId } = openModalBtn.dataset;
      if (objectId) getOrcidExportModalController().open(objectId);
    } catch (error) {
      console.error('Error opening ORCID modal:', error);
    }
  });
};

document.addEventListener('DOMContentLoaded', (): void => {
  setupExportModalContoller();
  setupOpenModalBtn();
  setupStatusBadges();
});
