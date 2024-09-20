const fetchAccessToken = async (webApplicationBaseUrl) => {
  const response = await fetch(`${webApplicationBaseUrl}rsc/jwt`);
  if (!response.ok) {
    throw new Error('Failed to fetch JWT for current user.');
  }
  const result = await response.json();
  if (!result.login_success) {
    throw new Error('Login failed');
  }
  return result.access_token;
}

const fetchOrcidUserSettings = async (webApplicationBaseUrl, accessToken, orcid) => {
  const response = await fetch(`${webApplicationBaseUrl}api/orcid/v1/${orcid}/user-properties`, {
    headers: { Authorization: `Bearer ${accessToken}`},
  });
  if (!response.ok) {
    throw new Error(`Failed to fetch ORCID user settings for ${orcid}.`);
  }
  return await response.json();
};

const updateOrcidUserSettings = async (webApplicationBaseUrl, accessToken, orcid, userSettings) => {
  const response = await fetch(`${webApplicationBaseUrl}api/orcid/v1/${orcid}/user-properties`, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(userSettings),
  });
  if (!response.ok) {
    throw new Error(`Failed to update ORCID user settings for ${orcid}.`);
  }
};

const webApplicationBaseUrl = window['webApplicationBaseURL'];

document.addEventListener('DOMContentLoaded', () => {
  const modalElement = document.querySelector('#orcid-settings-modal');
  const alertElement = document.querySelector('#orcid-settings-container #orcid-missing-setting-alert');
  const settingsMapping = [
    { key: 'createFirstWork', input: document.querySelector('#orcid-settings-form #create-first-work-setting') },
    { key: 'alwaysUpdateWork', input: document.querySelector('#orcid-settings-form #always-update-work-setting') },
    { key: 'createDuplicateWork', input: document.querySelector('#orcid-settings-form #create-duplicate-work-setting') },
    { key: 'recreateDeletedWork', input: document.querySelector('#orcid-settings-form #recreate-deleted-work-setting') }
  ];

  let accessToken;
  let orcid;

  const getAccessToken = async () => {
    if (!accessToken) {
      accessToken = await fetchAccessToken(webApplicationBaseUrl);
    }
    return accessToken;
  }

  const getDefaultSetting = (name) => {
    if (modalElement.dataset.hasOwnProperty(name)) {
      return modalElement.dataset[name] == true;
    }
    throw new Error(`There is not default setting for '${name}'.`);
  }

  const showSettingMissingAlert = (show) => {
    if (show) {
      alertElement.classList.remove('d-none');
    } else {
      alertElement.classList.add('d-none');
    }
  };

  const init = async () => {
    const accessToken = await getAccessToken();
    const settings = await fetchOrcidUserSettings(webApplicationBaseUrl, accessToken, orcid);
    let settingMissing = false;
    const processSetting = ({ key, input }) => {
      if (key in settings && settings[key] !== null) {
          input.checked = settings[key];
      } else {
          input.checked = getDefaultSetting(key);
          settingMissing = true;
      }
    };
    settingsMapping.forEach(processSetting);
    if (settingMissing) {
      showSettingMissingAlert(true);
    }
  };

  $('#orcid-settings-modal').on('show.bs.modal', (event) => {
    const orcidTitleElement = document.querySelector('#orcid-settings-modal #modal-title-orcid');
    orcidTitleElement.innerHTML = '';
    const button = event.relatedTarget;
    orcid = button.getAttribute('data-orcid');
    if (orcid) {
      orcidTitleElement.innerHTML = ` ${orcid}`;
      init();
    } else {
      console.error('Failed to init modal, orcid is undefined.');
    }
  });

  const getSettings = () => {
    const settings = {};
    settingsMapping.forEach(({ key, input }) => {
      settings[key] = input.checked;
    });
    return settings;
  };

  document.querySelector('#save-orcid-settings-btn').addEventListener('click', async () => {
    if (orcid) {
      const accessToken = await getAccessToken();
      const settings = getSettings();
      try {
        await updateOrcidUserSettings(webApplicationBaseUrl, accessToken, orcid, settings);
        showSettingMissingAlert(false);
        // TODO close modal or show success alert
      } catch (err) {
        // TODO show generic error alert
        console.error(err);
      }
    } else {
      console.error('Failed to save user settings, orcid is undefined.');
    }
  });
});

