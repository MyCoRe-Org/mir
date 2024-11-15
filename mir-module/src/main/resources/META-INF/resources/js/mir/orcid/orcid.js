/*!
 * This file is part of ***  M y C o R e  ***
 * See https://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Service for interacting with the ORCID API to manage works and user statuses.
 */
class MIROrcidWorkService {

  /**
   * @private
   * @type {string} The base URL.
   */
  #baseUrl;

  /**
   * @private
   * @type {string} The access token for authenticating API requests.
   */
  #accessToken;

  /**
   * Creates an instance of the MIROrcidWorkService.
   * 
   * @param {string} baseUrl The base URL.
   * @param {string} accessToken The access token used for authenticating.
   */
  constructor(baseUrl, accessToken) {
    this.baseUrl = baseUrl;
    this.accessToken = accessToken;
  }

  /**
   * Fetches the status of a work for a specific user.
   * 
   * This method retrieves the current status of a work identified by its `objectId` for a given ORCID ID. 
   * The request can either be made using the public ORCID API or the member API (if `useMember` is true).
   * 
   * @param {string} orcid The ORCiD ID of the user for whom the work status is being fetched.
   * @param {string} objectId The ID of the work whose status is to be fetched.
   * @param {boolean} [useMember=false] Whether to use the member API (`true`) or the public API (`false`).
   * @returns {Promise<Object>} A promise that resolves with the status data of the work.
   * @throws {Error} Throws an error if the request fails, or if the status cannot be fetched.
   */
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

  /**
   * Exports a work to an ORCID profile.
   * 
   * This method allows exporting a work (identified by its `objectId`) to the ORCID profile 
   * of a user (identified by their `orcid`).
   * 
   * @param {string} orcid The ORCiD ID of the user to whom the work is being exported.
   * @param {string} objectId The ID of the work to be exported to the user's ORCID profile.
   * @returns {Promise<void>} A promise that resolves when the work has been successfully published.
   * @throws {Error} Throws an error if the export operation fails.
   */
  exportObjectToOrcid = async (orcid, objectId) => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/member/${orcid}/works/object/${objectId}`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${this.accessToken}`},
    });
    if (!response.ok) {
      throw new Error(`Failed to export ${objectId} to ${orcid}.`);
    }
  }
}

/**
 * Service to manage ORCID user settings.
 */
class MIROrcidUserService {

  /**
   * @private
   * @type {string} The base URL.
   */
  #baseUrl;

  /**
   * @private
   * @type {string} The bearer access token for authenticating API requests.
   */
  #accessToken;

  /**
   * Creates an instance of the MIROrcidUserService.
   * 
   * @param {string} baseUrl The base URL.
   * @param {string} bearerAccessToken The bearer access token for authenticating.
   */
  constructor(baseUrl, bearerAccessToken) {
    this.baseUrl = baseUrl;
    this.accessToken = bearerAccessToken;
  }

  /**
   * Fetches the current user's ORCID status.
   * 
   * This method retrieves the current status of the authenticated user by making a 
   * request to the ORCID API. The status data typically includes whether the user is 
   * logged in and other related information.
   * 
   * @returns {Promise<Object>} A promise that resolves with the user status data.
   * @throws {Error} Throws an error if the request fails or the status cannot be fetched.
   */
  fetchCurrentUserOrcidStatus = async () => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/user-status`, {
      headers: { Authorization: `Bearer ${this.accessToken}`}
    });
    if (!response.ok) {
      throw new Error('Failed to fetch Orcid user status');
    }
    return await response.json();
  }

  /**
   * Fetches the ORCID user settings for a specific ORCiD ID.
   * 
   * This method retrieves the settings associated with a specific ORCID ID. These settings 
   * include user-defined preferences or configurations stored in the ORCID profile.
   * 
   * @param {string} orcid The ORCiD ID of the user whose settings are to be fetched.
   * @returns {Promise<Object>} A promise that resolves with the user settings data.
   * @throws {Error} Throws an error if the request fails or the settings cannot be fetched.
   */
  fetchCurrentUserOrcidSettings = async (orcid) => {
    const response = await fetch(`${this.baseUrl}api/orcid/v1/user-properties/${orcid}`, {
      headers: { Authorization: `Bearer ${this.accessToken}`},
    });
    if (!response.ok) {
      throw new Error(`Failed to fetch ORCID user settings for ${orcid}.`);
    }
    return await response.json();
  }

  /**
   * Updates the ORCID settings for a specific user.
   * 
   * This method allows updating the user settings in the ORCID profile for a given ORCiD ID.
   * 
   * @param {string} orcid The ORCiD ID of the user whose settings are to be updated.
   * @param {Object} settings The new ORCID settings to be applied to the user's profile.
   * @returns {Promise<void>} A promise that resolves when the settings have been successfully updated.
   * @throws {Error} Throws an error if the request fails or the settings cannot be updated.
   */
  updateCurrentUserOrcidSettings = async (orcid, settings) => {
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

export { MIROrcidWorkService, MIROrcidUserService };