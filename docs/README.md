# Kotlin refactors: what's supported

What each refactor does on Kotlin code with refactoring-kotlin.nvim, and what
it doesn't do. The examples are the expected results of the test battery in
this repo, so they are exactly what the refactor produces.

| Refactor | refactoring.nvim function | Needs kotlin-lsp | Page |
|---|---|---|---|
| Extract function | `extract_func()` (operator, or a visual selection) | no | [extract-function.md](extract-function.md) |
| Extract variable | `extract_var()` (operator, or a visual selection) | no | [extract-variable.md](extract-variable.md) |
| Inline variable | `inline_var()` on the variable (declaration or a usage) | yes | [inline-variable.md](inline-variable.md) |
| Inline function | `inline_func()` on the function (definition or a call) | yes | [inline-function.md](inline-function.md) |
| Debug prints | `refactoring.debug`'s `print_var()`, `print_exp()`, `print_loc()` and `cleanup()` | no | [debug-print.md](debug-print.md) |

The pages say "the keymap" for whichever keymap you mapped to that function
(see the [plugin's README](https://github.com/archinautio/refactoring-kotlin.nvim#installation)). kotlin-lsp itself only supports rename, so these
refactors come from refactoring.nvim plus this plugin.

## Reading the pages

Each page has two sections:

- **Supported**: what works, with the test case that checks it (`cases.lua`
  and `expected/<case>/`).
- **Not supported**: what doesn't work and what happens instead. Each item says
  how much we know about it:
  - **tested**: a test case checks this behaviour on purpose;
  - **verified**: it was observed while building the support, but no test checks it;
  - **untested**: it follows from how the code works, but nobody has run it.

When a page and the code disagree, the test battery is right: run `../run.sh`.
