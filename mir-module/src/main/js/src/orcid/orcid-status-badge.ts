import {
  OrcidUserStatus,
  OrcidWorkApiClient,
  OrcidWorkStatus,
} from '@jsr/mycore__js-common/orcid';

export class OrcidStatusBadge {
  private workClient: OrcidWorkApiClient;
  private userStatus: OrcidUserStatus;
  private translate: (key: string) => Promise<string>;

  constructor(
    workClient: OrcidWorkApiClient,
    userStatus: OrcidUserStatus,
    translate: (key: string) => Promise<string>
  ) {
    this.workClient = workClient;
    this.userStatus = userStatus;
    this.translate = translate;
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
    span.classList.remove('mir-badge-orcid-in-profile');
    const label = await this.translate(
      `mir.orcid.publication.badge.inProfile.${isInOrcidProfile}`
    );
    if (isInOrcidProfile) {
      span.classList.add('mir-badge-orcid-in-profile-true');
    } else {
      span.classList.add('mir-badge-orcid-in-profile-false');
    }
    const textEl = span.querySelector('.mir-orcid-badge-in-profile-text');
    if (textEl) {
      textEl.innerHTML = label;
    }
    // TODO add tooltip related orcid to badge
  }
}
