#!/usr/bin/env node
/**
 * Resolves UI page metadata from config/journey-map.json for Maestro navigation flows.
 * Usage: node scripts/resolve-page.js <pageKey>
 */
const fs = require("fs");
const path = require("path");

const pageKey = process.argv[2];
const baseUrl = process.env.BASE_URL || "http://localhost:3000";

if (!pageKey) {
  console.error("Usage: node scripts/resolve-page.js <pageKey>");
  process.exit(1);
}

const mapPath = path.join(__dirname, "..", "config", "journey-map.json");
const map = JSON.parse(fs.readFileSync(mapPath, "utf8"));
const page = map.ui.pages[pageKey];

if (!page) {
  console.error(`Unknown page key: ${pageKey}`);
  process.exit(1);
}

const lines = {
  PAGE_KEY: pageKey,
  PAGE_URL: `${baseUrl}${page.path}`,
  PAGE_ASSERT: page.assertText,
};

if (page.next) {
  lines.CONTINUE_ID = page.next.buttonId;
  lines.SUCCESS_TEXT = page.next.successText;
  lines.NEXT_PAGE = page.next.target;
  lines.NEXT_PAGE_URL = `${baseUrl}${map.ui.pages[page.next.target].path}`;
}

Object.entries(lines).forEach(([key, value]) => {
  console.log(`${key}=${value}`);
});
