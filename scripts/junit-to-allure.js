#!/usr/bin/env node
/**
 * Converts Maestro JUnit XML output into Allure result JSON files.
 */
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

const [junitPath, outputDir] = process.argv.slice(2);

if (!junitPath || !outputDir) {
  console.error("Usage: node junit-to-allure.js <junit.xml> <allure-results-dir>");
  process.exit(1);
}

fs.mkdirSync(outputDir, { recursive: true });

const xml = fs.readFileSync(junitPath, "utf8");

function extract(tag, source) {
  const match = source.match(new RegExp(`<${tag}[^>]*>([\\s\\S]*?)</${tag}>`, "i"));
  return match ? match[1].trim() : "";
}

function extractAttr(tagName, attr, source) {
  const blockMatch = source.match(new RegExp(`<${tagName}[^>]*>`, "i"));
  if (!blockMatch) return "";
  const attrMatch = blockMatch[0].match(new RegExp(`${attr}="([^"]*)"`, "i"));
  return attrMatch ? attrMatch[1] : "";
}

const testcaseRegex = /<testcase[\s\S]*?(?:\/>|<\/testcase>)/gi;
const testcases = xml.match(testcaseRegex) || [];

testcases.forEach((testcase, index) => {
  const name = extractAttr("testcase", "name", testcase) || `Test ${index + 1}`;
  const classname = extractAttr("testcase", "classname", testcase) || "maestro";
  const time = Number(extractAttr("testcase", "time", testcase) || 0);
  const failure = extract("failure", testcase);
  const status = failure ? "failed" : "passed";

  const xrayMatch = name.match(/@([A-Z]+-[0-9]+)/);
  const uuid = crypto.randomUUID();
  const result = {
    uuid,
    historyId: crypto.createHash("md5").update(`${classname}:${name}`).digest("hex"),
    name,
    fullName: `${classname} :: ${name}`,
    status,
    stage: "finished",
    start: Date.now() - Math.round(time * 1000),
    stop: Date.now(),
    labels: [
      { name: "framework", value: "maestro" },
      { name: "suite", value: classname },
      ...(xrayMatch ? [{ name: "xray", value: xrayMatch[1] }] : []),
    ],
    links: xrayMatch
      ? [{ name: xrayMatch[1], url: `#${xrayMatch[1]}`, type: "issue" }]
      : [],
  };

  if (failure) {
    result.statusDetails = {
      message: failure.split("\n")[0],
      trace: failure,
    };
  }

  fs.writeFileSync(
    path.join(outputDir, `${uuid}-result.json`),
    JSON.stringify(result, null, 2)
  );
});

console.log(`Converted ${testcases.length} testcase(s) from ${path.basename(junitPath)}`);
