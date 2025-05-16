import { OrcidExportModalHandler } from './orcid-export-modal-handler';
import { OrcidApiClientFactory } from './orcid-utils';
import { getElementByIdOrThrow } from '../utils/ui';
import { LangServiceFactory } from '../utils/i18n';

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

export const getOrcidExportModalHandler = (): OrcidExportModalHandler => {
  if (!orcidExportModalHandler) {
    initializeExportModalHandler();
  }
  return orcidExportModalHandler!;
};
