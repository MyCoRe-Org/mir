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

export class OrcidExportModalHandler {
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
    const exportListener = () => this.handleExport();
    this.config.uiElements.exportBtn.addEventListener('click', exportListener);
    this.state.eventListeners.push([
      this.config.uiElements.exportBtn,
      'click',
      exportListener,
    ]);
    const selectListener = () => this.updateExportButtonState();
    this.config.uiElements.orcidSelect.addEventListener(
      'change',
      selectListener
    );
    this.state.eventListeners.push([
      this.config.uiElements.orcidSelect,
      'change',
      selectListener,
    ]);
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

    try {
      this.setLoadingState(true);
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
    orcids.forEach(orcid => {
      select.add(new Option(orcid, orcid));
    });

    this.updateExportButtonState();
  }

  private async handleExport(): Promise<void> {
    if (!this.state.currentObjectId || this.state.isExporting) return;

    try {
      this.setLoadingState(true);
      const selectedOrcid = this.config.uiElements.orcidSelect.value;

      await this.config.workClient.exportObject(
        selectedOrcid,
        this.state.currentObjectId
      );
      this.handleSuccess(
        await this.config.langService.translate(
          'mir.orcid.publication.export.notification.success'
        )
      );
      this.removeOrcidOption(selectedOrcid);
    } catch (error) {
      this.handleError('Export failed', error);
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
    UiHandler.toggleElement(this.config.uiElements.alertDiv, true);
    console.error(`${message}: ${(error as Error).message}`);
  }

  public destroy(): void {
    this.state.eventListeners.forEach(([element, event, listener]) => {
      element.removeEventListener(event, listener);
    });
    this.modalInstance.dispose();
  }
}
