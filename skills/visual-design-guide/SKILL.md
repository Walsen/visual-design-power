---
name: visual-design-guide
description: How to use the visual-design power in Kiro. Read before any design, UI, landing page, critique, audit or animation task to pick the right bundled skill and to apply the Kiro workarounds for Impeccable's decision page, subagents, screenshots and hooks.
---

# visual-design power: usage guide

The power bundles 20 skills and two MCP servers. This guide says which skill to use and how to run the skills inside Kiro, where some of their assumptions don't hold. If setup hasn't been checked this session, run the `visual-design-onboarding` skill first.

## Pick the skill

Use one primary skill per request. When two could fit, ask the user once.

| The user wants to... | Skill |
|---|---|
| Design, redesign, critique, audit, polish or restyle any interface (default for design work) | `impeccable` |
| A company, product, shop or café website held to a "not generic" bar, with a browser-checked finish gate | `design-taste-frontend` |
| Build one animation from scratch | `animate` (React Native/Expo: `animate-expo`) |
| Coordinate several elements moving together | `choreograph` |
| Find what should animate, without editing | `find-animation-opportunities` |
| Review motion code against a high bar | `review-animations` |
| Plan motion improvements across a codebase | `improve-animations` |
| Remove motion that shouldn't be there | `remove-animations` |
| Fix dropped frames | `animation-performance` |
| Name a motion effect they can only describe | `animation-vocabulary` |
| Drag, swipe or sheet interactions | `gestures`; Apple-style physics: `apple-design` |
| General UI polish philosophy | `emil-design-eng` |
| Make a web app feel native on phones | `mobile-native` |
| Stress a component with worst-case data | `break-ui` |
| Compare several versions of one component | `prototype` (only when asked explicitly) |
| Choose a frontend library | `pick-ui-library` (only when asked explicitly) |
| Toasts with Sonner | `ask-sonner` |
| Write Swift | `write-swift` |

`impeccable` and `design-taste-frontend` overlap. If the user names neither, use `impeccable` and mention the other once.

## Running Impeccable in Kiro

Impeccable's scripts live at `<power-root>/skills/impeccable/scripts/impeccable`, where `<power-root>` holds `plugin.json`. Run them with the user's project as the working directory. Its docs write the path as `.kiro/skills/impeccable/scripts/impeccable`; substitute the real path.

**Shell output.** Kiro's shell can echo commands back garbled, or return no output. Redirect each launcher call to a file and read the file:

```sh
"$IMP" context --target index.html > /tmp/imp-context.txt 2>&1; echo "exit=$?"
```

**Interviews (`init`, `shape`).** Kiro has no structured question tool. Ask the questions in chat, at most three or four per round, and wait for the answer. Write PRODUCT.md only after a real answer. Mark what the user didn't answer as open, never invented.

**Direction round (decision page).** For new pages and redesigns:

1. Run `concept-seed --scope direction --mode <mode>` and build the payload as it says (`serve-question --schema` prints the shape).
2. Run `serve-question --start --payload <file>` and read the URL and key from its output.
3. Write each card's `html` sketch **after** starting the server. The page only counts files written after the round was served.
4. Open the URL with `open <url>` (macOS) or `xdg-open <url>`.
5. Start `serve-question --wait --key <key>` with `control_bash_process` (action `start`) so it doesn't block. Read the answer with `get_process_output`. If the user hasn't picked yet, tell them to choose on the page and check again on their next message.
6. After the answer, send the choice ping the roll's TELEMETRY line names (`--kind <kind>`). It prints `choice already recorded` when the page already sent it.

**No image generation.** Kiro has no image tool and no image API key by default, so every build is code-led. Set `"buildPath": {"value": "code"}` without `toggle`, and give each card an `html` sketch instead of a `comp`.

**Shipped subagents.** Impeccable's `impeccable-finish-reviewer`, `impeccable-asset-producer` and documenter agents aren't installed in Kiro. Use the in-thread versions in `skills/impeccable/reference/degraded/` (`finish-reviewer.md`, `documenter.md`, `asset-producer.md`, `manual-edit-applier.md`), and tell the user in one line that you substituted them. A finished new page still needs the finish review and DESIGN.md.

**Design hook.** Impeccable's automatic detector hook doesn't run in Kiro. Run `detect --json <changed files>` once when the UI is finished, fix what is mechanical, and report the rest. Detector findings can be false positives; say so when you judge one to be.

**Fonts.** Persuade-mode pages need a display face with character, served from the project. Download the font file into the project (for example from the `google/fonts` GitHub repo) and load it with `@font-face`. Don't use hosted font stylesheets or system faces such as Arial Black for display type.

## Checking the rendered page

1. **Playwright MCP (preferred):** `browser_navigate`, `browser_resize`, `browser_take_screenshot`, `browser_emulate_media` for dark mode and reduced motion.
2. **Fallback when the Playwright server is down:** serve the project (`python3 -m http.server <port>` as a background process) and capture with the cached headless Chromium:

   ```sh
   CHROME=$(find ~/Library/Caches/ms-playwright -name chrome-headless-shell -type f | sort | tail -1)
   "$CHROME" --hide-scrollbars --virtual-time-budget=3000 --window-size=1440,900 --screenshot=.impeccable/review/desktop.png http://localhost:<port>/
   "$CHROME" --hide-scrollbars --virtual-time-budget=3000 --window-size=390,844 --screenshot=.impeccable/review/mobile.png http://localhost:<port>/
   ```

   A tall `--window-size` stands in for a full-page capture, but it also makes `100vh`/`100svh` sections that tall. Cap hero heights (for example `min(100svh, 900px)`) or capture the first viewport separately. Use a new file name for each capture: Kiro's file reader can return a cached image for a path it has already read.
3. Stop any server you started when you finish.

## Taste Skill

`design-taste-frontend` defines a Claude Code hook that runs `scripts/gate.mjs`. Kiro doesn't run hooks defined inside skills, so run the gate by hand when the skill asks for its finish check, and report the result.

## Before saying a design task is done

- The page was looked at, at desktop and mobile widths, after the last change.
- Placeholder content (names, prices, hours, addresses, coffees, testimonials) is labeled as such on the page and listed for the user.
- For Impeccable new work: the surface brief has its direction contract, the detector ran, and the finish review and DESIGN.md are done or explicitly reported as not done.
