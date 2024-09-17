import { OrcidStatusBadge } from './orcid-status-badge';
import { OrcidApiClientFactory } from './orcid-utils';
import { getBaseUrl } from '../utils/config.js';
import { LangServiceFactory } from '../utils/i18n.js';

const DEFAULT_STATUS_BADGE_SELECTOR = 'div.mir-badge-orcid';

export const setupStatusBadges = async (
  elements = document.querySelectorAll<HTMLDivElement>(
    DEFAULT_STATUS_BADGE_SELECTOR
  ),
  userStatusGetter = () =>
    OrcidApiClientFactory.getUserService().getUserStatus(),
  workClientGetter = () => OrcidApiClientFactory.getWorkService(),
  translate = (key: string) =>
    LangServiceFactory.getLangService().translate(key),
  baseUrl = getBaseUrl().toString()
): Promise<void> => {
  if (!elements.length) return;
  const userStatus = await userStatusGetter();
  const badge = new OrcidStatusBadge(
    workClientGetter(),
    userStatus,
    translate,
    baseUrl
  );

  await Promise.all(
    Array.from(elements).map(div =>
      badge.render(div).catch(err => {
        console.error('Error rendering ORCID badge:', err);
      })
    )
  );
};
