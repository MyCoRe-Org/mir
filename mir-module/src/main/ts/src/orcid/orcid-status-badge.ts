import {
  OrcidUserStatus,
  OrcidWorkApiClient,
  OrcidWorkStatus,
} from '@jsr/mycore__js-common/orcid';

export const ORCID_BADGE_BASE_CLASS = 'mir-badge-orcid-in-profile';
const I18N_PREFIX = 'mir.orcid.publication.badge.inProfile.';

export class OrcidStatusBadge {
  private workClient: OrcidWorkApiClient;
  private userStatus: OrcidUserStatus;
  private getTranslations: (prefix: string) => Promise<Record<string, string>>;

  constructor(
    workClient: OrcidWorkApiClient,
    userStatus: OrcidUserStatus,
    getTranslations: (prefix: string) => Promise<Record<string, string>>
  ) {
    this.workClient = workClient;
    this.userStatus = userStatus;
    this.getTranslations = getTranslations;
  }

  public async render(span: HTMLSpanElement): Promise<void> {
    const { objectId } = span.dataset;
    if (!objectId) {
      console.error('ORCID status div is missing data attributes:', { span });
      return;
    }

    const checkedOrcids = new Set<string>();

    const allOrcids = [
      ...this.userStatus.trustedOrcids.map(id => ({
        orcid: id,
        trusted: true,
      })),
      ...this.userStatus.orcids.map(id => ({ orcid: id, trusted: false })),
    ];

    for (const { orcid, trusted } of allOrcids) {
      // skip already checked orcids
      if (checkedOrcids.has(orcid)) {
        continue;
      }
      try {
        const workStatus = await this.workClient.getWorkStatus(
          orcid,
          objectId,
          trusted ? 'member' : 'public'
        );

        if (this.checkIsInOrcidProfile(workStatus)) {
          await this.finalizeBadge(span, true);
          return;
        } else {
          checkedOrcids.add(orcid);
        }
      } catch {
        console.warn(
          `Could not fetch work status for ${objectId} and ${orcid}`
        );
      }
    }
    await this.finalizeBadge(span, false);
  }

  private checkIsInOrcidProfile(workStatus: OrcidWorkStatus): boolean {
    return !!(workStatus.own ?? workStatus.other?.length);
  }

  private async finalizeBadge(
    span: HTMLSpanElement,
    isInOrcidProfile: boolean
  ): Promise<void> {
    span.classList.remove(ORCID_BADGE_BASE_CLASS);
    const translations = await this.getTranslations(
      `${I18N_PREFIX}${isInOrcidProfile}*`
    );
    span.classList.add(`${ORCID_BADGE_BASE_CLASS}-${isInOrcidProfile}`);
    const textEl = span.querySelector(`.${ORCID_BADGE_BASE_CLASS}-text`);
    if (textEl) {
      textEl.innerHTML = translations[`${I18N_PREFIX}${isInOrcidProfile}`];
    }
    span.setAttribute('data-bs-toggle', 'tooltip');
    span.setAttribute(
      'title',
      translations[`${I18N_PREFIX}${isInOrcidProfile}.tooltip`]
    );
  }
}
