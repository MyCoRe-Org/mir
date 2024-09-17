import {
  OrcidWorkService,
  OrcidUserService,
} from '@jsr/mycore__js-common/orcid';
import { getBaseUrl, getAuthStrategy } from '../common/helpers';

export class OrcidServiceFactory {
  private static workService?: OrcidWorkService;
  private static userService?: OrcidUserService;

  static async getWorkService(): Promise<OrcidWorkService> {
    if (!this.workService) {
      const authStrategy = await getAuthStrategy();
      this.workService = new OrcidWorkService(getBaseUrl(), () => authStrategy);
    }
    return this.workService;
  }

  static async getUserService(): Promise<OrcidUserService> {
    if (!this.userService) {
      const authStrategy = await getAuthStrategy();
      this.userService = new OrcidUserService(getBaseUrl(), () => authStrategy);
    }
    return this.userService;
  }
}
