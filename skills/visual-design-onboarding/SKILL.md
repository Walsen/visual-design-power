---
name: visual-design-onboarding
description: First-run setup and health check for the visual-design power. Use when the user has just installed the power, asks to get started or try it, or when Playwright or Figma tools are missing or failing.
---

# visual-design power: onboarding

Run these steps in order the first time the power is used in a session, and again whenever a tool from the power fails. Report each result to the user in one line. Fix what you can; for anything that needs the user (signing in, reconnecting a server), say exactly what to click.

## Step 1: Check local dependencies

Run the bundled check from the user's project directory:

```sh
sh <power-root>/skills/visual-design-onboarding/scripts/check-setup.sh
```

`<power-root>` is the folder that holds `plugin.json` (for an installed power, `~/.kiro/powers/installed/visual-design-power`). The script checks Node.js and npx, the Playwright MCP package, a local Chromium, and the Impeccable launcher. It prints one `OK`, `WARN` or `FAIL` line per check and never installs anything.

Kiro's shell can echo the command back mixed with its output. When output looks garbled or empty, redirect it to a file (`> /tmp/vd-check.txt 2>&1`) and read the file.

## Step 2: Check the MCP servers

Activate the power and look at the tools listed per server.

- **Playwright:** call `browser_navigate` with `https://example.com`, then `browser_snapshot`.
  - If activation lists the tools but the call fails with "Tool ... does not exist", the server didn't start. Ask the user to open the **MCP Servers** view in the Kiro panel and reconnect `power-visual-design-power-playwright`. The first start downloads `@playwright/mcp` through npx and can time out on a slow connection; running `npx -y @playwright/mcp@latest --help` once in a terminal warms the cache.
  - If Chromium is missing, the user can run `npx playwright install chromium`. Ask before running it, since it downloads about 150 MB.
- **Figma:** if activation shows **no tools**, the server is waiting for sign-in. Ask the user to reconnect the `figma` server from the MCP Servers view and finish the browser sign-in. Figma is optional; skip it when the user has no Figma files.

## Step 3: Load Impeccable's project context

From the user's project directory:

```sh
<power-root>/skills/impeccable/scripts/impeccable context > /tmp/vd-context.txt 2>&1
```

Read the file. `NO_PRODUCT_MD` or `PRODUCT_INIT_REQUIRED` means a new project: Impeccable will run its `init` interview before designing. The first run may download the launcher's binary.

## Step 4: Tell the user what works

Summarize in a short list: which servers work, which fallbacks apply (see the `visual-design-guide` skill), and what the user needs to do, if anything. Then offer a first task, for example:

- "Use impeccable to design a landing page for <your product>." (new page)
- "Critique index.html" or "audit index.html" (existing page)
- "Add tasteful animations to the hero." (motion)

Then follow the `visual-design-guide` skill for picking a skill and for Kiro-specific workarounds.
