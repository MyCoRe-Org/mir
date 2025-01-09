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

import { getBaseUrl, getAccessToken } from './common/helpers';
import { MCROrcidUserService } from '@golsch/test/orcid';
import { MIROrcidUserSetttingsModalHandler } from './orcid/orcid-user-settings-modal-handler';

const createSettingsModalHandler = (accessToken: string): MIROrcidUserSetttingsModalHandler => {
  const userService = new MCROrcidUserService(getBaseUrl());
  const modalDiv: HTMLDivElement | null = document.querySelector('#orcid-settings-modal');
  const settingsForm: HTMLFormElement | null = document.querySelector('#orcid-settings-form');
  const saveBtn: HTMLButtonElement | null = document.querySelector('#save-orcid-settings-btn');
  const alertDiv: HTMLDivElement | null = document.querySelector('#orcid-missing-setting-alert');
  if (!modalDiv || !settingsForm || !saveBtn || !alertDiv) {
    throw new Error('check input');
  }
  return new MIROrcidUserSetttingsModalHandler(
    accessToken,
    userService,
    modalDiv,
    settingsForm,
    saveBtn,
    alertDiv
  );
};

let settingsModalHandlerInstance: MIROrcidUserSetttingsModalHandler | null  = null;

const getSettingsModalHandlerInstance = async (): Promise<MIROrcidUserSetttingsModalHandler> =>  {
  if (!settingsModalHandlerInstance) {
    const accessToken = await getAccessToken();
    settingsModalHandlerInstance = createSettingsModalHandler(accessToken);
  }
  return settingsModalHandlerInstance;
};

const handleOpenModal = async (event: MouseEvent): Promise<void> => {
  const targetElement = event.currentTarget as HTMLElement;
  const { orcid } = targetElement.dataset;
  if (!orcid) {
    console.error('ORCID iD is missing.');
    return;
  }
  const modalHandler = await getSettingsModalHandlerInstance();
  modalHandler.orcid = orcid;
  modalHandler.showModal();
};

const initSettingsModal = (): void => {
  const openModalButton = document.getElementById('openSettingsModalBtn');
  if (openModalButton) {
    openModalButton.addEventListener('click', handleOpenModal);
  } else {
    console.error('Modal button not found');
  }
};

document.addEventListener('DOMContentLoaded', initSettingsModal);
