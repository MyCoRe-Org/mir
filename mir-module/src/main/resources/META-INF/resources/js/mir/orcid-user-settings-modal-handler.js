class UiHandler {
  static toggleElement(element, shouldShow) {
    if (element) element.classList.toggle('d-none', !shouldShow);
  }

  static setDisabled(element, isDisabled) {
    if (element) element.disabled = isDisabled;
  }
}

export class OrcidUserSetttingsModalHandler {
  constructor(userService, modalId, formId, saveButtonId, alertId) {
    this.#userService = userService;
    this.#modal = document.querySelector(modalId);
    this.#form = document.querySelector(formId);
    this.#saveButton = document.querySelector(saveButtonId);
    this.#alertDiv = document.querySelector(alertId);
    this.#titleDiv = this.#modal.querySelector('#modal-title-orcid');
    this.#bindEvents();
  }

  #userService;
  #isBusy = false;
  #modal;
  #form;
  #saveButton;
  #titleDiv;
  #alertDiv;
  #orcid;

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
      userSettings = await this.#userService.fetchSettings(this.orcid);
    } catch (error) {
      console.error(error);
    }
    if (!userSettings) {
      return;
    }
    let settingMissing = false;
    const settingNames = this.#getSettingNames();
    const settings = {};
    settingNames.forEach((name) => {
      if (userSettings.hasOwnProperty(name) && userSettings[name] !== null) {
        settings[name] = userSettings[name];
      } else {
        settings[name] = this.#getDefaultSetting(name);
        settingMissing = true;
      }
    });
    console.log(settings);
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
      await this.#userService.updateSettings(this.#orcid, settings);
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