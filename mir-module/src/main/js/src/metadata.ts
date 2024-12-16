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

import { MCROrcidUserService, MCROrcidWorkService } from '@golsch/test/orcid';
import { getBaseUrl, getAccessToken } from './common/helpers';
import { MIROrcidExportModalHandler } from './orcid/orcid-export-modal-handler';

const baseUrl: URL = getBaseUrl();

const createOrcidExportModalHandler = (accessToken: string): MIROrcidExportModalHandler => {
  const modalDiv: HTMLDivElement | null = document.querySelector('#exportToOrcidModal');
  const exportBtn: HTMLButtonElement | null = document.querySelector('#exportToOrcidBtn');
  const profileSelect: HTMLSelectElement | null = document.querySelector('#orcidProfileSelect');
  const alertDiv: HTMLDivElement | null = document.querySelector('#alertDiv');
  if (!modalDiv || !exportBtn || !profileSelect || !alertDiv) {
    throw new Error('check input');
  }
  const workService = new MCROrcidWorkService(baseUrl);
  const userService = new MCROrcidUserService(baseUrl);
  return new MIROrcidExportModalHandler(
    accessToken,
    workService,
    userService,
    modalDiv,
    exportBtn,
    profileSelect,
    alertDiv
  );
};

let orcidExportModalHandlerInstance: MIROrcidExportModalHandler | null;;

const getOrcidExportModalHandlerInstance = async (): Promise<MIROrcidExportModalHandler> => {
  if (!orcidExportModalHandlerInstance) {
    const accessToken = await getAccessToken();
    orcidExportModalHandlerInstance = createOrcidExportModalHandler(accessToken);
  }
  return orcidExportModalHandlerInstance;
};

const initExportModal = async () => {
  const appendMenuButton = () => {
    const menu: HTMLDivElement | null = document.querySelector('div#mir-edit-div ul.dropdown-menu');
    const item: HTMLDivElement | null = document.querySelector('li#publishToOrcidMenuItem');
    if (menu && item) {
      menu.append(item);
    }
  };

  const handleOpenModal = async (event: MouseEvent) => {
    const button = event.currentTarget as HTMLButtonElement;
    const objectId = button.getAttribute('data-object-id');
    if (objectId) {
      const modalHandler = await getOrcidExportModalHandlerInstance();
      modalHandler.objectId = objectId;
      modalHandler.showModal();
    }
  };

  const openModalBtn: HTMLDivElement | null = document.querySelector('#openPublishToOrcidModal');
  if (openModalBtn) {
    openModalBtn.addEventListener('click', handleOpenModal);
    appendMenuButton();
  }
};
document.addEventListener('DOMContentLoaded', initExportModal);
