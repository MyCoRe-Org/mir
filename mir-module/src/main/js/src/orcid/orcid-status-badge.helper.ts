import { OrcidStatusBadge } from './orcid-status-badge';
import { OrcidApiClientFactory } from './orcid-utils';
import { LangServiceFactory } from '../utils/i18n.js';

const DEFAULT_STATUS_BADGE_SELECTOR = 'span.mir-badge-orcid-in-profile';

export const setupStatusBadges = async (
  elements = document.querySelectorAll<HTMLDivElement>(
    DEFAULT_STATUS_BADGE_SELECTOR
  ),
  userStatusGetter = () =>
    OrcidApiClientFactory.getUserService().getUserStatus(),
  workClientGetter = () => OrcidApiClientFactory.getWorkService(),
  translate = (key: string) =>
    LangServiceFactory.getLangService().translate(key)
): Promise<void> => {
  if (!elements.length) return;
  const userStatus = await userStatusGetter();
  const badge = new OrcidStatusBadge(workClientGetter(), userStatus, translate);

  await Promise.all(
    Array.from(elements).map(div =>
      badge.render(div).catch(err => {
        console.error('Error rendering ORCID badge:', err);
      })
    )
  );
};
