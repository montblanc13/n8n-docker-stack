---
name: n8n-ui-healthcheck
description: Run a browser-based healthcheck of the local n8n instance when the user wants to verify that the UI loads, authentication works, and a workflow can be opened with Playwright.
---

# N8N UI Healthcheck

Use this skill when the user wants an end-to-end UI healthcheck of the local n8n instance with Playwright.

## Preconditions

- Run from the repository root.
- Read `.env` to determine the target URL. Prefer `N8N_EDITOR_BASE_URL`; fall back to `http://localhost:5678`.
- Read `.env` for UI login credentials using `UI_USER_EMAIL` and `UI_USER_PASSWORD`.
- If `.env` uses Docker Compose escaping such as `$$`, interpret it as a literal `$` before using the credential in the browser.
- If either `UI_USER_EMAIL` or `UI_USER_PASSWORD` is missing, stop and report that the local UI credentials are not configured.
- If the user explicitly provides different credentials for the current run, those override `.env`.

## Workflow

1. Read `.env` and resolve the editor URL plus `UI_USER_EMAIL` and `UI_USER_PASSWORD`.
2. Normalize UI credentials from Compose-style escaping before use, for example `$$` -> `$`.
3. Open the URL with Playwright.
4. Inspect the page state before acting:
   - If a login form is visible, fill the email or username field with `UI_USER_EMAIL` and the password field with `UI_USER_PASSWORD`, then submit.
   - If the instance is already authenticated, continue without re-logging.
   - If an owner-setup or first-run screen appears instead of login, stop and report that the instance is not initialized for normal user login yet.
5. Wait until the main n8n application shell is visible.
6. Navigate to workflow creation by clicking the visible action that creates a workflow, such as `New workflow`, `Create workflow`, or the equivalent current UI label.
7. Confirm the editor screen loads by checking for strong signals such as the workflow canvas, the workflow title field, or the save button.
8. Report pass or fail with the blocking screen or error if any step fails.

## Playwright Guidance

- Prefer `browser_snapshot` before each interaction so the current accessible labels drive the next step.
- Use visible labels from the snapshot instead of hard-coded CSS selectors.
- After login, wait for the application shell rather than sleeping blindly.
- If a modal or onboarding prompt blocks the UI, dismiss it only when that clearly helps reach the workflow editor.

## Notes

- This skill is a UI healthcheck, not a webhook healthcheck.
- Avoid leaving accidental changes behind. If a blank workflow was opened successfully, close it without saving when practical.
- Expected local credential variables: `UI_USER_EMAIL` and `UI_USER_PASSWORD`.
