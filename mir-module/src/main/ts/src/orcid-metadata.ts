import {
  getOrcidExportModalController,
  setupExportModalContoller,
} from './orcid/orcid-export-modal.helper';
import { setupStatusBadges } from './orcid/orcid-status-badge.helper';

const SELECTORS = {
  openModalBtn: '#openExportToOrcidModal',
};

const setupOpenModalBtn = (
  openModalBtn = document.querySelector<HTMLButtonElement>(
    SELECTORS.openModalBtn
  )
) => {
  if (!openModalBtn) return;
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
