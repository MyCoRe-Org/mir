import { Tooltip } from 'bootstrap';
import { OrcidStatusBadge, ORCID_BADGE_BASE_CLASS } from './orcid-status-badge';
import { OrcidApiClientFactory } from './orcid-utils';
import { LangServiceFactory } from '../utils/i18n.js';

const DEFAULT_STATUS_BADGE_SELECTOR = `span.${ORCID_BADGE_BASE_CLASS}`;

export const setupStatusBadges = async (
  elements = document.querySelectorAll<HTMLDivElement>(
    DEFAULT_STATUS_BADGE_SELECTOR
  ),
  userStatusGetter = () =>
    OrcidApiClientFactory.getUserService().getUserStatus(),
  workClientGetter = () => OrcidApiClientFactory.getWorkService(),
  getTranslations = (prefix: string) =>
    LangServiceFactory.getLangService().getTranslations(prefix)
): Promise<void> => {
  if (!elements.length) return;
  const userStatus = await userStatusGetter();
  const badge = new OrcidStatusBadge(
    workClientGetter(),
    userStatus,
    getTranslations
  );
  await Promise.all(
    Array.from(elements).map(div =>
      badge.render(div).catch(err => {
        console.error('Error rendering ORCID badge:', err);
      })
    )
  );
  document
    .querySelectorAll(
      `span[class*="${ORCID_BADGE_BASE_CLASS}"][data-bs-toggle="tooltip"]`
    )
    .forEach(el => {
      new Tooltip(el);
    });
};
