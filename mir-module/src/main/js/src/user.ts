import {
  OrcidUserService,
  getOrcidAuthInitUrl,
} from '@jsr/mycore__js-common/orcid';
import { getBaseUrl } from './utils/config';
import { MIROrcidUserSettingsModal } from './orcid/orcid-user-settings-modal';
import { OrcidServiceFactory } from './orcid/orcid-service-factory';

const initOrcidSettingsModal = (
  userService: OrcidUserService
): MIROrcidUserSettingsModal => {
  const modalEl: HTMLElement | null = document.querySelector(
    '#orcid-settings-modal'
  );
  const settingsForm: HTMLFormElement | null = document.querySelector(
    '#orcid-settings-form'
  );
  const saveBtn: HTMLButtonElement | null = document.querySelector(
    '#save-orcid-settings-btn'
  );
  const alertDiv: HTMLDivElement | null = document.querySelector(
    '#orcid-missing-setting-alert'
  );
  const titleEl: HTMLElement | null =
    document.querySelector('#modal-title-orcid');
  if (!modalEl || !settingsForm || !saveBtn || !alertDiv || !titleEl) {
    throw new Error('check input');
  }
  return new MIROrcidUserSettingsModal(
    modalEl,
    userService,
    settingsForm,
    saveBtn,
    alertDiv,
    titleEl
  );
};

let orcidSettingsModalInstance: MIROrcidUserSettingsModal;
const getSettingsModalInstance =
  async (): Promise<MIROrcidUserSettingsModal> => {
    if (!orcidSettingsModalInstance) {
      orcidSettingsModalInstance = initOrcidSettingsModal(
        await OrcidServiceFactory.getUserService()
      );
    }
    return orcidSettingsModalInstance;
  };

const handleOpenOrcidSettingsModal = async (event: Event): Promise<void> => {
  const targetElement = event.currentTarget as HTMLElement;
  const { orcid } = targetElement.dataset;
  if (!orcid) {
    console.error('ORCID iD is missing.');
    return;
  }
  (await getSettingsModalInstance()).openModal(orcid);
};

const doInitOrcidOAuth = (scope: string | null): void => {
  const width = 540;
  const height = 750;
  let left = 0;
  let top = 0;
  if (window.top) {
    left = window.top.outerWidth / 2 + window.top.screenX - width / 2;
    top = window.top.outerHeight / 2 + window.top.screenY - height / 2;
  }
  const initUrl = getOrcidAuthInitUrl(
    getBaseUrl(),
    scope !== null ? scope : undefined
  );
  const w = window.open(
    initUrl,
    '_blank',
    `toolbar=no, width=${width}, height=${height}, top=${top}, left=${left}`
  );
  w?.addEventListener('beforeunload', () => {
    window.location.reload();
  });
};

const doRevokeOrcidOAuth = async (
  orcid: string,
  redirectUrl: string | null
): Promise<void> => {
  await (await OrcidServiceFactory.getUserService()).revokeAuth(orcid);
  if (redirectUrl) {
    window.location.href = redirectUrl;
  }
};

const handleRevokeOrcidOAuth = async (event: Event): Promise<void> => {
  const target = event.target as HTMLButtonElement;
  const orcid: string | null = target.getAttribute('data-orcid');
  if (orcid) {
    await doRevokeOrcidOAuth(orcid, target.getAttribute('data-redirect-url'));
  } else {
    console.error('Orcid is required to revoke Orcid OAuth');
  }
};

const init = (): void => {
  const openOrcidSettingsModalBtns: NodeListOf<HTMLButtonElement> =
    document.querySelectorAll('button.open-orcid-settings');
  openOrcidSettingsModalBtns.forEach((button: HTMLButtonElement) => {
    button.addEventListener(
      'click',
      async (event: MouseEvent) => await handleOpenOrcidSettingsModal(event)
    );
  });
  const revokeOrcidBtns: NodeListOf<HTMLButtonElement> =
    document.querySelectorAll('button.revoke-orcid-oauth');
  revokeOrcidBtns.forEach((button: HTMLButtonElement) => {
    button.addEventListener('click', async (event: MouseEvent) =>
      handleRevokeOrcidOAuth(event)
    );
  });
  const initOrcidBtn: HTMLButtonElement | null =
    document.querySelector('#initOrcidOAuthBtn');
  if (initOrcidBtn) {
    const scope: string | null = initOrcidBtn.getAttribute('data-scope');
    initOrcidBtn.addEventListener('click', () => {
      doInitOrcidOAuth(scope);
    });
  }
};

document.addEventListener('DOMContentLoaded', init);
