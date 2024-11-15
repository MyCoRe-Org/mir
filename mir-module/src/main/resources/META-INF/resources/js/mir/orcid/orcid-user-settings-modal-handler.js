import { UiHandler } from '../ui-utils.js';

export class OrcidUserSetttingsModalHandler {
  #userService;
  #isBusy = false;
  #modal;
  #form;
  #saveButton;
  #titleDiv;
  #alertDiv;
  #orcid;

  constructor(userService, modalSelector, formSelector, saveButtonSelector, alertDivSelector) {
    this.#userService = userService;
    this.#modal = document.querySelector(modalSelector);
    this.#form = document.querySelector(formSelector);
    this.#saveButton = document.querySelector(saveButtonSelector);
    this.#alertDiv = document.querySelector(alertDivSelector);
    this.#titleDiv = this.#modal.querySelector('#modal-title-orcid');
    this.#bindEvents();
  }

  set orcid (orcid) {
    this.#orcid = orcid;
  }

  get orcid () {
    return this.#orcid;
  }

  get isBusy() {
    return this.#isBusy;
  }

  #bindEvents = () => {
    if (this.#modal) {
      $(this.#modal).on('hide.bs.modal', this.#handleClose);
      $(this.#modal).on('show.bs.modal', this.#handleOpenModal);
    }
    if (this.#saveButton) this.#saveButton.addEventListener('click', this.#handleSave);
  }

  #handleClose = (event) => {
    if (this.isBusy) event.preventDefault();
  }

  showModal = () => {
    if (this.#modal) $(this.#modal).modal('show');
  }

  closeModal = () => {
    if (this.#modal && !this.#isBusy) {
      $(this.#modal).modal('hide');
    }
  }

  #setModalTitle = (orcid) => {
    if (this.#titleDiv) this.#titleDiv.textContent = ` ${orcid}`;
  }

  #handleOpenModal = async (event) => {

    if (!this.#orcid) {
      console.error('Orcid is not set');
      return;
    }
    this.#setModalTitle(this.#orcid);
    let userSettings = null;
    try {
      userSettings = await this.#userService.fetchCurrentUserOrcidSettings(this.orcid);
    } catch (error) {
      console.error(error);
    }
    if (!userSettings) {
      return;
    }
    const settingNames = this.#getSettingNames();
    const settings = {};
    let settingMissing = false;
    settingNames.forEach((name) => {
      if (userSettings.hasOwnProperty(name) && userSettings[name] !== null) {
        settings[name] = userSettings[name];
      } else {
        settings[name] = this.#getDefaultSetting(name);
        settingMissing = true;
      }
    });
    if (settingMissing) {
      UiHandler.toggleElement(this.#alertDiv, true);
    }
    this.#setSettings(settings);
  }

  #setSettings = (settings) => {
    Object.entries(settings).forEach(([name, value]) => {
      this.#form.querySelector(`input[name="${name}"]`).checked = value;
    })
  }

  #getSettings = () => {
    const settings = {};
    this.#form.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
      settings[checkbox.name] = checkbox.checked;
    })
    return settings;
  }

  #getSettingNames = () => {
    return Array.from(this.#form.querySelectorAll('input[type="checkbox"]')).map(checkbox => checkbox.name);
  }

  #getDefaultSetting = (name) => {
    if (this.#modal && this.#modal.dataset.hasOwnProperty(name)) {
      return this.#modal.dataset[name] === 'true';
    }
    throw new Error(`There is not default setting for '${name}'.`);
  }

  #handleSave = async (event) => {
    if (!this.#orcid) {
      console.error('Orcid is not set');
      return;
    } 
    const settings = this.#getSettings();
    this.#isBusy = true;
    UiHandler.setDisabled(this.#saveButton, true);
    try {
      await this.#userService.updateCurrentUserOrcidSettings(this.#orcid, settings);
      UiHandler.toggleElement(this.#alertDiv, false);
      this.#isBusy = false;
      this.closeModal(true);
    } catch (err) {
      console.error(err);
    } finally {
      UiHandler.setDisabled(this.#saveButton, false);
      this.#isBusy = false;
    }
  }
}