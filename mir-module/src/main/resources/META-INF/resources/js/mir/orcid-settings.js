
const fetchAccessToken = async (baseUrl) => {
  const response = await fetch(`${baseUrl}rsc/jwt`);
  if (!response.ok) {
    throw new Error('Failed to fetch JWT for current user.');
  }
  const result = await response.json();
  if (!result.login_success) {
    throw new Error('Login failed.');
  }
  return result.access_token;
}

class OrcidSettingsService {
  constructor(baseUrl, bearerAccessToken) {
    this.baseUrl = baseUrl;
    this.accessToken = bearerAccessToken;
  }

  fetchSettings = async (orcid) => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/user-properties/${orcid}`, {
      headers: { Authorization: `Bearer ${this.accessToken}`},
    });
    if (!response.ok) {
      throw new Error(`Failed to fetch ORCID user settings for ${orcid}.`);
    }
    return await response.json();
  }

  updateSettings = async (orcid, settings) => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/user-properties/${orcid}`, {
      method: 'PUT',
      headers: {
        Authorization: `Bearer ${this.accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(settings),
    });
    if (!response.ok) {
      throw new Error(`Failed to update ORCID user settings for ${orcid}.`);
    }
  }
}

const baseUrl = window['webApplicationBaseURL'];

class OrcidSettingsForm {
  constructor() {
    this.createFirstWorkInput = document.querySelector('#orcid-settings-form #create-first-work-setting');
    this.alwaysUpdateWork = document.querySelector('#orcid-settings-form #always-update-work-setting');
    this.createDuplicateWork = document.querySelector('#orcid-settings-form #create-duplicate-work-setting');
    this.recreateDeletedWork = document.querySelector('#orcid-settings-form #recreate-deleted-work-setting');
    this.listeners = {};

    document.querySelector('#save-orcid-settings-btn').addEventListener('click', () => {
      this.dispatchEvent(new CustomEvent('saveClicked'));
    });
  }

  setSettings = (settings) => {
    this.createFirstWorkInput.checked = settings.createFirstWork;
    this.alwaysUpdateWork.checked = settings.alwaysUpdateWork;
    this.createDuplicateWork.checked = settings.createDuplicateWork;
    this.recreateDeletedWork.checked = settings.recreateDeletedWork;
  }

  getSettings = () => {
    return {
      createFirstWork: this.createFirstWorkInput.checked,
      alwaysUpdateWork: this.alwaysUpdateWork.checked,
      createDuplicateWork: this.createDuplicateWork.checked,
      recreateDeletedWork: this.recreateDeletedWork.checked,
    }
  }

  dispatchEvent(event) {
    const eventName = event.type;
    if (this.listeners[eventName]) {
        this.listeners[eventName].forEach(listener => {
            listener(event);
        });
    }
  }

  addEventListener(eventName, listener) {
    if (!this.listeners[eventName]) {
        this.listeners[eventName] = [];
    }
    this.listeners[eventName].push(listener);
  }
}

class OrcidSetttingsModal {
  constructor(service) {
    this.service = service;
    this.modalId = "orcid-settings-modal";
    this.alertElement = document.querySelector('#orcid-settings-container #orcid-missing-setting-alert');
    this.titleElement = document.querySelector(`#${modalId} #modal-title-orcid`);
    this.modalElement = document.querySelector(`#${modalId}`);
    this.form = new OrcidSettingsForm();
    this.orcid = null;
  }

  show = () => {
    if (this.modalElement) {
      $(this.modalElement).modal('show');
    }
  }

  hide = () => {
    if (this.modalElement) {
      $(this.modalElement).modal('hide');
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const modalId = "orcid-settings-modal";
  const alertElement = document.querySelector('#orcid-settings-container #orcid-missing-setting-alert');
  const titleElement = document.querySelector(`#${modalId} #modal-title-orcid`);
  const modalElement = document.querySelector(`#${modalId}`);
  const form = new OrcidSettingsForm();
  let service = null;
  let orcid = null;

  const showModal = () => {
    if (modalElement) {
      $(modalElement).modal('show');
    }
  }

  const hideModal = () => {
    if (modalElement) {
      $(modalElement).modal('hide');
    }
  }

  const setModalTitle = (orcid) => {
    if (titleElement) {
      titleElement.innerHTML = ` ${orcid}`;
    }
  }

  const showSettingMissingAlert = (show) => {
    if (alertElement) {
      if (show) {
        alertElement.classList.remove('d-none');
      } else {
        alertElement.classList.add('d-none');
      }
    }
  }

  const initModal = async () => {
    const settingNames = ['createFirstWork', 'alwaysUpdateWork', 'createDuplicateWork', 'recreateDeletedWork'];
    if (orcid && service) {
      try {
        const settings = await service.fetchSettings(orcid);
        let settingMissing = false;
        let fixedSettings = {};
        settingNames.forEach((settingName) => {
          if (settings.hasOwnProperty(settingName) && settings[settingName] !== null) {
            fixedSettings[settingName] = settings[settingName];
          } else {
            fixedSettings[settingName] = getDefaultSetting(settingName);
            settingMissing = true;
          }
        });
        if (settingMissing) {
          showSettingMissingAlert(true);
        }
        setModalTitle(orcid);
        form.setSettings(fixedSettings);
        showModal();
      } catch (err) {
        console.error(err);
      }
    }
  }

  getDefaultSetting = (name) => {
    if (modalElement && modalElement.dataset.hasOwnProperty(name)) {
      return modalElement.dataset[name] == true;
    }
    throw new Error(`There is not default setting for '${name}'.`);
  }

  form.addEventListener('saveClicked', async (event) => {
    if (orcid && service) {
      const settings = form.getSettings();
      try {
        await service.updateSettings(orcid, settings);
        showSettingMissingAlert(false);
        hideModal();
      } catch (err) {
        // TODO show generic error alert
        console.error(err);
      }
    } else {
      console.error('Failed to save user settings, orcid is undefined.');
    }
  });

  document.getElementById('openSettingsModalBtn').addEventListener('click', async (event) => {
    orcid = event.currentTarget.dataset.orcid;
    try {
      if (orcid) {
        if (!service) {
          const accessToken = await fetchAccessToken(baseUrl);
          service = new OrcidSettingsService(baseUrl, accessToken);
        }
        initModal();
      } else {
        console.error('ORCID iD is missing.');
      }
    } catch (err) {
      console.error('Failed to load settings modal.');
    }
  });
});
