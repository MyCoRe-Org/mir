import {
  fetchJwt,
  AccessTokenAuthStrategy,
  AuthStrategy,
} from '@jsr/mycore__js-common/auth';
import { LangService } from '@jsr/mycore__js-common/i18n';

interface CustomWindow extends Window {
  webApplicationBaseURL: string;
  currentLang: string;
}

declare const window: CustomWindow;

export const getBaseUrl = (): URL => {
  if (!window.webApplicationBaseURL) {
    throw new Error('webApplicationBaseURL is not defined on window.');
  }
  return new URL(window.webApplicationBaseURL);
};

export const getCurrentLang = (): string => {
  if (!window.currentLang) {
    throw new Error('currentLang is not defined on window.');
  }
  return window.currentLang;
};

let authStrategy: AuthStrategy;
let authStrategyPromise: Promise<AuthStrategy>;

export const getAuthStrategy = (): Promise<AuthStrategy> => {
  if (authStrategy) {
    return Promise.resolve(authStrategy);
  }
  if (!authStrategyPromise) {
    const baseUrl = getBaseUrl().toString();
    authStrategyPromise = fetchJwt(baseUrl).then(accessToken => {
      authStrategy = new AccessTokenAuthStrategy(accessToken);
      return authStrategy;
    });
  }
  return authStrategyPromise;
};

let langService: LangService | undefined;
export const getLangService = (): LangService => {
  if (!langService) {
    langService = new LangService(getBaseUrl());
  }
  return langService;
};
