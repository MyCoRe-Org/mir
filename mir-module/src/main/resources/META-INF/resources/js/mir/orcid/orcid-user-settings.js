import getConfigService from '../config/config.js';
import getAuthTokenService from '../auth/auth.js';
import { MIROrcidUserService } from './orcid.js';
import { OrcidUserSetttingsModalHandler } from './orcid-user-settings-modal-handler.js';

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
}

let settingsModalHandlerInstance = null;

const getSettingsModalHandlerInstance = async () => {
  if (!settingsModalHandlerInstance) {
    settingsModalHandlerInstance = await createSettingsModalHandler();
  }
  return settingsModalHandlerInstance;
};

const initSettingsModal = () => {
  const handleOpenModal = async (event) => {
    const orcid = event.currentTarget.dataset.orcid;
    if (orcid) {
      const modalHandler = await getSettingsModalHandlerInstance();
      modalHandler.orcid = orcid;
      modalHandler.showModal();
    } else {
      console.error('ORCID iD is missing.');
    }
  };
  document.getElementById('openSettingsModalBtn').addEventListener('click', handleOpenModal);
};
document.addEventListener('DOMContentLoaded', initSettingsModal);