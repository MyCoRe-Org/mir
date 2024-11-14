export class I18nService {
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