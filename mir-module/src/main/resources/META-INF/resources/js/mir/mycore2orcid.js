class OrcidService {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
    this.accessToken = null;
  }

  fetchAccessToken = async () => {
    const response = await fetch(`${this.baseUrl}rsc/jwt`);
    if (!response.ok) {
      throw new Error('Failed to fetch JWT for current user.');
    }
    const result = await response.json();
    if (!result.login_success) {
      throw new Error('Login failed.');
    }
    this.accessToken = result.access_token;
  }

  getWorkStatus = async (orcid, objectId) => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/${orcid}/work-status?objectId=${objectId}`, {
      headers: { Authorization: `Bearer ${this.accessToken}`}
    });
    if (!response.ok) {
      throw new Error(`Failed to fetch work status for ${objectId}.`);
    }
    return await response.json();
  }

  publishObjectToOrcid = async (orcid, objectId) => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/${orcid}/create-work?objectId=${objectId}`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${this.accessToken}`},
    });
    if (!response.ok) {
      throw new Error(`Failed to publish ${objectId} to ORCID profile.`);
    }
  }
}

class I18nService {
  constructor(baseUrl, lang) {
    this.baseUrl = baseUrl;
    this.lang = lang;
  }

  fetchI18nData = async (key) => {
    const response = await fetch(`${webApplicationBaseUrl}rsc/locale/translate/${lang}/${key}`);
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

class OrcidUi {
  constructor(baseUrl, i18nService, orcidService) {
    this.baseUrl = baseUrl;
    this.i18nService = i18nService;
    this.orcidService = orcidService;
  }

	setOrcidPublicationStatus = (div, workStatus) => {
    div.innerHTML = '';
    const statusElement = document.createElement('span');
    statusElement.classList.add('orcid-info');
    statusElement.title = workStatus.isInOrcidProfile
      ? this.i18nService.translate('orcid.publication.inProfile.true')
      : this.i18nService.translate('orcid.publication.inProfile.false');
    statusElement.appendChild(this.createOrcidIcon());
    statusElement.appendChild(this.createThumbsElement(workStatus));
    div.appendChild(statusElement);
	}

  setOrcidPublicationStatuses = async () => {
    document.querySelectorAll('div.orcid-status').forEach(async (e) => {
      const objectId = e.dataset.objectId;
      const orcid = e.dataset.orcid;
      if (objectId && orcid) {
        const workStatus = await this.orcidService.getWorkStatus(orcid, objectId);
        this.setOrcidPublicationStatus(e, workStatus);
      }
    });
  }

	createOrcidPublishButton = async (div, objectId, orcid, workStatus) => {
    div.innerHTML = '';
    const publishButtonElement = document.createElement('button');
    publishButtonElement.classList.add('orcid-button');
    publishButtonElement.innerHTML = this.i18nService.translate('orcid.publication.action.create');
    publishButtonElement.addEventListener('click', async () => {
      await this.orcidService.publishObjectToOrcid(orcid, objectId );
      document.querySelectorAll(`div.orcid-status[data-object-id='${objectId}']`).forEach(async (e) => {
        const workStatus = await this.orcidService.getWorkStatus(orcid, objectId);
        this.setOrcidPublicationStatus(e, workStatus);
      });
      publishButtonElement.disabled = true;
      alert(this.i18nService.translate('orcid.publication.action.confirmation'));
    });
    div.appendChild(publishButtonElement);
	}

  createOrcidPublishButtons = async () => {
    document.querySelectorAll('div.orcid-publish').forEach(async (e) => {
      const objectId = e.dataset.objectId;
      const orcid = e.dataset.orcid;
      if (objectId && orcid) {
        const workStatus = await this.orcidService.getWorkStatus(orcid, objectId);
        if (!workStatus.isInOrcidProfile) {
          this.createOrcidPublishButton(e, objectId, orcid, workStatus);
        }
      }
    });
  }

  createThumbsElement = (workStatus) => {
    const thumbsElement = document.createElement('span');
    thumbsElement.classList.add('far');
    thumbsElement.classList.add(`fa-thumbs-${(workStatus.isInOrcidProfile ? 'up' : 'down')}`);
    thumbsElement.classList.add(`orcid-in-profile-${workStatus.isInOrcidProfile}`);
    return thumbsElement;
  }

  createOrcidIcon = () => {
    const orcidIcon =  document.createElement('img');
    orcidIcon.alt = 'ORCID iD';
    orcidIcon.classList.add('orcid-icon');
    orcidIcon.src = `${this.baseUrl}images/orcid_icon.svg`;
    return orcidIcon;
  }

}

const webApplicationBaseUrl = window['webApplicationBaseURL'];
const lang = window['currentLang'];

document.addEventListener('DOMContentLoaded', async () => {
  const orcidService = new OrcidService(webApplicationBaseUrl);
  const i18nService = new I18nService(webApplicationBaseUrl);
  const orcidUi = new OrcidUi(webApplicationBaseUrl, i18nService, orcidService);
  await i18nService.fetchI18nData('orcid.publication*');
  await orcidService.fetchAccessToken();
  await orcidUi.setOrcidPublicationStatuses();
  await orcidUi.createOrcidPublishButtons();
});
