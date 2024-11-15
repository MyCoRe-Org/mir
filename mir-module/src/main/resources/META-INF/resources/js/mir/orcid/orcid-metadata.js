import getConfigService from '../config/config.js';
import getAuthTokenService from '../auth/auth.js';
import { MIROrcidWorkService, MIROrcidUserService } from './orcid.js';
import { OrcidExportModalHandler } from './orcid-export-modal-handler.js';

const createOrcidExportModalHandler = async () => {
  const accessToken = await getAuthTokenService().retrieveToken();
  const baseUrl = getConfigService().getBaseUrl();
  const workService = new MIROrcidWorkService(baseUrl, accessToken);
  const userService = new MIROrcidUserService(baseUrl, accessToken);
  return new OrcidExportModalHandler(
    workService,
    userService,
    '#exportToOrcidModal',
    '#exportToOrcidBtn',
    '#orcidProfileSelect',
    '#alertDiv'
  );
};

let orcidExportModalHandlerInstance = null;

const getOrcidExportModalHandlerInstance = async () => {
  if (!orcidExportModalHandlerInstance) {
    orcidExportModalHandlerInstance = await createOrcidExportModalHandler();
  }
  return orcidExportModalHandlerInstance;
};

const initExportModal = async () => {
  const appendMenuButton = () => {
    const menu = document.querySelector('div#mir-edit-div ul.dropdown-menu');
    const item = document.querySelector('li#publishToOrcidMenuItem');
    menu.append(item);
  }

  const handleOpenModal = async (event) => {
    const button = event.originalTarget;
    const objectId = button.getAttribute('data-object-id');
    if (objectId) {
      const modalHandler = await getOrcidExportModalHandlerInstance();
      modalHandler.objectId = objectId;
      modalHandler.openModal();
    }
  };

  document.querySelector('#openPublishToOrcidModal').addEventListener('click', handleOpenModal);
  appendMenuButton();
};
document.addEventListener('DOMContentLoaded', initExportModal);