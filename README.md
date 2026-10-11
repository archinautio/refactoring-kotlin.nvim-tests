# refactoring-kotlin.nvim tests

Automated tests for [refactoring-kotlin.nvim](https://github.com/archinautio/refactoring-kotlin.nvim), the
Kotlin support for [refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim).
They live in their own repo so that installing the plugin doesn't download them.

Each case runs a real refactor in a headless Neovim (refactoring.nvim, the
plugin and kotlin-lsp), compares the changed files and the notifications with
`expected/`, and then compiles the result with Gradle.

## Requirements

- `nvim` 0.12.5+, `git`, and the `tree-sitter` CLI with a C compiler (to build
  the Kotlin parser).
- `kotlin-lsp` in `PATH`.
- A JDK for Gradle.
- The plugin checked out next to this repo (`../refactoring-kotlin.nvim`), or
  its path in `PLUGIN_DIR`.
- Optionally, [StyLua](https://github.com/JohnnyMorganz/StyLua): `run.sh` then
  checks that the Lua of both repos is formatted (`stylua .` in each).

The first run clones refactoring.nvim and its dependencies at pinned commits,
builds the Kotlin parser into `.deps/`, and downloads Gradle and the Kotlin
Gradle plugin. Later runs work offline. Your own Neovim config, plugins and
parsers aren't used.

## Running

```sh
./run.sh                    # every case, then compile every result
./run.sh inline_func_method # only the cases whose name matches (Lua pattern)
./run.sh --no-compile       # skip the Gradle step
./run.sh --update           # save the results as the new expected ones
PLUGIN_DIR=~/elsewhere/refactoring-kotlin.nvim ./run.sh
```

It prints `PASS`/`FAIL` per case (with a diff on failure) and exits with a
non-zero status if anything failed. The results of the last run are in
`.out/results/<case>/`.

## Layout

- `project/`: Gradle Kotlin project (with its wrapper). Each file in
  `src/main/kotlin/` is the fixture for one feature; together they compile.
- `cases.lua`: the cases (file, refactor, cursor or selection, input). The
  cursor is found by text, so fixtures can change without fixing line numbers.
- `expected/<case>/`: the files each case changes and its `messages.txt`.
- `minimal_init.lua`: the Neovim configuration the tests run with (pinned
  dependencies, Kotlin parser, kotlin-lsp, the plugin).
- `runner.lua`: runs inside Neovim; `run.sh` starts it and compiles the results.
- `docs/`: the plugin's user documentation: what each refactor supports and
  doesn't, with examples taken from `expected/` ([start here](docs/README.md)).
  It lives here, not in the plugin, to keep what users install minimal.

## Adding a case

1. Add or extend a fixture in `project/src/main/kotlin/` (it must compile:
   `project/gradlew -p project compileKotlin`).
2. Add the case to `cases.lua`.
3. Run `./run.sh --update <name>` and **review** `expected/<name>/` before
   committing it: `--update` records whatever the refactor produced.

## License

[MIT](LICENSE)

