import {
  OrcidUserApiClient,
  OrcidUserSettings,
} from '@jsr/mycore__js-common/orcid';
import { Modal } from 'bootstrap';
import { UiHandler } from '../utils/ui';

declare global {
  interface Window {
    mycore: {
      defaultOrcidUserSettings: OrcidUserSettings;
    };
  }
}

type OrcidUserSettingsModalConfig = {
  modalEl: HTMLElement;
  userClient: OrcidUserApiClient;
  uiElements: {
    saveBtn: HTMLButtonElement;
    infoAlert: HTMLDivElement;
    titleEl: HTMLElement;
    checkboxes: NodeListOf<HTMLInputElement>;
  };
};

type OrcidUserSettingsModalState = {
  currentOrcid: string | null;
  pendingSave: Promise<void> | null;
  eventListeners: Array<[HTMLElement, string, EventListener]>;
};

export class OrcidUserSettingsModalController {
  private config: OrcidUserSettingsModalConfig;
  private state: OrcidUserSettingsModalState;
  private modalInstance: bootstrap.Modal;

  constructor(config: OrcidUserSettingsModalConfig) {
    this.config = config;
    this.state = {
      currentOrcid: null,
      pendingSave: null,
      eventListeners: [],
    };

    this.modalInstance = new Modal(this.config.modalEl, {
      backdrop: 'static',
      keyboard: false,
    });
    this.initialize();
  }

  private initialize(): void {
    this.bindEventListeners();
  }

  private bindEventListeners(): void {
    const saveListener = () => this.handleSave();
    this.config.uiElements.saveBtn.addEventListener('click', saveListener);
    this.state.eventListeners.push([
      this.config.uiElements.saveBtn,
      'click',
      saveListener,
    ]);
  }

  public async open(orcid: string): Promise<void> {
    if (this.state.pendingSave) return;

    try {
      this.setLoadingState(true);
      this.state.currentOrcid = orcid;

      const settings = await this.config.userClient.getUserSettings(orcid);
      const { processed, hasChanges } = this.processSettings(settings);
      this.updateTitle();
      UiHandler.toggleElement(this.config.uiElements.infoAlert, hasChanges);
      this.updateCheckboxes(processed);
      this.modalInstance.show();
    } catch (error) {
      this.handleError('Error while loading the settings', error);
    } finally {
      this.setLoadingState(false);
    }
  }

  private processSettings(settings: OrcidUserSettings): {
    processed: OrcidUserSettings;
    hasChanges: boolean;
  } {
    const processed = { ...settings };
    let hasChanges = false;
    const defaultSettings = window.mycore.defaultOrcidUserSettings;
    (Object.keys(defaultSettings) as Array<keyof OrcidUserSettings>).forEach(
      key => {
        if (processed[key] === null) {
          processed[key] = defaultSettings[key];
          hasChanges = true;
        }
      }
    );
    return { processed, hasChanges };
  }

  private updateTitle() {
    this.config.uiElements.titleEl.textContent = ` ${this.state.currentOrcid}`;
  }

  private updateCheckboxes(settings: OrcidUserSettings): void {
    this.config.uiElements.checkboxes.forEach(checkbox => {
      const value = settings[checkbox.name as keyof OrcidUserSettings];
      if (typeof value === 'boolean') {
        checkbox.checked = value;
      } else {
        console.warn(`Invalid value for checkbox ${checkbox.name}`);
      }
    });
  }

  private collectSettings(): OrcidUserSettings {
    return Array.from(this.config.uiElements.checkboxes).reduce(
      (acc, checkbox) => {
        acc[checkbox.name as keyof OrcidUserSettings] = checkbox.checked;
        return acc;
      },
      {} as OrcidUserSettings
    );
  }

  private async handleSave(): Promise<void> {
    if (!this.state.currentOrcid || this.state.pendingSave) return;

    try {
      this.setLoadingState(true);
      this.state.pendingSave = this.config.userClient.updateUserSettings(
        this.state.currentOrcid,
        this.collectSettings()
      );
      await this.state.pendingSave;
      this.modalInstance.hide();
    } catch (error) {
      this.handleError('Save failed', error);
    } finally {
      this.state.pendingSave = null;
      this.setLoadingState(false);
    }
  }

  private setLoadingState(isLoading: boolean): void {
    UiHandler.setDisabled(this.config.uiElements.saveBtn, isLoading);
    this.config.modalEl.setAttribute('aria-busy', isLoading.toString());
  }

  private handleError(message: string, error: unknown): void {
    console.error(`${message}: ${(error as Error).message}`);
  }

  public destroy(): void {
    this.state.eventListeners.forEach(([element, event, listener]) => {
      element.removeEventListener(event, listener);
    });
    this.modalInstance.dispose();
  }
}
