import {
  OrcidUserStatus,
  OrcidWorkApiClient,
  OrcidWorkStatus,
} from '@jsr/mycore__js-common/orcid';

export class OrcidStatusBadge {
  private workClient: OrcidWorkApiClient;
  private userStatus: OrcidUserStatus;
  private translate: (key: string) => Promise<string>;
  private baseUrl: string;

  constructor(
    workClient: OrcidWorkApiClient,
    userStatus: OrcidUserStatus,
    translate: (key: string) => Promise<string>,
    baseUrl: string
  ) {
    this.workClient = workClient;
    this.userStatus = userStatus;
    this.translate = translate;
    this.baseUrl = baseUrl;
  }

  public async render(div: HTMLDivElement): Promise<void> {
    const { objectId } = div.dataset;
    if (!objectId) {
      console.error('ORCID status div is missing data attributes:', { div });
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
          const statusElement = await this.createStatusElement(true);
          div.appendChild(statusElement);
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
    const statusElement = await this.createStatusElement(false);
    div.appendChild(statusElement);
  }

  private checkIsInOrcidProfile(workStatus: OrcidWorkStatus): boolean {
    return !!(workStatus.own ?? workStatus.other?.length);
  }

  private createOrcidIcon(): HTMLImageElement {
    const icon = document.createElement('img');
    icon.alt = 'ORCID iD';
    icon.classList.add('orcid-icon');
    icon.src = `${this.baseUrl}images/orcid_icon.svg`;
    return icon;
  }

  private createThumbsElement(up: boolean): HTMLSpanElement {
    const el = document.createElement('span');
    el.classList.add(
      'far',
      `fa-thumbs-${up ? 'up' : 'down'}`,
      `orcid-in-profile-${up}`
    );
    return el;
  }

  private async createStatusElement(
    isInOrcidProfile: boolean
  ): Promise<HTMLSpanElement> {
    const span = document.createElement('span');
    span.classList.add('orcid-info');

    const icon = this.createOrcidIcon();
    span.appendChild(icon);

    const label = await this.translate(
      `mir.orcid.publication.badge.inProfile.${isInOrcidProfile}`
    );
    span.title = label;
    span.setAttribute('aria-label', label);

    span.appendChild(this.createThumbsElement(isInOrcidProfile));
    return span;
  }
}
