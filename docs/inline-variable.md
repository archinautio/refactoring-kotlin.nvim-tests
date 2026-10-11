# Inline variable

`inline_var()` with the cursor on the variable, at its declaration or at any
usage. kotlin-lsp finds the usages (`textDocument/definition` and
`references`). Tree-sitter finds the declaration and replaces each usage.

## Supported

### A local `val`/`var` with a value → every usage, declaration removed

The value is wrapped in parentheses at each usage. Case
`inline_var_from_declaration`:

```kotlin
// before
val tax = subtotal * taxRate
println("Subtotal: $subtotal")
val result = subtotal + tax

// after
println("Subtotal: $subtotal")
val result = subtotal + (subtotal * taxRate)
```

### From a usage, with several usages

Case `inline_var_from_usage` (cursor on `doubled` in `println(...)`):

```kotlin
// before
val doubled = base * 2
val squared = square(doubled)
println(squared + doubled)

// after
val squared = square((base * 2))
println(squared + (base * 2))
```

## Not supported

- **Smart parentheses** (tested: `inline_var_from_usage`). They're always
  added, even where they aren't needed: `square((base * 2))`. Inline function
  has precedence-aware parentheses, but inline variable is upstream's code.
- **Side effects** (tested: `inline_var_side_effects`). The value is copied
  into every usage, so `val id = nextId()` used twice calls `nextId()` twice:
  `println((nextId()))` and `println((nextId()) + 1)`.
- **String templates** (tested: `inline_var_string_template`).
  `"Total: $total"` becomes `"Total: $(price * 2)"`, which compiles but prints
  `$(price * 2)` literally.
- **A `var` that's reassigned** (tested: `inline_var_reassigned`). The
  assignment's target is replaced too, `(1) += 1`, which doesn't compile.
- **Class or top-level properties** (tested: `inline_var_class_property`).
  Usages inside the class are replaced (`fun next() = (10) + 1`), but member
  usages from outside (`counter.start`) aren't, and the property is deleted.
- **Variables without a `= value` declaration**: parameters, `for` loop
  variables, lambda parameters, destructuring (tested with a parameter:
  `inline_var_parameter`). Nothing changes; the plugin reports "Couldn't find
  the definition of the symbol under cursor using treesitter".
