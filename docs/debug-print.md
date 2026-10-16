# Debug prints

refactoring.nvim's debug prints, from `require("refactoring.debug")`:

- `print_var()` + a motion or a visual selection: prints the variables in it.
- `print_exp()` + a motion or a visual selection: prints the selected expression.
- `print_loc()` on a line: prints where it is.
- `cleanup()` + a motion or a visual selection: removes the prints.

They only use Tree-sitter (no LSP). Each print is a `println` between two marker
comments, so `cleanup()` can find it. By default it goes below the statement
under the cursor (`{ output_location = "above" }` puts it above). It's labelled
with its location (the enclosing functions, loops, `if`s and lambdas, as
`(anon)`) and a count for repeated prints.

## Supported

### A variable → a `println` below its statement

Case `print_var_statement` (selection: `total` in `total += price`):

```kotlin
for (price in prices) {
    total += price
    // __PRINT_VAR_START
    println("┆orderTotal#for┆ ╎total╎ ┊1┊: $total")// __PRINT_VAR_END
}
```

Above the statement: case `print_var_above`.

A backticked variable works too: `` $`delivery note` `` is a valid template
(case `print_var_backticked`).

### A variable in a statement's header → into its body

A parameter, a `for` variable, a lambda parameter, or a `while` or `if`
condition: the print goes at the start of the body, where the variable exists.
Below its whole statement it could be out of scope. Cases
`print_var_parameter`, `print_var_for_variable`, `print_var_lambda_parameter`,
`print_var_local_function_parameter`, `print_var_while_condition`,
`print_var_if_condition` (only the `if` branch, not the `else`) and
`print_var_labelled_loop_variable` (a loop with a label). A `do`-`while`
condition goes below the loop (case `print_var_do_while_condition`).

The layout needs tidying: refactoring.nvim leaves a line with only the
indentation and the start marker at column 0. The code still compiles. This
happens in every language, not just Kotlin. Case `print_var_for_variable`
(selection: `price` in `for (price in prices)`):

```kotlin
for (price in prices) {
        
// __PRINT_VAR_START
    println("┆orderTotal#for┆ ╎price╎ ┊1┊: $price")// __PRINT_VAR_END
    total += price
}
```

### An expression

Quotes, `\` and `$` are escaped in the label, so any expression can be printed.
Cases `print_exp` and `print_exp_string_escaped` (selection:
`"Total: $" + (amount + tip)`):

```kotlin
val summary = "Total: $" + (amount + tip)
// __PRINT_EXP_START
println("┆receipt┆ ╎\"Total: \$\" + (amount + tip)╎ ┊1┊: ${"Total: $" + (amount + tip)}")// __PRINT_EXP_END
```

### A location

Cases `print_loc` and `print_loc_in_lambda`:

```kotlin
names.forEach { name ->
    labels.add(name.uppercase())
    // __PRINT_LOC_START
    println("┆shippingLabels#(anon)┆ ┊1┊")// __PRINT_LOC_END
}
```

### Cleanup

Case `debug_cleanup`: the prints of all three kinds in the selected lines are
removed, with their markers.

## Not supported

- **The variable of a loop without braces** (tested:
  `print_var_braceless_loop`). `for (n in numbers) println(n)` has no body to
  print into, so the print goes after the loop, where `n` doesn't exist: it
  doesn't compile.
- **Below a lambda's last expression** (tested: `print_var_lambda_result`). The
  print becomes the lambda's result. Here it doesn't compile; when the result is
  unused or its type is inferred, it compiles but the behaviour changes:

  ```kotlin
  val doubled: List<Int> = numbers.map { n ->
      n * 2
      // __PRINT_VAR_START
      println("┆debugLambdaResult#(anon)┆ ╎n╎ ┊1┊: $n")// __PRINT_VAR_END
  }
  ```

  Use `{ output_location = "above" }` there.
- **A `catch` parameter** (tested: `print_var_catch_parameter`). It isn't known
  as a declaration, so refactoring.nvim says "Couldn't find any reference
  inside of the extracted range with a declaration above output range" and
  nothing changes.
- **Above a labelled loop** (tested: `print_var_labelled_loop_above`). With
  `{ output_location = "above" }` and the cursor in the loop's header, the print
  goes between the label and the loop. The label then belongs to the print, and
  `break@search` doesn't compile ("Label does not denote a reachable loop"):

  ```kotlin
      var found = -1
      search@ 
  // __PRINT_VAR_START
      println("┆firstOverLimit┆ ╎prices╎ ┊1┊: $prices")// __PRINT_VAR_END
      for (price in prices.sorted()) {
  ```

  The label isn't part of the loop's Tree-sitter node, and refactoring.nvim
  only knows where a statement's node starts. Below the loop (the default)
  works: case `print_var_labelled_loop_variable`.
- **An `else if` condition or a `when` subject** (untested). Only the first
  branch of an `if` is used as its body, and `when` has none, so the print goes
  around the whole statement.
