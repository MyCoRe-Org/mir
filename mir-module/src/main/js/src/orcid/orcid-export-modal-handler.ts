/*
 * This file is part of ***  M y C o R e  ***
 * See https://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

import { MIRModalHandler } from '../common/modal';
import { UiHandler } from '../common/ui-utils';
import { MCROrcidUserService, MCROrcidWorkService } from '@golsch/test/orcid';

export class MIROrcidExportModalHandler extends MIRModalHandler {
  private _accessToken: string;
  private _orcidWorkService: MCROrcidWorkService;
  private _orcidUserService: MCROrcidUserService;
  private _exportBtn: HTMLButtonElement;
  private _orcidSelect: HTMLSelectElement;
  private _alertDiv: HTMLDivElement;

  private _objectId: string | null;

  constructor(
    accessToken: string,
    orcidWorkService: MCROrcidWorkService,
    orcidUserService: MCROrcidUserService,
    modalDiv: HTMLDivElement,
    exportBtn: HTMLButtonElement,
    orcidSelect: HTMLSelectElement,
    alertDiv: HTMLDivElement
  ) {
    super(modalDiv);
    this._accessToken = accessToken;
    this._orcidWorkService = orcidWorkService;
    this._orcidUserService = orcidUserService;
    this._exportBtn = exportBtn;
    this._orcidSelect = orcidSelect;
    this._alertDiv = alertDiv;
    this._objectId = null;
    this.resetModal();
    this.handleOpenModal = this.handleOpenModal.bind(this);
    this.handleSelectChange = this.handleSelectChange.bind(this);
    this.bindEvents();
  }

  set objectId (objectId: string | null) {
    this._objectId = objectId;
  }

  get objectId (): string | null {
    return this._objectId;
  }

  private bindEvents(): void {
    this._exportBtn.addEventListener('click', this.exportToOrcid);
    this._orcidSelect.addEventListener('change', this.handleSelectChange);
  }

  private resetModal(): void {
    this.isBusy = false;
    this.resetSelect();
    UiHandler.setDisabled(this._exportBtn, true);
    UiHandler.toggleElement(this._alertDiv, false);
  }

  protected async handleOpenModal (event: JQuery.TriggeredEvent): Promise<void> {
    if (!this._objectId) {
      throw new Error('Object id is required');
    }
    this.resetModal();
    const objectId: string = this._objectId;
    const accessToken: string = this._accessToken;
    try {
      const userStatus = await this._orcidUserService.fetchOrcidUserStatus(accessToken);
      const orcidPromises = userStatus.trustedOrcids.map(async (orcid) => {
        const workStatus = await this._orcidWorkService.fetchWorkStatus(accessToken, orcid, objectId, true);
        if (!workStatus.own) this.addOrcidSelectOption(orcid);
      });
      await Promise.all(orcidPromises);
    } catch (error) {
      console.error('Error loading ORCID infos:', error);
      UiHandler.toggleElement(this._alertDiv, true);
    }
  }

  private async exportToOrcid (): Promise<void> {
    if (!this._objectId) {
      throw new Error('Object id is required');
    }
    const selectedOrcid = this._orcidSelect.value;
    if (!selectedOrcid) {
      return;
    }
    this.isBusy = true;
    UiHandler.setDisabled(this._exportBtn, true);
    UiHandler.setDisabled(this._orcidSelect, true);
    UiHandler.toggleElement(this._alertDiv, false);
    const objectId: string = this._objectId;
    const accessToken: string = this._accessToken;
    try {
      await this._orcidWorkService.exportObjectToOrcid(accessToken, selectedOrcid, objectId);
      alert('Success');
      this.removeSelectOptionByValue(selectedOrcid);
    } catch (error) {
      console.log(error);
      UiHandler.setDisabled(this._exportBtn, false);
      UiHandler.toggleElement(this._alertDiv, true);
    } finally {
      UiHandler.setDisabled(this._orcidSelect, false);
      this.isBusy = false;
    }
  }

  private resetSelect (): void {
    for (let i = 1; i < this._orcidSelect.options.length; i++) {
      this._orcidSelect.remove(i);
    }
  }

  private addOrcidSelectOption (orcid: string): void {
    this._orcidSelect.append(new Option(orcid, orcid));
  }

  private removeSelectOptionByValue (value: string): void {
    Array.from(this._orcidSelect.options).forEach((option, i) => {
      if (option.value === value) this._orcidSelect.remove(i);
    });
    this._orcidSelect.value = '';
    this._orcidSelect.dispatchEvent(new Event('change'));
  }

  private handleSelectChange (event: Event): void {
    const target = event.target as HTMLSelectElement;
    UiHandler.setDisabled(this._exportBtn, !target.value);
  }
}
