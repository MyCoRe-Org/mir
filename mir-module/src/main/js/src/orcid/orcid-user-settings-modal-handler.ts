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

import { UiHandler } from '../common/ui-utils';
import { MIRModalHandler } from '../common/modal';
import { MCROrcidUserService, type MCROrcidUserSettings } from '@golsch/test/orcid';

export class MIROrcidUserSetttingsModalHandler extends MIRModalHandler {
  private _accessToken: string;
  private _userService: MCROrcidUserService;
  private _form: HTMLFormElement;
  private _saveBtn: HTMLButtonElement;
  private _titleElement: HTMLElement;
  private _alertDiv: HTMLDivElement;

  private _orcid: string | null;

  constructor(
    accessToken: string,
    userService: MCROrcidUserService,
    modalDiv: HTMLDivElement,
    form: HTMLFormElement,
    saveBtn: HTMLButtonElement,
    alertDiv: HTMLDivElement
  ) {
    super(modalDiv);
    this._accessToken = accessToken;
    this._userService = userService;
    this._form = form;
    this._saveBtn = saveBtn;
    this._alertDiv = alertDiv;
    const titleElement: HTMLElement | null = modalDiv.querySelector('#modal-title-orcid');
    if (titleElement) {
      this._titleElement = titleElement;
    } else {
      throw new Error('Missing title element');
    }
    this._orcid = null;
    saveBtn.addEventListener('click', this.handleSave);
  }

  public set orcid (orcid: string) {
    this._orcid = orcid;
  }

  public set accessToken(accessToken: string) {
    this._accessToken = accessToken;
  }

  private setModalTitle = (orcid: string) => {
    this._titleElement.textContent = ` ${orcid}`;
  }

  protected async handleOpenModal (event: JQuery.TriggeredEvent) {
    if (!this._orcid) {
      console.error('Orcid is not set');
      return;
    }
    this.setModalTitle(this._orcid);
    let userSettings: MCROrcidUserSettings;
    try {
      userSettings = await this._userService.fetchOrcidUserSettings(this._accessToken, this._orcid);
    } catch (error) {
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
    this.setSettings(fixedSettings);
    if (unsetSettings) {
      UiHandler.toggleElement(this._alertDiv, true);
    }
  }

  private setSettings (settings: MCROrcidUserSettings): void {
    const plainSettings = JSON.parse(JSON.stringify(settings));
    for (const key in plainSettings) {
      const checkbox: HTMLInputElement | null = this._form.querySelector(`input[name="${key}"]`);
      if (checkbox) {
        checkbox.checked = plainSettings[key];
      } else {
        throw Error(`Found missing checkbox: ${key}`);
      }
    }
  }

  private getSettings (): MCROrcidUserSettings {
    let plainSettings: Record<string, boolean> = {};
    for (const checkbox of this._form.querySelectorAll('input[type="checkbox"]') as NodeListOf<HTMLInputElement>) {
      plainSettings[checkbox.name] = checkbox.checked;
    }
    return JSON.parse(JSON.stringify(plainSettings));
  }

  private getDefaultSetting (name: string) {
    if (this.modalDiv.dataset.hasOwnProperty(name)) {
      return this.modalDiv.dataset[name] === 'true';
    }
    throw new Error(`There is not default setting for '${name}'.`);
  }

  private handleSave = async (event: MouseEvent) => {
    if (!this._orcid) {
      throw new Error('Orcid is not set');
    } 
    const settings = this.getSettings();
    this.isBusy = true;
    UiHandler.setDisabled(this._saveBtn, true);
    try {
      await this._userService.updateOrcidUserSettings(this._accessToken, this._orcid, settings);
      UiHandler.toggleElement(this._alertDiv, false);
      this.isBusy = false;
      super.closeModal();
    } catch (err) {
      console.error(err);
    } finally {
      UiHandler.setDisabled(this._saveBtn, false);
      this.isBusy = false;
    }
  }
}
