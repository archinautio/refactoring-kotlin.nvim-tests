# Extract variable

`extract_var()` + a motion or on a visual selection (select exactly the
expression), then type the name. It only uses Tree-sitter (no LSP).

## Supported

### An expression → a `val` above its statement

Kotlin infers the type, so no type is written. Case `extract_var` (selection:
`subtotal * taxRate`):

```kotlin
// before
val tax = subtotal * taxRate

// after
val taxed = subtotal * taxRate
val tax = taxed
```

### An expression inside a one-line lambda

Case `extract_var_in_lambda`: the `val` goes inside the lambda, so `it` is
still in scope, but the layout needs tidying:

```kotlin
items.forEach { val doubled = it * 2
println(doubled) }
```

## Not supported

- **The same expression in another function, or in an expression body**
  (tested: `extract_var_every_occurrence`, `extract_var_expression_body`).
  refactoring.nvim also replaces the other occurrences of the expression in the
  buffer, and needs a statement before all of them to insert the `val`. When
  there's none (an occurrence in another function, or an expression-bodied
  function like `fun f(w: Int) = w * 3`), it crashes with "extract_var.lua:263:
  assertion failed!" and nothing changes.
- **Expressions that only run conditionally** (tested:
  `extract_var_conditional`). The `val` goes before the whole statement, so the
  expression runs unconditionally. With
  `val ok = items != null && items.size > limit`, `items.size` moves before the
  `null` check and no longer compiles.
