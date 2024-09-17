import {
  OrcidUserService,
  OrcidWorkService,
} from '@jsr/mycore__js-common/orcid';
import { MIROrcidExportModal } from './orcid/orcid-export-modal';
import { OrcidServiceFactory } from './orcid/orcid-service-factory';

const initOrcidExportModal = (
  userService: OrcidUserService,
  workService: OrcidWorkService
): MIROrcidExportModal => {
  const modalDiv: HTMLDivElement | null = document.querySelector(
    '#exportToOrcidModal'
  );
  const exportBtn: HTMLButtonElement | null =
    document.querySelector('#exportToOrcidBtn');
  const profileSelect: HTMLSelectElement | null = document.querySelector(
    '#orcidProfileSelect'
  );
  const alertDiv: HTMLDivElement | null = document.querySelector('#alertDiv');
  if (!modalDiv || !exportBtn || !profileSelect || !alertDiv) {
    throw new Error('check input');
  }
  return new MIROrcidExportModal(
    modalDiv,
    userService,
    workService,
    exportBtn,
    profileSelect,
    alertDiv
  );
};

let orcidExportModalInstance: MIROrcidExportModal;
const getOrcidExportModalInstance = async (): Promise<MIROrcidExportModal> => {
  if (!orcidExportModalInstance) {
    orcidExportModalInstance = initOrcidExportModal(
      await OrcidServiceFactory.getUserService(),
      await OrcidServiceFactory.getWorkService()
    );
  }
  return orcidExportModalInstance;
};

const initExportModal = async (): Promise<void> => {
  const appendMenuButton = () => {
    const menu: HTMLDivElement | null = document.querySelector(
      'div#mir-edit-div ul.dropdown-menu'
    );
    const item: HTMLDivElement | null = document.querySelector(
      'li#publishToOrcidMenuItem'
    );
    if (menu && item) {
      menu.append(item);
    }
  };

  const handleOpenModal = async (event: MouseEvent): Promise<void> => {
    const button = event.currentTarget as HTMLButtonElement;
    const objectId = button.getAttribute('data-object-id');
    if (objectId) {
      const modalHandler = await getOrcidExportModalInstance();
      modalHandler.open(objectId);
    }
  };

  const openModalBtn: HTMLDivElement | null = document.querySelector(
    '#openPublishToOrcidModal'
  );
  if (openModalBtn) {
    openModalBtn.addEventListener('click', handleOpenModal);
    appendMenuButton();
  }
};

document.addEventListener('DOMContentLoaded', initExportModal);
