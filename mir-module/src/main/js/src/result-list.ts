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

import { MCRLangServiceImpl } from '@golsch/test/i18n';
import { getAccessToken, getBaseUrl, getLangService } from './common/helpers.js';
import {
  MCROrcidWorkService,
  MCROrcidUserService,
  MCROrcidUserStatus,
  MCROrcidWorkStatus
} from '@golsch/test/orcid';

const baseUrl: URL = getBaseUrl();

const createOrcidStatusImg = (): HTMLImageElement => {
  const orcidIcon: HTMLImageElement = document.createElement('img');
  orcidIcon.alt = 'ORCID iD';
  orcidIcon.classList.add('orcid-icon');
  orcidIcon.src = `${baseUrl}images/orcid_icon.svg`;
  return orcidIcon;
};

const createThumbsElement = (up: boolean): HTMLSpanElement => {
  const thumbsElement = document.createElement('span');
  thumbsElement.classList.add('far', `fa-thumbs-${up ? 'up' : 'down'}`, `orcid-in-profile-${up}`);
  return thumbsElement;
};

const checkIsInOrcidProfile = (workStatus: MCROrcidWorkStatus): boolean => {
  return workStatus.own !== undefined
    || (workStatus.other !== undefined && workStatus.other.length > 0);
};

const initOrcidStatus = async (): Promise<void> => {
  const workService: MCROrcidWorkService = new MCROrcidWorkService(baseUrl);
  const langService: MCRLangServiceImpl = getLangService();

  const createOrcidPublicationStatus = async (
    isInOrcidProfile: boolean
  ): Promise<HTMLSpanElement> => {
    const statusSpan = document.createElement('span');
    statusSpan.classList.add('orcid-info');
    statusSpan.appendChild(createOrcidStatusImg());
    const titleKey = `orcid.publication.inProfile.${isInOrcidProfile}`;
    statusSpan.title = await langService.translate(titleKey);
    statusSpan.appendChild(createThumbsElement(isInOrcidProfile));
    return statusSpan;
  };

  const handleStatusDiv = async (
    div: HTMLDivElement,
    accessToken: string,
    userStatus: MCROrcidUserStatus
  ): Promise<void> => {
    const objectId = div.dataset.objectId;
    const orcid = div.dataset.orcid;
    if (!objectId || !orcid) {
      console.error('ORCID status div is incomplete');
      return;
    }
    const workStatus = userStatus.trustedOrcids.includes(orcid)
      ? await workService.fetchWorkStatus(accessToken, orcid, objectId)
      : await workService.fetchWorkStatus(accessToken, orcid, objectId, true);
    const isInOrcidProfile = checkIsInOrcidProfile(workStatus);
    const statusElement = await createOrcidPublicationStatus(isInOrcidProfile);
    div.appendChild(statusElement);
  };

  const statusDivs = document.querySelectorAll<HTMLDivElement>('div.orcid-status');
  if (statusDivs.length > 0) {
    const accessToken = await getAccessToken();
    const orcidUserStatus = await new MCROrcidUserService(baseUrl).fetchOrcidUserStatus(accessToken);
    await langService.cacheTranslations('orcid.publication*');
    for (const div of statusDivs) {
      await handleStatusDiv(div, accessToken, orcidUserStatus);
    }
  }
};

document.addEventListener('DOMContentLoaded', initOrcidStatus);
