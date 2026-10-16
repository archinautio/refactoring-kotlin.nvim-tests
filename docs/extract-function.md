# Extract function

`extract_func()` + a motion (e.g. `ip`) or on a visual selection, then
type the name. It only uses Tree-sitter (no LSP).

## Supported

### Statements in a class method → a `private fun` member

Variables declared before the selection and used inside it become parameters.
Their type is copied when the source writes it (`taxRate: Double`). A variable
declared inside and used after the selection is returned. Case
`extract_func_method`:

```kotlin
// before (selection: the `val tax` and `println` lines)
fun total(prices: List<Int>, taxRate: Double): Double {
    val subtotal = prices.sum()
    val tax = subtotal * taxRate
    println("Subtotal: $subtotal")
    val result = subtotal + tax
    return result
}

// after
private fun computeTax(subtotal: P, taxRate: Double): P {
    val tax = subtotal * taxRate
    println("Subtotal: $subtotal")

    return tax
}

fun total(prices: List<Int>, taxRate: Double): Double {
    val subtotal = prices.sum()
    val tax = computeTax(subtotal, taxRate)
    val result = subtotal + tax
    return result
}
```

### Statements in a top-level function → a top-level `private fun`

The new function goes right above the function it came from (above its
comments, if any), also when an earlier function has comments and this one
doesn't (cases `extract_func_after_commented_function` and, in a class,
`extract_func_after_commented_method`). With no value used afterwards, the call
is a plain statement. Case `extract_func_top_level`:

```kotlin
private fun report(squared: P, doubled: P) {
    println(squared + doubled)
    greet("Kotlin")
}

fun main() {
    // ...
    report(squared, doubled)
}
```

### A declaration whose variable is used afterwards

Case `extract_func_return_value`: `val base = 4` becomes
`val base = initialValue()`, and `initialValue()` returns it.

### Statements inside a lambda

Case `extract_func_in_lambda`: the new function goes above the enclosing
top-level function and the lambda parameter is passed as an argument
(`values.forEach { value -> printDouble(value) }`). The lambda parameter's type
isn't written in the source, so it's `P`.

## Not supported

- **Inferred types** (tested: every `extract_func_*` case with parameters or
  a return value). A type is only known
  when the source writes it (a parameter, `val x: Int = …`); otherwise the
  parameter or return type is the placeholder `P`, which doesn't compile until
  you replace it. kotlin-lsp knows the types, but the plugin doesn't ask it.
- **Several values used after the selection** (tested:
  `extract_func_multiple_results`). Only the first one is returned, with the
  warning "The extracted function requires multiple return values; only the
  first one is returned"; the others are no longer declared at the call site:

  ```kotlin
  val first = makeValues()
  println(first + second) // `second` is undefined
  ```
- **Assigning to an existing variable** (tested: `extract_func_reassigned_var`).
  The call redeclares it (`var counter = 0` then `val counter = addFive(counter)`)
  and the new function reassigns its parameter (`counter += 5`), which Kotlin
  doesn't allow.
- **Selecting an expression** instead of whole statements (tested:
  `extract_func_expression`). The expression becomes a statement of a function
  that returns nothing, so `val area = computeArea(width, height)` is `Unit`.
- **A selection that contains `return`** (tested: `extract_func_with_return`).
  The `return` now leaves the new function instead of the caller, and its value
  doesn't match the new function's (missing) return type.
- **Extract to another file** (tested: `extract_func_to_file`, not mapped to a
  key). The new file has no `package` line and the function is `private`, so
  the call can't see it; the types are `P` too.
