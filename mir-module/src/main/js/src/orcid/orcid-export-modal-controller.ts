import { LangService } from '@jsr/mycore__js-common/i18n';
import {
  OrcidUserApiClient,
  OrcidWorkApiClient,
} from '@jsr/mycore__js-common/orcid';
import { Modal } from 'bootstrap';
import { UiHandler } from '../utils/ui';

type OrcidExportModalConfig = {
  modalEl: HTMLElement;
  workClient: OrcidWorkApiClient;
  userClient: OrcidUserApiClient;
  langService: LangService;
  uiElements: {
    exportBtn: HTMLButtonElement;
    orcidSelect: HTMLSelectElement;
    alertDiv: HTMLDivElement;
  };
};

type OrcidExportModalState = {
  currentObjectId: string | null;
  isExporting: boolean;
  eventListeners: Array<[HTMLElement, string, EventListener]>;
};

export class OrcidExportModalController {
  private config: OrcidExportModalConfig;
  private state: OrcidExportModalState;
  private modalInstance: bootstrap.Modal;

  constructor(config: OrcidExportModalConfig) {
    this.config = config;
    this.state = {
      currentObjectId: null,
      isExporting: false,
      eventListeners: [],
    };

    this.modalInstance = new Modal(this.config.modalEl, {
      backdrop: 'static',
      keyboard: false,
    });

    this.bindEventListeners();
  }

  private bindEventListeners(): void {
    this.addListener(this.config.uiElements.exportBtn, 'click', () =>
      this.handleExport()
    );

    this.addListener(this.config.uiElements.orcidSelect, 'change', () =>
      this.updateExportButtonState()
    );
  }

  private addListener(
    el: HTMLElement,
    event: string,
    listener: EventListener
  ): void {
    el.addEventListener(event, listener);
    this.state.eventListeners.push([el, event, listener]);
  }

  public open(objectId: string): void {
    if (this.state.isExporting) return;

    this.state.currentObjectId = objectId;
    this.resetModalState();
    this.loadOrcidProfiles()
      .catch(error =>
        this.handleError('Error loading the ORCID profiles', error)
      )
      .finally(() => this.modalInstance.show());
  }

  private async loadOrcidProfiles(): Promise<void> {
    if (!this.state.currentObjectId) return;

    this.setLoadingState(true);
    try {
      const userStatus = await this.config.userClient.getUserStatus();
      const profilePromises = userStatus.trustedOrcids.map(
        async (orcid: string) => {
          const workStatus = await this.config.workClient.getWorkStatus(
            orcid,
            this.state.currentObjectId!,
            'member'
          );
          return workStatus.own ? null : orcid;
        }
      );

      const availableOrcids = (await Promise.all(profilePromises)).filter(
        Boolean
      );
      this.updateSelectOptions(availableOrcids as string[]);
    } finally {
      this.setLoadingState(false);
    }
  }

  private updateSelectOptions(orcids: string[]): void {
    const select = this.config.uiElements.orcidSelect;
    select.options.length = 1;
    orcids.forEach(orcid => select.add(new Option(orcid, orcid)));
    this.updateExportButtonState();
  }

  private async handleExport(): Promise<boolean> {
    const selectedOrcid = this.config.uiElements.orcidSelect.value;
    if (!this.state.currentObjectId || !selectedOrcid || this.state.isExporting)
      return false;

    this.setLoadingState(true);
    try {
      await this.config.workClient.exportObject(
        selectedOrcid,
        this.state.currentObjectId
      );
      const msg = await this.config.langService.translate(
        'mir.orcid.publication.export.notification.success'
      );
      this.handleSuccess(msg);
      this.removeOrcidOption(selectedOrcid);
      return true;
    } catch (error) {
      this.handleError('Export failed', error);
      return false;
    } finally {
      this.setLoadingState(false);
    }
  }

  private removeOrcidOption(value: string): void {
    const option = this.config.uiElements.orcidSelect.querySelector(
      `option[value="${value}"]`
    );
    option?.remove();
    this.updateExportButtonState();
  }

  private setLoadingState(isLoading: boolean): void {
    this.state.isExporting = isLoading;
    this.config.modalEl.setAttribute('aria-busy', isLoading.toString());
    UiHandler.setDisabled(this.config.uiElements.orcidSelect, isLoading);

    if (isLoading) {
      UiHandler.setDisabled(this.config.uiElements.exportBtn, true);
    } else {
      this.updateExportButtonState();
    }
  }

  private updateExportButtonState(): void {
    const hasSelection = !!this.config.uiElements.orcidSelect.value;
    UiHandler.setDisabled(
      this.config.uiElements.exportBtn,
      !hasSelection || this.state.isExporting
    );
  }

  private resetModalState(): void {
    UiHandler.toggleElement(this.config.uiElements.alertDiv, false);
    this.config.uiElements.orcidSelect.value = '';
    this.updateExportButtonState();
  }

  private handleSuccess(message: string): void {
    alert(message);
  }

  private handleError(message: string, error: unknown): void {
    const errorMessage =
      error instanceof Error ? error.message : JSON.stringify(error);
    console.error(`${message}: ${errorMessage}`);
    UiHandler.toggleElement(this.config.uiElements.alertDiv, true);
  }

  public destroy(): void {
    this.state.eventListeners.forEach(([el, event, listener]) => {
      el.removeEventListener(event, listener);
    });
    this.modalInstance.dispose();
  }
}
