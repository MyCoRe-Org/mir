import { OrcidExportModalHandler } from './orcid/orcid-export-modal-handler';
import { OrcidApiClientFactory } from './orcid/orcid-utils';
import { LangServiceFactory } from './utils/i18n';
import { getElementByIdOrThrow } from './utils/ui';

let orcidExportModalHandler: OrcidExportModalHandler | null = null;

const initializeExportModalHandler = (): void => {
  orcidExportModalHandler = new OrcidExportModalHandler({
    modalEl: getElementByIdOrThrow('exportToOrcidModal')!,
    workClient: OrcidApiClientFactory.getWorkService(),
    userClient: OrcidApiClientFactory.getUserService(),
    langService: LangServiceFactory.getLangService(),
    uiElements: {
      exportBtn: getElementByIdOrThrow<HTMLButtonElement>('exportToOrcidBtn'),
      orcidSelect:
        getElementByIdOrThrow<HTMLSelectElement>('orcidProfileSelect'),
      alertDiv: getElementByIdOrThrow<HTMLDivElement>('alertDiv'),
    },
  });
};

const getOrcidExportModalHandler = (): OrcidExportModalHandler => {
  if (!orcidExportModalHandler) {
    initializeExportModalHandler();
  }
  return orcidExportModalHandler!;
};

const appendMenuButton = (): void => {
  const MENU_SELECTOR = 'div#mir-edit-div ul.dropdown-menu';
  const ITEM_SELECTOR = 'li#exportToOrcidMenuItem';
  const menu = document.querySelector<HTMLDivElement>(MENU_SELECTOR);
  const item = document.querySelector<HTMLLIElement>(ITEM_SELECTOR);
  if (menu && item) {
    menu.append(item);
  }
};

document.addEventListener('DOMContentLoaded', (): void => {
  const OPEN_MODAL_SELECTOR = '#openExportToOrcidModal';
  const openModalBtn =
    document.querySelector<HTMLButtonElement>(OPEN_MODAL_SELECTOR);
  if (!openModalBtn) return;
  appendMenuButton();
  openModalBtn.addEventListener('click', (): void => {
    try {
      const { objectId } = openModalBtn.dataset;
      if (objectId) getOrcidExportModalHandler().open(objectId);
    } catch (error) {
      console.error('Error opening ORCID modal:', error);
    }
  });
});
