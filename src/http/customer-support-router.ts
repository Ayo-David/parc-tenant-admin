import { Router, type Request } from "express";
import { z } from "zod";
import type { CustomerSupportService } from "../services/customer-support-service.js";
import { ApiError } from "./api-error.js";
import {
  requireServiceAccess,
  tenantAdminAccessPolicies,
} from "./service-access.js";

const identifiers = z.object({ customerId: z.string().uuid() });
const ticket = z.object({
  category_id: z.string().uuid().optional(),
  subject: z.string().trim().min(1).max(255),
  description: z.string().trim().min(1).max(10_000),
});

export function createCustomerSupportRouter(input: {
  service: CustomerSupportService;
  allowedServices: ReadonlySet<string>;
}): Router {
  const router = Router();
  router.use(
    "/internal/v1/customers/:customerId/support",
    (request, _response, next) => {
      try {
        authenticate(request, input);
        next();
      } catch (error) {
        next(error);
      }
    },
  );
  router.get(
    "/internal/v1/customers/:customerId/support/faqs",
    async (request, response, next) => {
      try {
        const tenantId = tenant(request);
        identifiers.parse(request.params);
        response.json({ items: await input.service.listFaqs(tenantId) });
      } catch (error) {
        next(error instanceof z.ZodError ? invalid() : error);
      }
    },
  );
  router.get(
    "/internal/v1/customers/:customerId/support/tickets",
    async (request, response, next) => {
      try {
        const tenantId = tenant(request);
        const parsed = identifiers.parse(request.params);
        response.json({
          items: await input.service.listTickets(tenantId, parsed.customerId),
        });
      } catch (error) {
        next(error instanceof z.ZodError ? invalid() : error);
      }
    },
  );
  router.post(
    "/internal/v1/customers/:customerId/support/tickets",
    async (request, response, next) => {
      try {
        const tenantId = tenant(request);
        const parsed = identifiers.parse(request.params);
        const body = ticket.parse(request.body);
        const idempotencyKey = z
          .string()
          .min(1)
          .max(255)
          .parse(request.header("idempotency-key"));
        response.status(201).json(
          await input.service.createTicket({
            tenantId,
            customerId: parsed.customerId,
            subject: body.subject,
            description: body.description,
            idempotencyKey,
            ...(body.category_id ? { categoryId: body.category_id } : {}),
          }),
        );
      } catch (error) {
        next(error instanceof z.ZodError ? invalid() : error);
      }
    },
  );
  return router;
}

function tenant(request: Request): string {
  return z.string().uuid().parse(request.header("x-tenant-id"));
}
function invalid(): ApiError {
  return new ApiError(422, "INVALID_REQUEST", "Request is invalid");
}
/** Customer delegation only, for that customer's own support data. */
function authenticate(
  request: Request,
  input: { allowedServices: ReadonlySet<string> },
): void {
  const principal = requireServiceAccess(
    request,
    request.method === "GET"
      ? tenantAdminAccessPolicies.customerSupportRead
      : tenantAdminAccessPolicies.customerSupportWrite,
    input.allowedServices,
  );
  if (principal.subject?.id !== request.params.customerId)
    throw new ApiError(403, "SUBJECT_MISMATCH", "Customer mismatch");
}
