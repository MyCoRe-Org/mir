import {
  OrcidUserStatus,
  OrcidWorkApiClient,
  OrcidWorkStatus,
} from '@jsr/mycore__js-common/orcid';
import { OrcidApiClientFactory } from './orcid/orcid-utils.js';
import { LangServiceFactory } from './utils/i18n.js';
import { getBaseUrl } from './utils/config.js';

const ORCID_ICON_CLASS = 'orcid-icon';
const ORCID_INFO_CLASS = 'orcid-info';
const ORCID_IN_PROFILE_CLASS_PREFIX = 'orcid-in-profile-';

const createOrcidStatusImg = (): HTMLImageElement => {
  const orcidIcon = document.createElement('img');
  orcidIcon.alt = 'ORCID iD';
  orcidIcon.classList.add(ORCID_ICON_CLASS);
  orcidIcon.src = `${getBaseUrl()}images/orcid_icon.svg`;
  return orcidIcon;
};

const createThumbsElement = (up: boolean): HTMLSpanElement => {
  const thumbsElement = document.createElement('span');
  thumbsElement.classList.add(
    'far',
    `fa-thumbs-${up ? 'up' : 'down'}`,
    `${ORCID_IN_PROFILE_CLASS_PREFIX}${up}`
  );
  return thumbsElement;
};

const createOrcidPublicationStatus = async (
  isInOrcidProfile: boolean
): Promise<HTMLSpanElement> => {
  const statusSpan = document.createElement('span');
  statusSpan.classList.add(ORCID_INFO_CLASS);

  statusSpan.appendChild(createOrcidStatusImg());

  const langService = LangServiceFactory.getLangService();
  const translatedTitle = await langService.translate(
    `mir.orcid.publication.badge.inProfile.${isInOrcidProfile}`
  );
  statusSpan.title = translatedTitle;
  statusSpan.setAttribute('aria-label', translatedTitle);

  statusSpan.appendChild(createThumbsElement(isInOrcidProfile));
  return statusSpan;
};

const checkIsInOrcidProfile = (workStatus: OrcidWorkStatus): boolean =>
  !!(workStatus.own ?? workStatus.other?.length);

const processStatusDiv = async (
  div: HTMLDivElement,
  workClient: OrcidWorkApiClient,
  userStatus: OrcidUserStatus
): Promise<void> => {
  const { objectId, orcid } = div.dataset;
  if (!objectId || !orcid) {
    console.error('ORCID status div is missing data attributes:', { div });
    return;
  }
  const workStatus = userStatus.trustedOrcids.includes(orcid)
    ? await workClient.getWorkStatus(orcid, objectId, 'public')
    : await workClient.getWorkStatus(orcid, objectId, 'member');

  const isInOrcidProfile = checkIsInOrcidProfile(workStatus);
  const statusElement = await createOrcidPublicationStatus(isInOrcidProfile);

  div.appendChild(statusElement);
};

const setupStatusHandler = async (): Promise<void> => {
  const statusDivs =
    document.querySelectorAll<HTMLDivElement>('div.orcid-status');
  if (!statusDivs.length) return;
  const orcidUserStatus =
    await OrcidApiClientFactory.getUserService().getUserStatus();
  await Promise.all(
    Array.from(statusDivs).map((div: HTMLDivElement): void => {
      try {
        processStatusDiv(
          div,
          OrcidApiClientFactory.getWorkService(),
          orcidUserStatus
        );
      } catch (error) {
        console.error('Error processing ORCID status:', error);
      }
    })
  );
};

document.addEventListener('DOMContentLoaded', setupStatusHandler);
