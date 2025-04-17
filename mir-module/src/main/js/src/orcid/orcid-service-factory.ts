import {
  OrcidWorkService,
  OrcidUserService,
} from '@jsr/mycore__js-common/orcid';
import { getBaseUrl } from '../utils/config';
import { getAuthStrategy } from '../utils/auth';

export class OrcidServiceFactory {
  private static workService?: OrcidWorkService;
  private static userService?: OrcidUserService;

  static async getWorkService(): Promise<OrcidWorkService> {
    if (!this.workService) {
      this.workService = new OrcidWorkService(getBaseUrl(), getAuthStrategy());
    }
    return this.workService;
  }

  static async getUserService(): Promise<OrcidUserService> {
    if (!this.userService) {
      this.userService = new OrcidUserService(getBaseUrl(), getAuthStrategy());
    }
    return this.userService;
  }
}
