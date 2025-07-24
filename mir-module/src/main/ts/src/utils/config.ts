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
