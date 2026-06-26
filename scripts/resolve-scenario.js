#!/usr/bin/env node
/**
 * Resolves a full test scenario by userId from shared JSON data files.
 * Used by data-driven-runner.sh to inject Maestro env vars.
 */
const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const userId = process.argv[2];

if (!userId) {
  console.error("Usage: node resolve-scenario.js <userId>");
  process.exit(1);
}

function readJson(relativePath) {
  return JSON.parse(fs.readFileSync(path.join(root, relativePath), "utf8"));
}

const users = readJson("data/users/onboarding-users.json").users;
const kyc = readJson("data/kyc/kyc-scenarios.json").scenarios;
const payments = readJson("data/payments/payment-scenarios.json");

const user = users.find((u) => u.id === userId);
const kycScenario = kyc.find((s) => s.userId === userId);
const account = payments.accounts.find((a) => a.userId === userId);
const payment = payments.payments.find((p) => p.userId === userId);

if (!user || !kycScenario || !account || !payment) {
  console.error(`No complete scenario found for userId: ${userId}`);
  process.exit(1);
}

const countryLabels = {
  US: "United States",
  UK: "United Kingdom",
  CA: "Canada",
};

const documentLabels = {
  passport: "Passport",
  drivers_license: "Driver's License",
  national_id: "National ID",
};

const accountTypeLabels = {
  checking: "Checking",
  savings: "Savings",
  premium: "Premium Checking",
};

const scenario = {
  USER_ID: user.id,
  XRAY_E2E_KEY: "BANK-500",
  FIRST_NAME: user.firstName,
  LAST_NAME: user.lastName,
  EMAIL: user.email,
  PHONE: user.phone,
  PASSWORD: user.password,
  DATE_OF_BIRTH: kycScenario.dateOfBirth,
  NATIONAL_ID: kycScenario.nationalId,
  ADDRESS: kycScenario.address,
  CITY: kycScenario.city,
  COUNTRY: kycScenario.country,
  COUNTRY_LABEL: countryLabels[kycScenario.country],
  DOCUMENT_TYPE: kycScenario.documentType,
  DOCUMENT_LABEL: documentLabels[kycScenario.documentType],
  ACCOUNT_TYPE: account.accountType,
  ACCOUNT_TYPE_LABEL: accountTypeLabels[account.accountType],
  CURRENCY: account.currency,
  INITIAL_DEPOSIT: account.initialDeposit,
  BENEFICIARY: payment.beneficiary,
  BENEFICIARY_ACCOUNT: payment.beneficiaryAccount,
  PAYMENT_AMOUNT: payment.amount,
  PAYMENT_REFERENCE: payment.reference,
};

Object.entries(scenario).forEach(([key, value]) => {
  console.log(`${key}=${value}`);
});
