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

import configProvider, { MIRConfigProvider } from "./config-provider.js";

/**
 * Service class that provides access to the configuration of the application.
 * Extends the EventTarget class to enable event dispatching for configuration changes.
 */
class MIRConfigService extends EventTarget {

  /**
   * @private
   * @type {string} The base URL of the application.
   */
  #baseUrl;

  /**
   * @private
   * @type {string} The current language of the application.
   */
  #lang;

  /**
   * @private
   * @type {Map<string, string>} A map of additional configuration properties.
   */
  #properties;

  /**
   * Creates an instance of MIRConfigService.
   * 
   * @param {MIRConfigProvider} configProvider - The configuration provider to initialize the service.
   */
  constructor (configProvider) {
    super();
    this.#baseUrl = configProvider.getBaseUrl();
    this.#lang = configProvider.getLang();
    this.#properties = configProvider.getProperties();
  }

  /**
   * Gets the base URL.
   *
   * @returns {string} The base URL of the application.
   * @throws {Error} Throws an error if the base URL is not defined.
   */
  getBaseUrl = () => {
    if (!this.#baseUrl) {
      throw new Error('Base URL is not defined');
    }
    return this.#baseUrl;
  }

  /**
   * Gets the current language.
   *
   * @returns {string} The current language of the application.
   * @throws {Error} Throws an error if the language is not defined.
   */
  getLang = () => {
    if (!this.#lang) {
      throw new Error('Language is not defined');
    }
    return this.#lang;
  }

  /**
   * Updates the language setting and dispatches a `langChanged` event.
   * 
   * @param {string} lang - The new language to set.
   * @throws {Error} Throws an error if the language is invalid.
   * @fires MIRConfigService#langChanged
   */
  updateLang = (lang) => {
    if (typeof lang !== 'string' || lang.trim() === '') {
      throw new Error('Invalid language provided');
    }
    this.#lang = lang;
    this.dispatchEvent(new CustomEvent('langChanged', { detail : { lang: lang }  }));
  }

    /**
   * Retrieves a property from the configuration map.
   * 
   * @param {string} key - The key of the property to retrieve.
   * @returns {string} The value of the property.
   * @throws {Error} Throws an error if the property does not exist.
   */
  getProperty = (key) => {
    if (!this.#properties.has(key)) {
      throw new Error(`Property with key: ${key} is missing in the configuration.`);
    }
    return this.#properties.get(key);
  };

  /**
   * Adds or updates a property in the configuration map.
   * 
   * @param {string} value - The value of the property to add or update.
   * @param {string} key - The key of the property to add or update.
   * @throws {Error} Throws an error if the key or value is invalid.
   */
  addProperty = (key, value) => {
    if (key == null || value == null) {
      throw new Error('Both key and value are required to add or update a property.');
    }
    this.#properties.set(key, value);
  }
}

/**
 * @type {MIRConfigService|null} The singleton instance of MIRConfigService.
 * @private
 */
let configServiceInstance = null;

/**
 * Retrieves the singleton instance of the MIRConfigService.
 * If no instance exists, it creates one using the `configProvider`.
 * 
 * @returns {MIRConfigService} The singleton instance of MIRConfigService.
 */
const getConfigService = () => {
  if (!configServiceInstance) {
    configServiceInstance = new MIRConfigService(configProvider);
  }
  return configServiceInstance;
}

export default getConfigService;
export { MIRConfigService }