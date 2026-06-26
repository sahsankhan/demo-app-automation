#!/usr/bin/env node
/**
 * Uploads JUnit XML results to ReportPortal via REST API.
 */
const fs = require("fs");
const path = require("path");

const [junitPath, endpoint, project, token, launchName, launchDescription] =
  process.argv.slice(2);

if (!junitPath || !endpoint || !project || !token) {
  console.error(
    "Usage: node upload-junit-to-reportportal.js <junit.xml> <endpoint> <project> <token> [launchName] [launchDescription]"
  );
  process.exit(1);
}

const xml = fs.readFileSync(junitPath, "utf8");

async function request(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      ...(options.headers || {}),
    },
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`ReportPortal API error ${response.status}: ${body}`);
  }

  return response.json().catch(() => ({}));
}

function extractAttr(tagName, attr, source) {
  const blockMatch = source.match(new RegExp(`<${tagName}[^>]*>`, "i"));
  if (!blockMatch) return "";
  const attrMatch = blockMatch[0].match(new RegExp(`${attr}="([^"]*)"`, "i"));
  return attrMatch ? attrMatch[1] : "";
}

function extract(tag, source) {
  const match = source.match(new RegExp(`<${tag}[^>]*>([\\s\\S]*?)</${tag}>`, "i"));
  return match ? match[1].trim() : "";
}

(async () => {
  const launch = await request(`${endpoint}/${project}/launch`, {
    method: "POST",
    body: JSON.stringify({
      name: launchName || `Maestro Run ${path.basename(junitPath)}`,
      description: launchDescription || "Demo App automation upload",
      startTime: new Date().toISOString(),
      mode: "DEFAULT",
    }),
  });

  const launchUuid = launch.id || launch.uuid;
  console.log(`Created ReportPortal launch: ${launchUuid}`);

  const testcaseRegex = /<testcase[\s\S]*?(?:\/>|<\/testcase>)/gi;
  const testcases = xml.match(testcaseRegex) || [];

  for (const testcase of testcases) {
    const name = extractAttr("testcase", "name", testcase) || "Unnamed test";
    const classname = extractAttr("testcase", "classname", testcase) || "maestro";
    const time = Number(extractAttr("testcase", "time", testcase) || 0);
    const failure = extract("failure", testcase);
    const status = failure ? "FAILED" : "PASSED";

    const item = await request(`${endpoint}/${project}/item`, {
      method: "POST",
      body: JSON.stringify({
        name,
        launchUuid,
        type: "TEST",
        startTime: new Date(Date.now() - Math.round(time * 1000)).toISOString(),
        description: `Suite: ${classname}`,
      }),
    });

    await request(`${endpoint}/${project}/item/${item.id}`, {
      method: "PUT",
      body: JSON.stringify({
        endTime: new Date().toISOString(),
        status,
        ...(failure
          ? {
              issue: {
                issueType: "AB001",
                comment: failure.slice(0, 2000),
              },
            }
          : {}),
      }),
    });
  }

  await request(`${endpoint}/${project}/launch/${launchUuid}/finish`, {
    method: "PUT",
    body: JSON.stringify({
      endTime: new Date().toISOString(),
    }),
  });

  console.log(`Uploaded ${testcases.length} test(s) to ReportPortal`);
})().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
