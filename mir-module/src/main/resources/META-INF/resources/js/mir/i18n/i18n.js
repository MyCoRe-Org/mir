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
 * Service for handling language properties and cache for I18n data.
 */
class MIRLangService {

  /**
   * @private
   * @type {string} The base URL for the API.
   */
  #baseUrl

  /**
   * @private
   * @type {string} The language code (e.g., 'en', 'de').
   */
  #lang

  /**
   * @private
   * @type {Map<string, string>} A cache of fetched properties with their corresponding keys and values.
   */
  #cache = new Map();

  /**
   * Creates an instance of MIRLangService.
   *
   * @param {string} baseUrl - The base URL for the API.
   * @param {string} lang - The language code (e.g., 'en', 'de').
   */
  constructor(baseUrl, lang) {
    this.#baseUrl = baseUrl;
    this.#lang = lang;
  }

  /**
   * Fetches properties for a given prefix and stores them in the cache.
   * The properties are retrieved from the server and then stored in the internal cache.
   * 
   * @param {string} prefix - The prefix for the properties to fetch.
   * @returns {Promise<void>} A promise that resolves when the properties have been fetched and cached.
   * @throws {Error} Throws an error if fetching properties from the server fails.
   */
  fetchProperties = async (prefix) => {
    try {
      const data = await this.#doFetchProperties(prefix);
      Object.entries(data).forEach(([key, value]) => this.#cache.set(key, value));
    } catch (error) {
      console.error(`Error while fetching prefix ${prefix}: ${error.message}`);
      throw new Error(`Failed to fetch properties for prefix ${prefix}.`);
    }
  }

  /**
   * Retrieves a property from the cache or fetches it if it is not available.
   * If the property is not cached, it will be fetched from the server and cached for future use.
   * 
   * @param {string} key - The key of the property to retrieve.
   * @returns {Promise<string>} A promise that resolves to the property value.
   * If the property is not found, a placeholder string ('??<key>??') will be returned.
   * @throws {Error} Throws an error if fetching the property from the server fails.
   */
  getProperty = async (key) => {
    if (this.#cache.has(key)) {
      return this.#cache.get(key);
    }
    try {
      const data = await this.#doFetchProperties(key);
      if (data[key]) {
        this.#cache.set(key, data[key])
        return data[key];
      } else {
        return `??${key}??`;
      }
    } catch (error) {
      console.error(`Error while fetching key ${key}: ${error.message}`);
      return `??${key}??`;
    }
  }

  /**
   * Fetches language properties for a given prefix from the server.
   * 
   * @private
   * @param {string} prefix - The prefix for the properties to fetch.
   * @returns {Promise<Object>} A promise that resolves to an object containing the fetched properties.
   * @throws {Error} Throws an error if the server request fails or the response is invalid.
   */
  #doFetchProperties = async(prefix) => {
    try {
      const response = await fetch(`${this.#baseUrl}rsc/locale/translate/${this.#lang}/${prefix}`);
      if (!response.ok) {
        throw new Error(`Failed to fetch properties from ${prefix}. Status: ${response.status}`);
      }
      return await response.json();
    } catch (error) {
      console.error(`Error during fetching from API: ${error.message}`);
      throw new Error('Error fetching language properties.');
    }
  }
}

/**
 * A map holding language service instances, keyed by language code.
 * 
 * This map ensures that only one instance of the language service is created for each language.
 * 
 * @private
 * @type {Map<string, MIRLangService>}
 */
const langServiceInstanceMap = new Map();

/**
 * Retrieves the default language service instance for the current language.
 * If an instance for the current language does not exist, it creates one using the configuration service.
 * 
 * @returns {MIRLangService} The language service instance for the current language.
 */
const getDefaultLangService = () => {
  const configurationService = getConfigService();
  const currentLang = configurationService.getLang();
  if (!langServiceInstanceMap.has(currentLang)) {
    const langService = new MIRLangService(configurationService.getBaseUrl(), configurationService.getLang());
    langServiceInstanceMap.set(currentLang, langService);
  }
  return langServiceInstanceMap.get(currentLang);
}

export default getDefaultLangService;
export { MIRLangService };