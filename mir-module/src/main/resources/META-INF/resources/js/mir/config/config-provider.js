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
 * Provides configuration settings for the MIR application.
 */
class MIRConfigProvider {

  /**
   * @private
   * @type {string} The base URL for the application.
   */
  #baseUrl;

  /**
   * @private
   * @type {string} The language setting for the application.
   */
  #lang;

  /**
   * @private
   * @type {Map<string, string>} A map of additional configuration properties.
   */
  #map;

  /**
   * Creates an instance of MIRConfigProvider.
   * 
   * @param {string} baseUrl - The base URL for the application.
   * @param {string} lang - The language setting for the application.
   * @param {Map<string, string>} map - A map of additional configuration properties.
   */
  constructor(baseUrl, lang, map) {
    this.#baseUrl = baseUrl;
    this.#lang = lang;
    this.#map = new Map(map);
  }

  /**
   * Returns the base URL for the application.
   * 
   * @returns {string} The base URL.
   */
  getBaseUrl = () => {
    return this.#baseUrl;
  }

  /**
   * Returns the language setting for the application.
   * 
   * @returns {string} The language setting.
   */
  getLang = () => {
    return this.#lang;
  }

  /**
   * Returns the map of additional configuration properties.
   * 
   * @returns {Map<string, string>} A map of configuration properties.
   */
  getProperties = () => {
    return this.#map;
  }
}

/**
 * An instance of MIRConfigProvider initialized with global settings.
 * 
 * @type {MIRConfigProvider}
 */
const configProvider = new MIRConfigProvider(
  window['webApplicationBaseURL'],
  window['currentLang'],
  new Map(),
);

export { MIRConfigProvider };
export default configProvider;