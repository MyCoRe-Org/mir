class I18nService {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
  }

  fetchI18nData = async (lang, key) => {
    const response = await fetch(`${this.baseUrl}rsc/locale/translate/${lang}/${key}`);
    if (!response.ok) {
      throw new Error('Failed to fetch I18n data.');
    }
    this.i18nData = await response.json();
  }

  translate = (property) => {
    if (property in this.i18nData) {
      return this.i18nData[property];
    }
    return property;
  }
}

const fetchAccessToken = async (baseUrl) => {
  const response = await fetch(`${baseUrl}rsc/jwt`);
  if (!response.ok) {
    throw new Error('Failed to fetch JWT for current user.');
  }
  const result = await response.json();
  if (!result.login_success) {
    throw new Error('Login failed.');
  }
  return result.access_token;
}

class OrcidService {
  constructor(baseUrl, accessToken) {
    this.baseUrl = baseUrl;
    this.accessToken = accessToken;
  }

  fetchUserStatus = async () => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/user-status`, {
      headers: { Authorization: `Bearer ${this.accessToken}`}
    });
    if (!response.ok) {
      throw new Error('Failed to fetch Orcid user status');
    }
    return await response.json();
  }

  fetchWorkStatus = async (orcid, objectId, useMember = false) => {
    const mode = useMember ? 'member' : 'public';
    const response = await fetch(`${this.baseUrl}api/orcid/v1/${mode}/${orcid}/works/object/${objectId}`, {
      headers: { Authorization: `Bearer ${this.accessToken}`}
    });
    if (!response.ok) {
      throw new Error(`Failed to fetch work status for ${objectId}.`);
    }
    return await response.json();
  }

  publishObjectToOrcid = async (orcid, objectId) => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/member/${orcid}/works/object/${objectId}`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${this.accessToken}`},
    });
    if (!response.ok) {
      throw new Error(`Failed to publish ${objectId} to ${orcid}.`);
    }
  }
}

const baseUrl = window['webApplicationBaseURL'];
const lang = window['currentLang'];

document.addEventListener('DOMContentLoaded', async () => {
  const i18nService = new I18nService(baseUrl);
  i18nService.fetchI18nData(lang, 'orcid.publication*');
  const accessToken = await fetchAccessToken(baseUrl);
  const orcidService = new OrcidService(baseUrl, accessToken);
  const userStatus = await orcidService.fetchUserStatus();

  const checkIsInOrcidProfile = (workStatus) => {
    return workStatus.own !== undefined || (workStatus.other !== undefined && workStatus.other.length > 0);
  }

  const createOrcidIconElement = () => {
    const orcidIcon =  document.createElement('img');
    orcidIcon.alt = 'ORCID iD';
    orcidIcon.classList.add('orcid-icon');
    orcidIcon.src = `${baseUrl}images/orcid_icon.svg`;
    return orcidIcon;
  }

  const createThumbsElement = (up) => {
    const thumbsElement = document.createElement('span');
    thumbsElement.classList.add('far');
    thumbsElement.classList.add(`fa-thumbs-${up ? 'up' : 'down'}`);
    thumbsElement.classList.add(`orcid-in-profile-${up}`);
    return thumbsElement;
  }

	const createOrcidPublicationStatus = (workStatus) => {
    const statusElement = document.createElement('span');
    statusElement.classList.add('orcid-info');
    statusElement.appendChild(createOrcidIconElement());
    if (checkIsInOrcidProfile(workStatus)) {
      statusElement.title = i18nService.translate('orcid.publication.inProfile.true')
      statusElement.appendChild(createThumbsElement(true));
    } else {
      statusElement.title = i18nService.translate('orcid.publication.inProfile.false');
      statusElement.appendChild(createThumbsElement(false));
    }
    return statusElement;
	}

  const createOrcidStatus = async (div, orcid, objectId) => {
    const workStatus = userStatus.trustedOrcids.includes(orcid)
      ? await orcidService.fetchWorkStatus(orcid, objectId)
      : await orcidService.fetchWorkStatus(orcid, objectId, true); 
    const statusElement = createOrcidPublicationStatus(workStatus);
    div.appendChild(statusElement);
  }

  document.querySelectorAll('div.orcid-status').forEach(async (div) => {
    const objectId = div.dataset.objectId;
    const orcid = div.dataset.orcid;
    if (objectId && orcid) {
      await createOrcidStatus(div, orcid, objectId);
    }
  });
});

// TODO kill jquery
class OrcidExportModal {
  constructor(modalId, exportButtonId, orcidSelectId) {
    this.modal = $(modalId);
    this.exportButton = this.modal.find(exportButtonId);
    this.orcidSelect = this.modal.find(orcidSelectId);
    this.modal.on('show.bs.modal', (event) => this.showModalHandler(event));
    this.exportButton.on('click', () => this.exportToOrcid());
    this.orcidSelect.on('change', () => this.handleSelectChange());
  }

  showModalHandler = async (event) => {
    const button = $(event.relatedTarget);
    this.objectId = button.data('objectId');
    const accessToken = await fetchAccessToken(baseUrl);
    this.orcidService = new OrcidService(baseUrl, accessToken);
    const userStatus = await this.orcidService.fetchUserStatus();
    userStatus.trustedOrcids.forEach((o) => {
      this.orcidSelect.append(new Option(o, o));
    })
  }

  exportToOrcid = async () => {
    const selectedOrcid = this.orcidSelect.val();
    if (selectedOrcid !== "") {
      await this.orcidService.publishObjectToOrcid(selectedOrcid, this.objectId);
      alert('orcid.publication.action.confirmation');
    }
  }

  handleSelectChange = () => {
    const selectedValue = this.orcidSelect.val();
    if (selectedValue !== "") {
      console.log(selectedValue);
    }
  }
}

$(document).ready(() => {
  new OrcidExportModal('#exportToOrcidModal', '#exportToOrcidBtn', '#orcidProfileSelect');
});