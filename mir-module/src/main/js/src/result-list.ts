import { getBaseUrl, getLangService } from './common/helpers.js';
import { OrcidUserStatus, OrcidWorkStatus } from '@jsr/mycore__js-common/orcid';
import { OrcidServiceFactory } from './orcid/orcid-service-factory.js';

const baseUrl = getBaseUrl();

const createOrcidStatusImg = (): HTMLImageElement => {
  const orcidIcon = document.createElement('img');
  orcidIcon.alt = 'ORCID iD';
  orcidIcon.classList.add('orcid-icon');
  orcidIcon.src = `${baseUrl}images/orcid_icon.svg`;
  return orcidIcon;
};

const createThumbsElement = (up: boolean): HTMLSpanElement => {
  const thumbsElement = document.createElement('span');
  thumbsElement.classList.add(
    'far',
    `fa-thumbs-${up ? 'up' : 'down'}`,
    `orcid-in-profile-${up}`
  );
  return thumbsElement;
};

const checkIsInOrcidProfile = (workStatus: OrcidWorkStatus): boolean => {
  return (
    workStatus.own !== undefined ||
    (workStatus.other !== undefined && workStatus.other.length > 0)
  );
};

const initOrcidStatus = async (): Promise<void> => {
  const langService = getLangService();

  const createOrcidPublicationStatus = async (
    isInOrcidProfile: boolean
  ): Promise<HTMLSpanElement> => {
    const statusSpan = document.createElement('span');
    statusSpan.classList.add('orcid-info');
    statusSpan.appendChild(createOrcidStatusImg());
    statusSpan.title = await langService.translate(
      `orcid.publication.inProfile.${isInOrcidProfile}`
    );
    statusSpan.appendChild(createThumbsElement(isInOrcidProfile));
    return statusSpan;
  };

  const handleStatusDiv = async (
    div: HTMLDivElement,
    userStatus: OrcidUserStatus
  ): Promise<void> => {
    const objectId = div.dataset.objectId;
    const orcid = div.dataset.orcid;
    if (!objectId || !orcid) {
      console.error('ORCID status div is incomplete');
      return;
    }
    const workService = await OrcidServiceFactory.getWorkService();
    const workStatus = userStatus.trustedOrcids.includes(orcid)
      ? await workService.getWorkStatus(orcid, objectId, 'public')
      : await workService.getWorkStatus(orcid, objectId, 'member');
    const isInOrcidProfile = checkIsInOrcidProfile(workStatus);
    const statusElement = await createOrcidPublicationStatus(isInOrcidProfile);
    div.appendChild(statusElement);
  };

  const statusDivs =
    document.querySelectorAll<HTMLDivElement>('div.orcid-status');
  if (statusDivs.length > 0) {
    const orcidUserStatus = await (
      await OrcidServiceFactory.getUserService()
    ).getUserStatus();
    for (const div of statusDivs) {
      await handleStatusDiv(div, orcidUserStatus);
    }
  }
};

document.addEventListener('DOMContentLoaded', initOrcidStatus);
