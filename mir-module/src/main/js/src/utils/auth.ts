import { fetchJwt, AuthStrategy } from '@jsr/mycore__js-common/auth';
import { getBaseUrl } from './config';

export class JwtAuthStrategy implements AuthStrategy {
  private currentToken?: string;

  async getHeaders(): Promise<Record<string, string>> {
    if (!this.currentToken) {
      this.currentToken = await fetchJwt(getBaseUrl());
    }
    return {
      Authorization: `Bearer ${this.currentToken}`,
    };
  }
}

let instance: JwtAuthStrategy;

export function getAuthStrategy(): JwtAuthStrategy {
  if (!instance) {
    instance = new JwtAuthStrategy();
  }
  return instance;
}
