import getConfigService from '../config/config.js';
import getAuthTokenService from '../auth/auth.js';
import { MIROrcidUserService } from './orcid.js';
import { OrcidUserSetttingsModalHandler } from './orcid-user-settings-modal-handler.js';

let settingsModalHandlerInstance = null;

const createSettingsModalHandler = async () => {
  const accessToken = await getAuthTokenService().retrieveToken();
  const userService = new MIROrcidUserService(getConfigService().getBaseUrl(), accessToken);
  return new OrcidUserSetttingsModalHandler(
    userService,
    '#orcid-settings-modal',
    '#orcid-settings-form',
    '#save-orcid-settings-btn',
    '#orcid-missing-setting-alert',
  );
};

const getSettingsModalHandlerInstance = async () => {
  if (!settingsModalHandlerInstance) {
    settingsModalHandlerInstance = await createSettingsModalHandler();
  }
  return settingsModalHandlerInstance;
};

const handleOpenModal = async (event) => {
  const { orcid } = event.currentTarget.dataset;
  if (!orcid) {
    console.error('ORCID iD is missing.');
    return;
  }
  const modalHandler = await getSettingsModalHandlerInstance();
  modalHandler.orcid = orcid;
  modalHandler.showModal();
};

const initSettingsModal = () => {
  const openModalButton = document.getElementById('openSettingsModalBtn');
  if (openModalButton) {
    openModalButton.addEventListener('click', handleOpenModal);
  } else {
    console.error('Modal button not found');
  }
};

document.addEventListener('DOMContentLoaded', initSettingsModal);