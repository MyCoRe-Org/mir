import {
  OrcidWorkApiClient,
  OrcidUserApiClient,
} from '@jsr/mycore__js-common/orcid';
import { AuthStrategyFactory } from '../utils/auth';
import { getBaseUrl } from '../utils/config';

export class OrcidApiClientFactory {
  private static workService?: OrcidWorkApiClient;
  private static userService?: OrcidUserApiClient;

  static getWorkService(): OrcidWorkApiClient {
    if (!this.workService) {
      this.workService = new OrcidWorkApiClient(
        getBaseUrl(),
        AuthStrategyFactory.getAuthStrategy()
      );
    }
    return this.workService;
  }

  static getUserService(): OrcidUserApiClient {
    if (!this.userService) {
      this.userService = new OrcidUserApiClient(
        getBaseUrl(),
        AuthStrategyFactory.getAuthStrategy()
      );
    }
    return this.userService;
  }
}
