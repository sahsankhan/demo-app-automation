#!/usr/bin/env node
/**
 * Imports JUnit results into Xray Cloud test execution for Jira traceability.
 * Test cases must include Xray keys in flow comments, e.g. # @BANK-500 ...
 */
const fs = require("fs");

const [junitPath, jiraBaseUrl, clientId, clientSecret, testExecutionKey] =
  process.argv.slice(2);

if (!junitPath || !jiraBaseUrl || !clientId || !clientSecret || !testExecutionKey) {
  console.error(
    "Usage: node xray-import-junit.js <junit.xml> <jiraBaseUrl> <clientId> <clientSecret> <testExecutionKey>"
  );
  process.exit(1);
}

const xml = fs.readFileSync(junitPath, "utf8");

async function getXrayToken() {
  const response = await fetch("https://xray.cloud.getxray.app/api/v2/authenticate", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ client_id: clientId, client_secret: clientSecret }),
  });

  if (!response.ok) {
    throw new Error(`Xray auth failed: ${response.status} ${await response.text()}`);
  }

  return response.text();
}

(async () => {
  const token = await getXrayToken();
  const authHeader = token.startsWith('"') ? JSON.parse(token) : token;

  const response = await fetch(
    `https://xray.cloud.getxray.app/api/v2/import/execution/junit?testExecKey=${encodeURIComponent(testExecutionKey)}`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${authHeader}`,
        "Content-Type": "application/xml",
      },
      body: xml,
    }
  );

  if (!response.ok) {
    throw new Error(`Xray import failed: ${response.status} ${await response.text()}`);
  }

  const result = await response.json().catch(() => ({}));
  console.log(`Imported ${junitPath} into ${testExecutionKey}`);
  if (result.testExecIssue?.key) {
    console.log(`Execution: ${result.testExecIssue.key}`);
  }
})().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
