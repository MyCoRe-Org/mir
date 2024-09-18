const fetchAccessToken = async (webApplicationBaseUrl) => {
  const response = await fetch(`${webApplicationBaseUrl}rsc/jwt`);
  if (!response.ok) {
    throw new Error(`Cannot fetch JWT: ${response.status}`);
  }
  const result = await response.json();
  if (!result.login_success) {
    throw new Error("Login failed");
  }
  return result.access_token;
}
const getUserStatus = async (webApplicationBaseUrl, accessToken) => {
  const response = await fetch(`${webApplicationBaseUrl}api/orcid/v1/user-status`, {
    headers: { Authorization: `Bearer ${accessToken}`}
  });
  if (!response.ok) {
    throw new Error("Cannot get current user's status");
  }
  return await response.json();
}
const getObjectStatus = async (webApplicationBaseUrl, accessToken, objectId) => {
  const response = await fetch(`${webApplicationBaseUrl}api/orcid/v1/object-status/v3/${objectId}`, {
    headers: { Authorization: `Bearer ${accessToken}`}
  });
  if (!response.ok) {
    throw new Error(`Cannot get object status for ${objectId}`);
  }
  return await response.json();
}
const fetchI18nData = async (webApplicationBaseUrl, lang, keyPrefix) => {
  const response = await fetch(`${webApplicationBaseUrl}rsc/locale/translate/${lang}/${keyPrefix}`);
  if (!response.ok) {
    throw new Error("Error while fetching i18n");
  }
  return await response.json();
}
const publishObjectToOrcid = async (webApplicationBaseUrl, accessToken, objectId) => {
  const response = await fetch(`${webApplicationBaseURL}api/orcid/v1/create-work/v3/${objectId}`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${accessToken}`}
  });
  if (!response.ok) {
    throw new Error(`Error while publishing ${objectId} to ORCID profile`);
  }
}
const createOrcidIcon = (webApplicationBaseUrl) => {
	const orcidIcon =  document.createElement('img');
  orcidIcon.alt = 'ORCID iD';
  orcidIcon.classList.add('orcid-icon');
  orcidIcon.src = `${webApplicationBaseURL}images/orcid_icon.svg`;
  return orcidIcon;
}

const webApplicationBaseUrl = window["webApplicationBaseURL"];
const lang = window["currentLang"];

(() => {
  let accessToken = null;
  let i18nData = null;

  const getAccessToken = async () => {
    if (!accessToken) {
      accessToken = await fetchAccessToken(webApplicationBaseUrl);
    }
    return accessToken;
  }

  const getI18n = async (property) => {
    if (!i18nData) {
      i18nData = await fetchI18nData(webApplicationBaseUrl, lang, 'orcid.publication*');
    }
    if (property in i18nData) {
      return i18nData[property];
    }
    return property;
  }

	const setOrcidPublicationStatus = async (div, isInOrcidProfile) => {
    div.innerHTML = '';
    const statusElement = document.createElement('span');
    statusElement.classList.add('orcid-info');
    statusElement.title = isInOrcidProfile ? await getI18n('orcid.publication.inProfile.true') : await getI18n('orcid.publication.inProfile.false');
    statusElement.appendChild(createOrcidIcon(webApplicationBaseUrl));
    thumbsElement = document.createElement('span');
    thumbsElement.classList.add('far');
    thumbsElement.classList.add(`fa-thumbs-${(isInOrcidProfile ? 'up' : 'down')}`);
    thumbsElement.classList.add(`orcid-in-profile-${isInOrcidProfile}`);
    statusElement.appendChild(thumbsElement);
    div.appendChild(statusElement);
	}

	const createOrcidPublishButton = async (div, objectId, isInOrcidProfile) => {
    div.innerHTML = '';
    const publishButtonElement = document.createElement('button');
    publishButtonElement.classList.add('orcid-button');
    // update work is not supported
    publishButtonElement.disabled = isInOrcidProfile;
    publishButtonElement.innerHTML = await getI18n('orcid.publication.action.create');
    if (!isInOrcidProfile) {
      publishButtonElement.addEventListener('click', async () => {
        const accessToken = await getAccessToken();
        await publishObjectToOrcid(webApplicationBaseUrl, accessToken, objectId);
        document.querySelectorAll(`div.orcid-status[data-id="${objectId}"]`).forEach((e) => {
          setOrcidPublicationStatus(e, true);
        });
        publishButtonElement.disabled = true;
        alert(await getI18n('orcid.publication.action.confirmation'));
      });
    }
    div.appendChild(publishButtonElement);
	}

  const setOrcidPublicationStatuses = () => {
    document.querySelectorAll('div.orcid-status').forEach(async (e) => {
      const objectId = e.dataset.id;
      if (objectId) {
        const accessToken = await getAccessToken();
        const objectStatus = await getObjectStatus(webApplicationBaseUrl, accessToken, objectId);
        if (objectStatus.usersPublication) {
          setOrcidPublicationStatus(e, objectStatus.inORCIDProfile);
        }
      }
    });
  }

  const createOrcidPublishButtons = () => {
    document.querySelectorAll('div.orcid-publish').forEach(async (e) => {
      const objectId = e.dataset.id;
      if (objectId) {
        const accessToken = await getAccessToken();
        const objectStatus = await getObjectStatus(webApplicationBaseUrl, accessToken, objectId);
        if (objectStatus.usersPublication) {
          createOrcidPublishButton(e, objectId, objectStatus.inORCIDProfile);
        }
      }
    });
  }

	const init = async() => {
    const userStatus = await getUserStatus(webApplicationBaseUrl, await getAccessToken());
    if (userStatus.orcids.length !== 0) {
      setOrcidPublicationStatuses();
      // TODO check if trustedOrcid is relevant orcid
      createOrcidPublishButtons();
    }
	}

  if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', init);
  } else {
      init();
  }

})();
