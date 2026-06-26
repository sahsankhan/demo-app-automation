/**
 * Mock Banking REST API — backs Karate API tests and cross-system flows.
 * Endpoints: onboarding → KYC → account → payment (with business validations).
 */
const http = require("http");
const { URL } = require("url");

const PORT = process.env.API_PORT || 4000;
const store = { customers: {}, accounts: {}, payments: [] };

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", (chunk) => (data += chunk));
    req.on("end", () => {
      try {
        resolve(data ? JSON.parse(data) : {});
      } catch (error) {
        reject(error);
      }
    });
    req.on("error", reject);
  });
}

function send(res, status, body) {
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(JSON.stringify(body));
}

function generateId(prefix) {
  return `${prefix}-${Math.random().toString(36).slice(2, 10).toUpperCase()}`;
}

function getCustomer(customerId) {
  return store.customers[customerId] || null;
}

function getAccount(accountId) {
  return store.accounts[accountId] || null;
}

const routes = {
  "GET /api/v1/health": (_req, res) => send(res, 200, { status: "UP", service: "demo-app-api" }),

  "POST /api/v1/test/reset": (_req, res) => {
    store.customers = {};
    store.accounts = {};
    store.payments = [];
    send(res, 200, { status: "RESET", message: "Test data cleared" });
  },

  "POST /api/v1/onboarding/register": async (req, res, body) => {
    const required = ["firstName", "lastName", "email", "phone", "password"];
    const missing = required.filter((field) => !body[field]);
    if (missing.length) {
      return send(res, 400, { error: "VALIDATION_ERROR", message: `Missing fields: ${missing.join(", ")}` });
    }

    const duplicate = Object.values(store.customers).find((c) => c.email === body.email);
    if (duplicate) {
      return send(res, 409, { error: "DUPLICATE_EMAIL", message: "Email already registered" });
    }

    const customerId = generateId("CUS");
    store.customers[customerId] = {
      customerId,
      firstName: body.firstName,
      lastName: body.lastName,
      email: body.email,
      phone: body.phone,
      status: "REGISTERED",
      kycStatus: "PENDING",
    };

    send(res, 201, {
      customerId,
      status: "REGISTERED",
      email: body.email,
      message: "Registration successful",
    });
  },

  "POST /api/v1/kyc/verify": (req, res, body) => {
    const customer = getCustomer(body.customerId);
    if (!customer) {
      return send(res, 404, { error: "CUSTOMER_NOT_FOUND", message: "Customer not found" });
    }

    const required = ["dateOfBirth", "nationalId", "address", "city", "country", "documentType"];
    const missing = required.filter((field) => !body[field]);
    if (missing.length) {
      return send(res, 400, { error: "VALIDATION_ERROR", message: `Missing fields: ${missing.join(", ")}` });
    }

    if (body.nationalId.length !== 4) {
      return send(res, 422, { error: "INVALID_NATIONAL_ID", message: "National ID must be last 4 digits" });
    }

    customer.kycStatus = "VERIFIED";
    customer.kyc = {
      dateOfBirth: body.dateOfBirth,
      nationalId: body.nationalId,
      address: body.address,
      city: body.city,
      country: body.country,
      documentType: body.documentType,
    };

    send(res, 200, {
      customerId: customer.customerId,
      kycStatus: "VERIFIED",
      message: "KYC verified",
    });
  },

  "POST /api/v1/accounts": (req, res, body) => {
    const customer = getCustomer(body.customerId);
    if (!customer) {
      return send(res, 404, { error: "CUSTOMER_NOT_FOUND", message: "Customer not found" });
    }
    if (customer.kycStatus !== "VERIFIED") {
      return send(res, 403, { error: "KYC_REQUIRED", message: "Complete KYC before opening account" });
    }

    const required = ["accountType", "currency", "initialDeposit"];
    const missing = required.filter((field) => body[field] === undefined || body[field] === "");
    if (missing.length) {
      return send(res, 400, { error: "VALIDATION_ERROR", message: `Missing fields: ${missing.join(", ")}` });
    }

    const initialDeposit = Number(body.initialDeposit);
    if (Number.isNaN(initialDeposit) || initialDeposit < 0) {
      return send(res, 422, { error: "INVALID_DEPOSIT", message: "Initial deposit must be a positive number" });
    }

    const accountId = generateId("ACC");
    const accountNumber = generateId("ACC");
    store.accounts[accountId] = {
      accountId,
      accountNumber,
      customerId: customer.customerId,
      accountType: body.accountType,
      currency: body.currency,
      balance: initialDeposit,
    };

    send(res, 201, {
      accountId,
      accountNumber,
      balance: initialDeposit,
      currency: body.currency,
      status: "OPEN",
      message: "Account opened",
    });
  },

  "POST /api/v1/payments": (req, res, body) => {
    const account = getAccount(body.accountId);
    if (!account) {
      return send(res, 404, { error: "ACCOUNT_NOT_FOUND", message: "Account not found" });
    }

    const required = ["beneficiary", "beneficiaryAccount", "amount", "reference"];
    const missing = required.filter((field) => !body[field]);
    if (missing.length) {
      return send(res, 400, { error: "VALIDATION_ERROR", message: `Missing fields: ${missing.join(", ")}` });
    }

    const amount = Number(body.amount);
    if (Number.isNaN(amount) || amount <= 0) {
      return send(res, 422, { error: "INVALID_AMOUNT", message: "Payment amount must be greater than zero" });
    }
    if (account.balance < amount) {
      return send(res, 422, { error: "INSUFFICIENT_FUNDS", message: "Insufficient funds" });
    }

    account.balance -= amount;
    const transactionId = generateId("TXN");
    const payment = {
      transactionId,
      accountId: account.accountId,
      beneficiary: body.beneficiary,
      beneficiaryAccount: body.beneficiaryAccount,
      amount,
      reference: body.reference,
      status: "SUCCESS",
      newBalance: account.balance,
    };
    store.payments.push(payment);

    send(res, 200, {
      transactionId,
      status: "SUCCESS",
      newBalance: account.balance,
      currency: account.currency,
      message: "Payment successful",
    });
  },

  "GET /api/v1/accounts/:accountId/balance": (req, res, _body, params) => {
    const account = getAccount(params.accountId);
    if (!account) {
      return send(res, 404, { error: "ACCOUNT_NOT_FOUND", message: "Account not found" });
    }

    send(res, 200, {
      accountId: account.accountId,
      balance: account.balance,
      currency: account.currency,
    });
  },
};

function matchRoute(method, pathname) {
  const key = `${method} ${pathname}`;
  if (routes[key]) return { handler: routes[key], params: {} };

  for (const routeKey of Object.keys(routes)) {
    const [routeMethod, routePath] = routeKey.split(" ");
    if (routeMethod !== method) continue;

    const routeParts = routePath.split("/");
    const pathParts = pathname.split("/");
    if (routeParts.length !== pathParts.length) continue;

    const params = {};
    let matched = true;
    for (let i = 0; i < routeParts.length; i += 1) {
      if (routeParts[i].startsWith(":")) {
        params[routeParts[i].slice(1)] = pathParts[i];
      } else if (routeParts[i] !== pathParts[i]) {
        matched = false;
        break;
      }
    }

    if (matched) return { handler: routes[routeKey], params };
  }

  return null;
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const match = matchRoute(req.method, url.pathname);

  if (!match) {
    return send(res, 404, { error: "NOT_FOUND", message: "Route not found" });
  }

  try {
    const body = req.method === "GET" ? {} : await readBody(req);
    await match.handler(req, res, body, match.params);
  } catch (error) {
    send(res, 500, { error: "INTERNAL_ERROR", message: error.message });
  }
});

server.listen(PORT, () => {
  console.log(`Demo App API listening on http://localhost:${PORT}`);
});
