export class OrcidService {
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

export class OrcidSettingsService {
  constructor(baseUrl, bearerAccessToken) {
    this.baseUrl = baseUrl;
    this.accessToken = bearerAccessToken;
  }

  fetchSettings = async (orcid) => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/user-properties/${orcid}`, {
      headers: { Authorization: `Bearer ${this.accessToken}`},
    });
    if (!response.ok) {
      throw new Error(`Failed to fetch ORCID user settings for ${orcid}.`);
    }
    return await response.json();
  }

  updateSettings = async (orcid, settings) => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/user-properties/${orcid}`, {
      method: 'PUT',
      headers: {
        Authorization: `Bearer ${this.accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(settings),
    });
    if (!response.ok) {
      throw new Error(`Failed to update ORCID user settings for ${orcid}.`);
    }
  }
}