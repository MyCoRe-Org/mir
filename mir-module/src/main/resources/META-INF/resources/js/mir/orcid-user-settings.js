import { OrcidSettingsService } from './orcid.js';
import { fetchAccessToken } from './jwt.js';
import { OrcidUserSetttingsModalHandler } from './orcid-user-settings-modal-handler.js';

const baseUrl = window['webApplicationBaseURL'];

document.addEventListener('DOMContentLoaded', async () => {
  const accessToken = await fetchAccessToken(baseUrl);
  const userService = new OrcidSettingsService(baseUrl, accessToken);
  const orcidUserSetttingsModalHandler = new OrcidUserSetttingsModalHandler(
    userService,
    '#orcid-settings-modal',
    '#orcid-settings-form',
    '#save-orcid-settings-btn',
    '#orcid-missing-setting-alert',
  );

  document.getElementById('openSettingsModalBtn').addEventListener('click', (event) => {
    const orcid = event.currentTarget.dataset.orcid;
    if (orcid) {
      orcidUserSetttingsModalHandler.orcid = orcid;
      orcidUserSetttingsModalHandler.showModal();
    } else {
      console.error('ORCID iD is missing.');
    }
  });
});
