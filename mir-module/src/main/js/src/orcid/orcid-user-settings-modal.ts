import {
  OrcidUserService,
  OrcidUserSettings,
} from '@jsr/mycore__js-common/orcid';
import { UiHandler } from '../utils/ui';
import { Modal } from 'bootstrap';

export class MIROrcidUserSettingsModal {
  private modalInstance: Modal;
  private isBusy = false;
  private currentOrcid?: string;

  constructor(
    private modalEl: HTMLElement,
    private userService: OrcidUserService,
    private form: HTMLFormElement,
    private saveBtn: HTMLButtonElement,
    private infoAlertDiv: HTMLDivElement,
    private titleEl: HTMLElement
  ) {
    this.modalInstance = new Modal(modalEl, {
      backdrop: 'static',
    });
    this.saveBtn.addEventListener('click', this.handleSave);
  }

  public async openModal(orcid: string): Promise<void> {
    this.currentOrcid = orcid;
    this.updateTitle(this.currentOrcid);
    let userSettings: OrcidUserSettings;
    try {
      userSettings = await this.userService.getUserSettings(orcid);
    } catch {
      throw new Error('Error while fetching user settings');
    }
    let unsetSettings = false;
    const plainSettings = JSON.parse(JSON.stringify(userSettings));
    for (const key in plainSettings) {
      if (plainSettings[key] === null) {
        unsetSettings = true;
        plainSettings[key] = this.getDefaultSetting(key);
      }
    }
    const fixedSettings = JSON.parse(JSON.stringify(plainSettings));
    this.fillSettings(fixedSettings);
    if (unsetSettings) {
      UiHandler.toggleElement(this.infoAlertDiv, true);
    }
    this.modalInstance.show();
  }

  private updateTitle = (orcid: string): void => {
    this.titleEl.textContent = ` ${orcid}`;
  };

  private getDefaultSetting(name: string): boolean {
    if (name in this.modalEl.dataset) {
      return this.modalEl.dataset[name] === 'true';
    }
    throw new Error(`There is not default setting for '${name}'.`);
  }

  private fillSettings(settings: OrcidUserSettings): void {
    const plainSettings = JSON.parse(JSON.stringify(settings));
    for (const key in plainSettings) {
      const checkbox: HTMLInputElement | null = this.form.querySelector(
        `input[name="${key}"]`
      );
      if (checkbox) {
        checkbox.checked = plainSettings[key];
      } else {
        throw Error(`Found missing checkbox: ${key}`);
      }
    }
  }

  private handleSave = async (): Promise<void> => {
    if (!this.currentOrcid || this.isBusy) return;

    const settings = this.getSettings();
    this.isBusy = true;
    UiHandler.setDisabled(this.saveBtn, true);

    try {
      await this.userService.updateUserSettings(this.currentOrcid, settings);
      UiHandler.toggleElement(this.infoAlertDiv, false);
      this.modalInstance.hide();
    } catch (err) {
      console.error('Error updating ORCID user settings:', err);
    } finally {
      UiHandler.setDisabled(this.saveBtn, false);
      this.isBusy = false;
    }
  };

  private getSettings(): OrcidUserSettings {
    const plainSettings: Record<string, boolean> = {};
    for (const checkbox of this.form.querySelectorAll(
      'input[type="checkbox"]'
    ) as NodeListOf<HTMLInputElement>) {
      plainSettings[checkbox.name] = checkbox.checked;
    }
    return JSON.parse(JSON.stringify(plainSettings));
  }
}
