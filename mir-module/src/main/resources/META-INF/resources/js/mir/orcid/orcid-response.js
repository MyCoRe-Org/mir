import getConfigurationService from '../config/config.js';
import getLangService from '../i18n/i18n.js';
import getAuthTokenService from '../auth/auth.js';
import { MIROrcidUserService, MIROrcidWorkService } from './orcid.js';

const createOrcidWorkService = async () => {
  const baseUrl = getConfigurationService().getBaseUrl();
  const accessToken = await getAuthTokenService().retrieveToken();
  return new MIROrcidWorkService(baseUrl, accessToken);
}

const createOrcidUserService = async () => {
  const baseUrl = getConfigurationService().getBaseUrl();
  const accessToken = await getAuthTokenService().retrieveToken();
  return new MIROrcidUserService(baseUrl, accessToken);
}

const createLangService = async () => {
  const langServiceInstance = getLangService();
  await langServiceInstance.fetchProperties('orcid.publication*');
  return langServiceInstance;
}

const initOrcidStatus = async () => {
  let workService = null;
  let orcidUserStatus = null;
  let langService = null;

  const createOrcidIconElement = () => {
    const orcidIcon =  document.createElement('img');
    orcidIcon.alt = 'ORCID iD';
    orcidIcon.classList.add('orcid-icon');
    orcidIcon.src = `${getConfigurationService().getBaseUrl()}images/orcid_icon.svg`;
    return orcidIcon;
  }

  const createThumbsElement = (up) => {
    const thumbsElement = document.createElement('span');
    thumbsElement.classList.add('far', `fa-thumbs-${up ? 'up' : 'down'}`, `orcid-in-profile-${up}`);
    return thumbsElement;
  };

  const createOrcidPublicationStatus = async (workStatus) => {
    const statusElement = document.createElement('span');
    statusElement.classList.add('orcid-info');
    statusElement.appendChild(createOrcidIconElement());
    const titleKey = checkIsInOrcidProfile(workStatus) 
      ? 'orcid.publication.inProfile.true' 
      : 'orcid.publication.inProfile.false';
    statusElement.title = await langService.getProperty(titleKey);
    statusElement.appendChild(createThumbsElement(checkIsInOrcidProfile(workStatus)));
    return statusElement;
  }

  const checkIsInOrcidProfile = (workStatus) => {
    return workStatus.own !== undefined || (workStatus.other !== undefined && workStatus.other.length > 0);
  }

  const handleStatusDiv = async (div) => {
    const objectId = div.dataset.objectId;
    const orcid = div.dataset.orcid;
    if (!objectId || !orcid) {
      console.error('ORCID status div is incomplete');
      return;
    }
    const workStatus = orcidUserStatus.trustedOrcids.includes(orcid)
      ? await workService.fetchWorkStatus(orcid, objectId)
      : await workService.fetchWorkStatus(orcid, objectId, true); 
    const statusElement = await createOrcidPublicationStatus(workStatus);
    div.appendChild(statusElement);
  }

  const statusDivs = document.querySelectorAll('div.orcid-status');
  for (const div of statusDivs) {
    if (!orcidUserStatus) {
      orcidUserStatus = await (await createOrcidUserService()).fetchCurrentUserOrcidStatus();
      workService = await createOrcidWorkService();
      langService = await createLangService();
    }
    await handleStatusDiv(div);
  }
};

document.addEventListener('DOMContentLoaded', initOrcidStatus);