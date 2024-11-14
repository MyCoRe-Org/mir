import { OrcidService } from './orcid.js';
import { I18nService } from './i18n.js';
import { fetchAccessToken } from './jwt.js';

const baseUrl = window['webApplicationBaseURL'];
const lang = window['currentLang'];

const initStatus = async () => {
  const accessToken = await fetchAccessToken(baseUrl);
  const orcidService = new OrcidService(baseUrl, accessToken);
  const i18nService = new I18nService(baseUrl);

  i18nService.fetchI18nData(lang, 'orcid.publication*');
  const userStatus = await orcidService.fetchUserStatus();

  const checkIsInOrcidProfile = (workStatus) => {
    return workStatus.own !== undefined || (workStatus.other !== undefined && workStatus.other.length > 0);
  }

  const createOrcidIconElement = () => {
    const orcidIcon =  document.createElement('img');
    orcidIcon.alt = 'ORCID iD';
    orcidIcon.classList.add('orcid-icon');
    orcidIcon.src = `${baseUrl}images/orcid_icon.svg`;
    return orcidIcon;
  }

  const createThumbsElement = (up) => {
    const thumbsElement = document.createElement('span');
    thumbsElement.classList.add('far');
    thumbsElement.classList.add(`fa-thumbs-${up ? 'up' : 'down'}`);
    thumbsElement.classList.add(`orcid-in-profile-${up}`);
    return thumbsElement;
  }

  const createOrcidPublicationStatus = (workStatus) => {
    const statusElement = document.createElement('span');
    statusElement.classList.add('orcid-info');
    statusElement.appendChild(createOrcidIconElement());
    if (checkIsInOrcidProfile(workStatus)) {
      statusElement.title = i18nService.translate('orcid.publication.inProfile.true')
      statusElement.appendChild(createThumbsElement(true));
    } else {
      statusElement.title = i18nService.translate('orcid.publication.inProfile.false');
      statusElement.appendChild(createThumbsElement(false));
    }
    return statusElement;
  }

  const createOrcidStatus = async (div, orcid, objectId) => {
    const workStatus = userStatus.trustedOrcids.includes(orcid)
      ? await orcidService.fetchWorkStatus(orcid, objectId)
      : await orcidService.fetchWorkStatus(orcid, objectId, true); 
    const statusElement = createOrcidPublicationStatus(workStatus);
    div.appendChild(statusElement);
  }

  document.querySelectorAll('div.orcid-status').forEach(async (div) => {
    const objectId = div.dataset.objectId;
    const orcid = div.dataset.orcid;
    if (objectId && orcid) {
      await createOrcidStatus(div, orcid, objectId);
    }
  });
};

document.addEventListener('DOMContentLoaded', initStatus);