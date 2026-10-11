# CLAUDE.md

Test battery for refactoring-kotlin.nvim, the plugin in `../refactoring-kotlin.nvim`
(its own git repo). `README.md` covers what it tests, how to run it, the layout
and the steps to add a case; this file is what you need to maintain it.

## When to run it

After any change to the plugin (`../refactoring-kotlin.nvim/lua/`, `queries/`)
or to this repo: run `./run.sh` and report the summary line. It must end in
`ALL PASSED` (exit 0). While iterating, `./run.sh --no-compile <pattern>` is
faster; finish with a full run. A bug in a refactor is fixed in the plugin repo,
not here.

## Expected results are reviewed, never trusted

`--update` records whatever the refactor produced, bugs included. After an
update, review every changed case as a diff against its fixture (the fixture is
what the refactor started from):

```sh
for f in expected/<case>/*.kt; do diff -u project/src/main/kotlin/$(basename $f) $f; done
cat expected/<case>/messages.txt
```

To see what an update changed, copy `expected/` to the scratchpad before
running it and `diff -rq` afterwards: only the cases you meant to change should
differ. Never `--update` to make a failing case pass without understanding the
diff. A bug in the refactor should be fixed in the plugin, and a bug in the
harness in `runner.lua`/`run.sh`/`minimal_init.lua`.

## Keep `docs/` in sync

`docs/` is the plugin's user documentation: each refactor's supported and
unsupported cases. It lives here to keep the plugin repo minimal, and the
plugin's README links to it (until there's a website). Its examples are copied
from `expected/`, and each unsupported item is labelled *tested*, *verified* or
*untested* (see `docs/README.md`), naming the case. When behaviour changes:

- update the affected page, and copy any changed example again from `expected/`;
- when you add a case for an unsupported item, label it *tested* and name the
  case. When a limitation is lifted, move it to **Supported**;
- don't label something *tested* or *verified* without a case or a run behind it.

## The test environment

- `run.sh` points `XDG_CONFIG_HOME`/`XDG_DATA_HOME`/`XDG_STATE_HOME`/`XDG_CACHE_HOME`
  into `.deps/xdg/` and starts Neovim with `-u minimal_init.lua`, so nothing
  from the user's Neovim config is loaded. That matters: a config with its own
  `queries/kotlin/refactor_*.scm` would be merged with the plugin's (`;; extends`).
- `minimal_init.lua` clones refactoring.nvim, async.nvim and nvim-treesitter
  into `.deps/` at **pinned commits** and builds the Kotlin parser there. The
  expected results depend on refactoring.nvim's code (and the recorded crash
  message includes its line numbers). To test against a newer refactoring.nvim,
  change its commit, run, and review every diff as for `--update`.
- Indentation is set there to Kotlin's style (4 spaces, `expandtab`). Neovim's
  Kotlin ftplugin doesn't set it, and re-indenting in the inline function patch
  depends on it.
- The plugin comes from `PLUGIN_DIR` (default `../refactoring-kotlin.nvim`),
  prepended to 'runtimepath'. There are no git submodules, on purpose.
- To reproduce a case by hand in the same environment, export the same `XDG_*`
  variables and run `nvim -u minimal_init.lua project/src/main/kotlin/<File>.kt`.

## How the runner behaves

- **One session for all cases**: one headless Neovim and one kotlin-lsp. After
  each case, every modified buffer is reverted with `nvim_buf_set_lines` from
  the file on disk (a normal change, so kotlin-lsp is told), never written.
  Fixtures on disk never change.
- **What a case records**: every buffer it modified (the whole file, so
  cross-file refactors record several) plus `messages.txt` with all the
  notifications in order. Upstream's own messages are part of it, including
  "Inlined N function occurrences", which also counts the calls that were
  skipped. That's an upstream quirk, so leave it in the expected results.
  `error.txt` appears only when a case throws.
- **Notifications are captured** by replacing `vim.notify` (also so that a
  multi-line message can't block headless Neovim on a hit-enter prompt, which
  is why the plugin's own warning is a single line).
- **Cursor search**: `at.line` is a plain substring (first matching line of the
  file) and `at.word` a whole word inside it, so pick a `line` text that is
  unique in its fixture.
- **LSP cases wait for kotlin-lsp** until the definition at the cursor is
  `at.word` and there are at least `refs` references, declaration included,
  for up to 240 s. A timeout error with "definition X (expected Y)" usually
  means the cursor is on the wrong symbol, not that kotlin-lsp is stale. Get
  `refs` by counting the declaration plus every call in all fixtures.
- **Async refactors** are considered done once a notification arrives and the
  notifications stop for 300 ms, or as soon as an error appears in
  `v:errmsg`. That's how a crash inside the plugin surfaces (e.g. upstream's
  `extract_var.lua` assertion). The error is recorded in `messages.txt` as
  `Error: <first line>` with directories stripped, so it's stable across
  machines. It also changes if upstream changes line numbers.
- **Neovim's stderr** (stack traces of those crashes, startup errors) goes to
  `.out/nvim.log`, so that it doesn't get mixed into the PASS/FAIL lines;
  `run.sh` prints its tail when the run fails.
- **`compiles = false`** (with `reason`) is for results that are invalid Kotlin
  on purpose. Today that's only extract function, which writes the `P`
  placeholder for types it can't read. The runner writes `.skip-compile` in
  `.out/results/<case>/`, which `run.sh` reads. It's not part of the expected
  results.

## Fixtures

- Every file in `project/src/main/kotlin/` is `package demo` and they compile
  **together**, so top-level names must be unique across files. `describe`
  and `Shop` already clashed once. Check with `project/gradlew -p project
  compileKotlin --quiet`.
- **Extending a fixture changes the expected result of every case that starts
  from that file**, because a case records the whole file. Regenerate those
  cases too, and check that their diff only gained the new lines.
- **Limitation cases** (after the "Limitations" comment in `cases.lua`, mostly in
  the `*Limits.kt` fixtures) record today's behaviour for everything `docs/`
  lists as not supported, even when it's wrong code. Most are
  `compiles = false` with the observed reason. A diff there means the behaviour
  changed. If it improved, move the case to the supported part of `cases.lua`
  (as was done with `inline_func_trailing_lambda`), drop `compiles = false` and
  move the item to **Supported** in `docs/`. Cases that skip a call (safe
  calls, conditional code, one-line lambdas, private members) are limitations
  too.

## Gradle

- The wrapper (`project/gradlew`, Gradle 9.7.1) belongs to the suite: keep it
  under version control. `.gradle/`, `build/` and `.kotlin/` are ignored.
- `gradle.properties` sets `kotlin.jvm.target.validation.mode=warning`: the
  local JDK (25) is newer than the newest JVM target Kotlin supports (24), and
  without it every compile fails before compiling anything.
- `run.sh` compiles each case in `.out/compile/` (a pristine copy of `src/`,
  plus the case's changed files), so a failure points at one case. Errors are
  the `e:` lines.
