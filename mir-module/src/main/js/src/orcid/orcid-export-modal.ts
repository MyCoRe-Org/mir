import { Modal } from 'bootstrap';
import {
  OrcidUserService,
  OrcidWorkService,
} from '@jsr/mycore__js-common/orcid';
import { UiHandler } from '../utils/ui';

export class MIROrcidExportModal {
  private modalInstance: Modal;
  private isBusy: boolean;
  private currentObjectId?: string;

  constructor(
    modalEl: HTMLElement,
    private userService: OrcidUserService,
    private workService: OrcidWorkService,
    private readonly exportBtn: HTMLButtonElement,
    private readonly orcidSelect: HTMLSelectElement,
    private readonly alertDiv: HTMLDivElement
  ) {
    this.modalInstance = new Modal(modalEl, {
      backdrop: 'static',
    });
    this.isBusy = false;
    this.resetModal();
    this.handleSelectChange = this.handleSelectChange.bind(this);
    this.bindEvents();
  }

  private bindEvents(): void {
    this.exportBtn.addEventListener('click', this.exportToOrcid);
    this.orcidSelect.addEventListener('change', this.handleSelectChange);
  }

  private resetModal(): void {
    this.isBusy = false;
    this.resetSelect();
    UiHandler.setDisabled(this.exportBtn, true);
    UiHandler.toggleElement(this.alertDiv, false);
  }

  public open = async (objectId: string): Promise<void> => {
    this.currentObjectId = objectId;
    this.resetModal();
    try {
      const userStatus = await this.userService.getUserStatus();
      const orcidPromises = userStatus.trustedOrcids.map(
        async (orcid: string) => {
          const workStatus = await this.workService.getWorkStatus(
            orcid,
            objectId,
            'member'
          );
          if (!workStatus.own) {
            this.addOrcidSelectOption(orcid);
          }
        }
      );
      await Promise.all(orcidPromises);
      this.modalInstance.show();
    } catch (error) {
      console.error('Error loading ORCID infos:', error);
      UiHandler.toggleElement(this.alertDiv, true);
    }
  };

  private exportToOrcid = async (): Promise<void> => {
    if (!this.currentObjectId) {
      console.error('Object ID is missing.');
      return;
    }
    const selectedOrcid = this.orcidSelect.value;
    if (!selectedOrcid) {
      return;
    }
    this.isBusy = true;
    UiHandler.setDisabled(this.exportBtn, true);
    UiHandler.setDisabled(this.orcidSelect, true);
    UiHandler.toggleElement(this.alertDiv, false);
    try {
      await this.workService.exportObject(selectedOrcid, this.currentObjectId);
      alert('Success');
      this.removeSelectOptionByValue(selectedOrcid);
    } catch (error) {
      console.log(error);
      UiHandler.setDisabled(this.exportBtn, false);
      UiHandler.toggleElement(this.alertDiv, true);
    } finally {
      UiHandler.setDisabled(this.orcidSelect, false);
      this.isBusy = false;
    }
  };

  private resetSelect(): void {
    for (let i = 1; i < this.orcidSelect.options.length; i++) {
      this.orcidSelect.remove(i);
    }
  }

  private addOrcidSelectOption(orcid: string): void {
    this.orcidSelect.append(new Option(orcid, orcid));
  }

  private removeSelectOptionByValue(value: string): void {
    const option = Array.from(this.orcidSelect.options).find(
      opt => opt.value === value
    );
    if (option) {
      this.orcidSelect.remove(option.index);
    }
    this.orcidSelect.value = '';
    this.orcidSelect.dispatchEvent(new Event('change'));
  }

  private handleSelectChange(event: Event): void {
    const target = event.target as HTMLSelectElement;
    UiHandler.setDisabled(this.exportBtn, !target.value);
  }
}
