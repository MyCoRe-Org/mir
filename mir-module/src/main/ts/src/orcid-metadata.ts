import {
  setupExportModalContoller,
  setupExportModalOpenBtns,
} from './orcid/orcid-export-modal.helper';
import { setupStatusBadges } from './orcid/orcid-status-badge.helper';

const SELECTORS = {
  menu: 'div#mir-edit-div ul.dropdown-menu',
  menuItem: 'li.mir-action-item-orcid-export',
};

const appendMenuItem = (
  menu = document.querySelector<HTMLUListElement>(SELECTORS.menu),
  item = document.querySelector<HTMLLIElement>(SELECTORS.menuItem)
) => {
  if (menu && item) {
    menu.append(item);
  }
};

document.addEventListener('DOMContentLoaded', (): void => {
  setupExportModalContoller();
  appendMenuItem();
  setupExportModalOpenBtns();
  setupStatusBadges();
});
