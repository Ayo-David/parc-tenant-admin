import { ApiError } from "../http/api-error.js";

export interface PlatformPrincipal {
  administratorId: string;
}

export interface AdministratorPrincipal extends PlatformPrincipal {
  tenantId: string | null;
  scope: "TENANT" | "PLATFORM";
}

export interface PlatformAuthorizer {
  authorize(
    accessToken: string,
    permission: string,
  ): Promise<PlatformPrincipal>;
}

export interface AdministratorAuthorizer extends PlatformAuthorizer {
  authorizeAdministrator(
    accessToken: string,
    permission: string,
  ): Promise<AdministratorPrincipal>;
}

export class UnconfiguredPlatformAuthorizer implements PlatformAuthorizer {
  public authorize(): Promise<never> {
    return Promise.reject(
      new ApiError(
        503,
        "ADMIN_AUTHORIZATION_UNAVAILABLE",
        "Administrator authorization is unavailable",
      ),
    );
  }
}

export class UnconfiguredAdministratorAuthorizer
  extends UnconfiguredPlatformAuthorizer
  implements AdministratorAuthorizer
{
  public authorizeAdministrator(): Promise<never> {
    return this.authorize();
  }
}
