import { LangApiClient } from '@jsr/mycore__js-common/i18n';
import { MemoryCache } from '@jsr/mycore__js-common/utils/cache';
import { DefaultLangService } from '@jsr/mycore__js-common/i18n';
import { getBaseUrl, getCurrentLang } from './config';

export interface LangService {
  translate(key: string): Promise<string>;
  getTranslations(prefix: string): Promise<Record<string, string>>;
}
export class LangServiceFactory {
  private static langService?: LangService;

  static getLangService(): LangService {
    if (!this.langService) {
      this.langService = new DefaultLangService(
        new LangApiClient(getBaseUrl()),
        getCurrentLang(),
        new MemoryCache()
      );
    }
    return this.langService;
  }
}
