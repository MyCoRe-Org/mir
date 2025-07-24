import { getOrcidAuthInitUrl } from '@jsr/mycore__js-common/orcid';
import { OrcidUserSettingsModalController } from './orcid/orcid-user-settings-modal-controller';
import { OrcidApiClientFactory } from './orcid/orcid-utils';
import { getBaseUrl } from './utils/config';
import { getElementByIdOrThrow } from './utils/ui';

let orcidUserSettingsModalController: OrcidUserSettingsModalController | null =
  null;

const setupSettingsModalController = (): void => {
  const modalEl = document.getElementById('orcidSettingsModal');
  if (!modalEl) return;
  const form = getElementByIdOrThrow<HTMLFormElement>('orcidSettingsForm');
  orcidUserSettingsModalController = new OrcidUserSettingsModalController({
    modalEl,
    userClient: OrcidApiClientFactory.getUserService(),
    uiElements: {
      saveBtn: getElementByIdOrThrow<HTMLButtonElement>('saveOrcidSettingsBtn'),
      checkboxes: form.querySelectorAll<HTMLInputElement>(
        'input[type="checkbox"]'
      ),
      titleEl: getElementByIdOrThrow<HTMLDivElement>('modalTitleOrcid'),
      infoAlert: getElementByIdOrThrow<HTMLDivElement>(
        'orcidMissingSettingAlert'
      ),
    },
  });
};

const setupOpenOrcidSettingsBtns = (): void => {
  document
    .querySelectorAll<HTMLLIElement>('.open-orcid-settings')
    .forEach(el => {
      el.addEventListener('click', async (): Promise<void> => {
        if (el.dataset.orcid)
          await orcidUserSettingsModalController!.open(el.dataset.orcid);
      });
    });
};

const handleRevocation = async (
  orcid: string,
  redirectUrl?: string
): Promise<void> => {
  await OrcidApiClientFactory.getUserService().revokeAuth(orcid);
  if (redirectUrl) {
    window.location.href = redirectUrl;
  }
};

const setupAuthRevocationBtn = (): void => {
  document.body.addEventListener(
    'click',
    async (event: MouseEvent): Promise<void> => {
      const btn = (event.target as Element).closest(
        'button.revoke-orcid-oauth'
      );
      if (!(btn instanceof HTMLButtonElement)) return;
      const { orcid, redirectUrl } = btn.dataset;
      if (orcid) await handleRevocation(orcid, redirectUrl);
    }
  );
};

const calculatePopupFeatures = (): string => {
  const width = 540;
  const height = 750;
  const parentWindow = window.top ?? window;
  const left = parentWindow.outerWidth / 2 + parentWindow.screenX - width / 2;
  const top = parentWindow.outerHeight / 2 + parentWindow.screenY - height / 2;
  return `toolbar=no, width=${width}, height=${height}, top=${top}, left=${left}`;
};

const openAuthPopup = (scope?: string): Window | null => {
  const initUrl = getOrcidAuthInitUrl(getBaseUrl(), scope);
  const popup = window.open(initUrl, '_blank', calculatePopupFeatures());
  if (!popup || popup.closed) {
    console.warn('Popup blocked or closed immediately');
  }
  return popup;
};

const handleOAuthInit = (scope?: string): void => {
  const popup = openAuthPopup(scope);
  popup?.addEventListener('beforeunload', () => {
    window.location.reload();
  });
};

const setupAuthInitBtn = (): void => {
  document
    .getElementById('initOrcidOAuthBtn')
    ?.addEventListener('click', (e: MouseEvent): void => {
      const btn = e.currentTarget as HTMLButtonElement;
      handleOAuthInit(btn.dataset.scope);
    });
};

document.addEventListener('DOMContentLoaded', (): void => {
  setupAuthInitBtn();
  setupAuthRevocationBtn();
  setupSettingsModalController();
  setupOpenOrcidSettingsBtns();
});
