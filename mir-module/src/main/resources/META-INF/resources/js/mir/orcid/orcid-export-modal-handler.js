import { UiHandler } from '../ui-utils.js';

export class OrcidExportModalHandler {
  #orcidWorkService;
  #orcidUserService;
  #objectId;
  #modal;
  #exportButton;
  #orcidSelect;
  #alertDiv;
  #isBusy = false;

  constructor(orcidWorkService, orcidUserService, modalSelector, exportButtonSelector, orcidSelectSelector, alertDivSelector) {
    this.#orcidWorkService = orcidWorkService;
    this.#orcidUserService = orcidUserService;
    this.#modal = document.querySelector(modalSelector);
    this.#exportButton = document.querySelector(exportButtonSelector);
    this.#orcidSelect = document.querySelector(orcidSelectSelector);
    this.#alertDiv = document.querySelector(alertDivSelector);
    this.#resetModal();
    this.#bindEvents();
  }

  get isBusy () {
    return this.#isBusy;
  }

  set objectId (objectId) {
    this.#objectId = objectId;
  }

  get objectId () {
    return this.#objectId;
  }

  openModal = () => {
    if (this.#modal) $(this.#modal).modal('show');
  }

  closeModal = () => {
    if (this.#modal && !this.isBusy) {
      $(this.#modal).modal('hide');
    }
  }

  #handleClose = (event) => {
    if (this.isBusy) event.preventDefault();
  }

  #bindEvents = () => {
    if (this.#modal) {
      $(this.#modal).on('hide.bs.modal', this.#handleClose);
      $(this.#modal).on('show.bs.modal', this.#handleOpenModal);
    }
    if (this.#exportButton) this.#exportButton.addEventListener('click', this.#exportToOrcid);
    if (this.#orcidSelect) this.#orcidSelect.addEventListener('change', this.#handleSelectChange);
  }

  #resetModal() {
    this.#isBusy = false;
    this.#resetSelect();
    UiHandler.setDisabled(this.#exportButton, true);
    UiHandler.toggleElement(this.#alertDiv, false);
  }

  #handleOpenModal = async (event) => {
    if (!this.#objectId) {
      console.error('Object id is not set');
      return;
    }
    this.#resetModal();
    try {
      const userStatus = await this.#orcidUserService.fetchCurrentUserOrcidStatus();
      const orcidPromises = userStatus.trustedOrcids.map(async (orcid) => {
        const workStatus = await this.#orcidWorkService.fetchWorkStatus(orcid, this.objectId, true);
        if (!workStatus.own) this.#addOrcidSelectOption(orcid);
      });
      await Promise.all(orcidPromises);
    } catch (error) {
      console.error('Error loading ORCID infos:', error);
      UiHandler.toggleElement(this.#alertDiv, true);
    }
  }

  #exportToOrcid = async () => {
    const selectedOrcid = this.#orcidSelect.value;
    if (!selectedOrcid) return;
    this.#isBusy = true;
    UiHandler.setDisabled(this.#exportButton, true);
    UiHandler.setDisabled(this.#orcidSelect, true);
    UiHandler.toggleElement(this.#alertDiv, false);
    try {
      await this.#orcidWorkService.exportObjectToOrcid(selectedOrcid, this.objectId);
      alert('Success');
      this.#removeSelectOptionByValue(selectedOrcid);
    } catch (error) {
      console.log(error);
      UiHandler.setDisabled(this.#exportButton, false);
      UiHandler.toggleElement(this.#alertDiv, true);
    } finally {
      UiHandler.setDisabled(this.#orcidSelect, false);
      this.#isBusy = false;
    }
  }

  #resetSelect() {
    if (this.#orcidSelect) {
      for (let i = 1; i < this.#orcidSelect.options.length; i++) {
        this.#orcidSelect.remove(i);
      }
    }
  }

  #addOrcidSelectOption = (orcid) => {
    if (this.#orcidSelect) this.#orcidSelect.append(new Option(orcid, orcid));
  }

  #removeSelectOptionByValue = (value) => {
    if (this.#orcidSelect) {
      Array.from(this.#orcidSelect.options).forEach((option, i) => {
        if (option.value === value) this.#orcidSelect.remove(i);
      });
      this.#orcidSelect.value = '';
      this.#orcidSelect.dispatchEvent(new Event('change'));
    }
  }

  #handleSelectChange = (event) => {
    UiHandler.setDisabled(this.#exportButton, !event.target.value);
  }
}