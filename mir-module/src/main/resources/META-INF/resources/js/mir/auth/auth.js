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

import getConfigService from "../config/config.js";

/**
 * Fetches the JWT token from the server.
 * 
 * @param {string} baseUrl The base URL of the server that provides the JWT token.
 * @returns {Promise<string>} A promise that resolves to the JWT token.
 * @throws {Error} Throws an error if the token cannot be fetched, or the login fails.
 */
const fetchToken = async(baseUrl, params = {}) => {
  try {
    const url = new URL(`${baseUrl}rsc/jwt`);
    const urlParams = new URLSearchParams();
    for (const [key, value] of Object.entries(params)) {
      if (value != null) {
        urlParams.append(key, value);
      }
    }
    url.search = urlParams.toString();
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error('Failed to fetch JWT for current user.');
    }
    const result = await response.json();
    if (!result.login_success) {
      throw new Error('Login failed.');
    }
    return result.access_token;
  } catch (error) {
    console.error('Error fetching the token:', error);
    throw error;
  }
}

/**
 * MIRAuthTokenService is a service that provides the JWT token for authentication.
 * @class
 */
class MIRAuthTokenService {

  /**
   * @private
   * @type {?string} The JWT token for the current user. Initially set to null.
   */
  #token = null;

  /**
   * @private
   * @type {string} The base URL of the server that provides the JWT token.
   */  
  #baseUrl;

  /**
   * Creates an instance of the MIRAuthTokenService.
   * 
   * @param {string} baseUrl The base URL of the server that provides the JWT token.
   * @throws {Error} If no base URL is provided.
   */
  constructor(baseUrl) {
    if (!baseUrl) {
      throw new Error('Base URL is required');
    }
    this.#baseUrl = baseUrl;
  }

  /**
   * Retrieves the token. If the token already exists, it is returned.
   * Otherwise, it fetches the token from the server and stores it.
   * 
   * @returns {Promise<string>} The JWT token for the current user.
   * @throws {Error} If fetching the token from the server fails.
   */
  retrieveToken = async () => {
    if (this.#token) {
      return this.#token;
    }
    this.#token = await fetchToken(this.#baseUrl);
    return this.#token;
  }

  /**
   * Sets the authentication token.
   *
   * @param {string} token - The token to be set.
   * @throws {Error} Throws an error if the token is invalid.
   */
  setToken = (token) => {
    if (typeof token !== 'string' || !token.trim()) {
      throw new Error('Invalid token: Must be a non-empty string.');
    }
    this.#token = token;
  }
}

/**
 * @type {MIRAuthTokenService|null} The singleton instance of MIRAuthTokenService.
 * @private
 */
let authTokenServiceInstance = null;

/**
 * Retrieves the default instance of the MIRAuthTokenService.
 * If the instance does not exist, it will be created using the base URL from the config service.
 * 
 * @returns {MIRAuthTokenService} The singleton instance of the MIRAuthTokenService.
 */
const getDefaultAuthTokenService = () => {
  if (!authTokenServiceInstance) {
    authTokenServiceInstance = new MIRAuthTokenService(getConfigService().getBaseUrl());
  }
  return authTokenServiceInstance;
}

export default getDefaultAuthTokenService;
export { fetchToken, MIRAuthTokenService };