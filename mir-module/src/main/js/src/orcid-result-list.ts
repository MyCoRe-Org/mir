import {
  getOrcidExportModalController,
  setupExportModalContoller,
} from './orcid/orcid-export-modal.helper';
import { setupStatusBadges } from './orcid/orcid-status-badge.helper';

const OPEN_MODAL_SELECTOR = '.open-export-orcid-modal';

export const setupExportModalOpenBtns = (): void => {
  document.querySelectorAll<HTMLLIElement>(OPEN_MODAL_SELECTOR).forEach(el => {
    el.addEventListener('click', (): void => {
      try {
        const { objectId } = el.dataset;
        if (objectId) getOrcidExportModalController().open(objectId);
      } catch (error) {
        console.error('Error opening ORCID modal:', error);
      }
    });
  });
};

document.addEventListener('DOMContentLoaded', () => {
  setupExportModalContoller();
  setupExportModalOpenBtns();
  setupStatusBadges();
});
