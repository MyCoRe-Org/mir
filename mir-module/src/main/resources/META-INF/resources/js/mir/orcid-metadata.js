import { OrcidExportModalHandler } from './orcid-export-modal-handler.js';
import { OrcidService } from './orcid.js';
import { fetchAccessToken } from './jwt.js';

const baseUrl = window['webApplicationBaseURL'];

const initExportModal = async () => {
  const accessToken = await fetchAccessToken(baseUrl);
  const orcidService = new OrcidService(baseUrl, accessToken);
  const exportModalHandler = new OrcidExportModalHandler(
    orcidService,
    '#exportToOrcidModal',
    '#exportToOrcidBtn',
    '#orcidProfileSelect',
    '#alertDiv'
  );
  document.querySelector('#openPublishToOrcidModal').addEventListener('click', (event) => {
    const button = event.originalTarget;
    const objectId = button.getAttribute('data-object-id');
    if (objectId) {
      exportModalHandler.objectId = objectId;
      exportModalHandler.openModal();
    }
  });
  const menu = document.querySelector('div#mir-edit-div ul.dropdown-menu');
  const item = document.querySelector('li#publishToOrcidMenuItem');
  menu.append(item);
}

document.addEventListener('DOMContentLoaded', initExportModal);