import { OrcidExportModalController } from './orcid-export-modal-controller';
import { OrcidApiClientFactory } from './orcid-utils';
import { LangServiceFactory } from '../utils/i18n';
import { getElementByIdOrThrow } from '../utils/ui';

let orcidExportModalController: OrcidExportModalController | null = null;

export const setupExportModalContoller = (): void => {
  orcidExportModalController = new OrcidExportModalController({
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

export const getOrcidExportModalController = (): OrcidExportModalController => {
  if (!orcidExportModalController) {
    throw new Error('ORCID export modal controller is not initialized');
  }
  return orcidExportModalController!;
};
