import {
  setupExportModalContoller,
  setupExportModalOpenBtns,
} from './orcid/orcid-export-modal.helper';
import { setupStatusBadges } from './orcid/orcid-status-badge.helper';

document.addEventListener('DOMContentLoaded', (): void => {
  setupExportModalContoller();
  setupExportModalOpenBtns();
  setupStatusBadges();
});
