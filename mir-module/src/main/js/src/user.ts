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
import { revokeOrcidOAuth, getOrcidOAuthInitUrl } from '@golsch/test/orcid';

const createOrcidSettingsModalHandler = (accessToken: string): MIROrcidUserSetttingsModalHandler => {
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

let orcidSettingsModalHandlerInstance: MIROrcidUserSetttingsModalHandler | null  = null;

const getSettingsModalHandlerInstance = async (): Promise<MIROrcidUserSetttingsModalHandler> =>  {
  if (!orcidSettingsModalHandlerInstance) {
    const accessToken = await getAccessToken();
    orcidSettingsModalHandlerInstance = createOrcidSettingsModalHandler(accessToken);
  }
  return orcidSettingsModalHandlerInstance;
};

const doOpenOrcidSettingsModal = async (orcid: string): Promise<void> => {
  const modalHandler = await getSettingsModalHandlerInstance();
  modalHandler.orcid = orcid;
  modalHandler.showModal();
};

const doRevokeOrcidOAuth = async (orcid: string, redirectUrl: string | null) => {
  await revokeOrcidOAuth(getBaseUrl(), await getAccessToken(), orcid);
  if (redirectUrl) {
    window.location.href = redirectUrl;
  }
}

const doInitOrcidOAuth = (scope: string | null) => {
  const width = 540;
  const height = 750;
  let left = 0;
  let top = 0;
  if (window.top) {
    left = window.top.outerWidth / 2 + window.top.screenX - (width / 2);
    top = window.top.outerHeight / 2 + window.top.screenY - (height / 2);
  }
  const initUrl = getOrcidOAuthInitUrl(getBaseUrl(), scope !== null ? scope : undefined);
  const w = window.open(initUrl, '_blank', `toolbar=no, width=${width}, height=${height}, top=${top}, left=${left}`);
  w?.addEventListener("beforeunload", (event) => {
    window.location.reload();
  });
}

const handleOpenOrcidSettingsModal = (event: Event) => {
  const targetElement = event.currentTarget as HTMLElement;
  const { orcid } = targetElement.dataset;
  if (!orcid) {
    console.error('ORCID iD is missing.');
    return;
  }
  doOpenOrcidSettingsModal(orcid);
}

const handleRevokeOrcidOAuth = async (event: Event) => {
  const target = event.target as HTMLButtonElement;
  const orcid: string | null = target.getAttribute('data-orcid');
  if (orcid) {
    await doRevokeOrcidOAuth(orcid, target.getAttribute('data-redirect-url'));
  } else {
    console.error('Orcid is required to revoke Orcid OAuth');
  }
}

const init = (): void => {
  const openOrcidSettingsModalBtns: NodeListOf<HTMLButtonElement> = document.querySelectorAll('button.open-orcid-settings');
  openOrcidSettingsModalBtns.forEach((button: HTMLButtonElement) => {
    button.addEventListener('click', async (event: MouseEvent) =>  handleOpenOrcidSettingsModal(event));
  });
  const revokeOrcidBtns: NodeListOf<HTMLButtonElement> = document.querySelectorAll('button.revoke-orcid-oauth');
  revokeOrcidBtns.forEach((button: HTMLButtonElement) => {
    button.addEventListener('click', async (event: MouseEvent) => handleRevokeOrcidOAuth(event));
  });
  const initOrcidBtn: HTMLButtonElement | null = document.querySelector('#initOrcidOAuthBtn');
  if (initOrcidBtn) {
    const scope: string | null = initOrcidBtn.getAttribute('data-scope');
    initOrcidBtn.addEventListener('click', () => {
      doInitOrcidOAuth(scope);
    });
  }
};

document.addEventListener('DOMContentLoaded', init);
