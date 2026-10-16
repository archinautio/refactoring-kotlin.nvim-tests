-- Test cases for the Kotlin support of refactoring.nvim (see README.md).
--
-- Fields:
--   name   unique name; the expected results live in `expected/<name>/`
--   file   fixture in `project/src/main/kotlin/` where the refactor starts
--   kind   extract_func | extract_func_to_file | extract_var | inline_var | inline_func
--          | print_var | print_loc | print_exp | cleanup (debug prints)
--   at     cursor: `{ line = <text in the line>, word = <text the cursor goes to> }`
--          (the first line of `file` that contains `line`)
--   lines  linewise selection (extract, cleanup): `{ from = <text>, to = <text> }`
--   select charwise selection (extract, print_var, print_exp):
--          `{ line = <text>, text = <selected text> }`
--   opts   (debug prints) options passed to `refactoring.debug.<kind>()`,
--          e.g. `{ output_location = "above" }`
--   input  name asked by extract function/variable (a list for several
--          questions; extract_func_to_file: `{ <function>, <file> }`)
--   refs   (LSP refactors) wait until kotlin-lsp reports at least this many
--          references to the symbol under the cursor, declaration included
--   compiles  false (with `reason`) when the result isn't valid Kotlin on
--             purpose: run.sh then doesn't compile it

-- Extract function writes `P` for the types it can't read from the source.
local placeholder_types = "unknown types are written as the `P` placeholder"

return {
  -- Extract function (Tree-sitter only)
  {
    name = "extract_func_method",
    file = "Main.kt",
    kind = "extract_func",
    lines = { from = "val tax = subtotal * taxRate", to = 'println("Subtotal: $subtotal")' },
    input = "computeTax",
    compiles = false,
    reason = placeholder_types,
  },
  {
    name = "extract_func_top_level",
    file = "Main.kt",
    kind = "extract_func",
    lines = { from = "println(squared + doubled)", to = 'greet("Kotlin")' },
    input = "report",
    compiles = false,
    reason = placeholder_types,
  },
  {
    name = "extract_func_return_value",
    file = "Main.kt",
    kind = "extract_func",
    lines = { from = "val base = 4", to = "val base = 4" },
    input = "initialValue",
    compiles = false,
    reason = placeholder_types,
  },

  -- A function without leading comments after one with them: the new function
  -- goes right above it, not above the commented one.
  {
    name = "extract_func_after_commented_function",
    file = "CommentedFunctions.kt",
    kind = "extract_func",
    lines = { from = 'println("Goodbye")', to = 'println("See you")' },
    input = "sayGoodbye",
  },
  {
    name = "extract_func_after_commented_method",
    file = "CommentedFunctions.kt",
    kind = "extract_func",
    lines = { from = 'println("Second")', to = 'println("Done")' },
    input = "sendSecond",
  },

  -- Extract variable (Tree-sitter only)
  {
    name = "extract_var",
    file = "Main.kt",
    kind = "extract_var",
    select = { line = "val tax = subtotal * taxRate", text = "subtotal * taxRate" },
    input = "taxed",
  },

  -- Inline variable (kotlin-lsp + Tree-sitter)
  {
    name = "inline_var_from_declaration",
    file = "Main.kt",
    kind = "inline_var",
    at = { line = "val tax = subtotal * taxRate", word = "tax" },
    refs = 2,
  },
  {
    name = "inline_var_from_usage",
    file = "Main.kt",
    kind = "inline_var",
    at = { line = "println(squared + doubled)", word = "doubled" },
    refs = 3,
  },

  -- Inline function: basics, indentation and blank lines
  {
    name = "inline_func_block_body",
    file = "Main.kt",
    kind = "inline_func",
    at = { line = "val squared = square(doubled)", word = "square" },
    refs = 2,
  },
  {
    name = "inline_func_statement_call",
    file = "Main.kt",
    kind = "inline_func",
    at = { line = 'greet("Kotlin")', word = "greet" },
    refs = 2,
  },
  {
    name = "inline_func_expression_body",
    file = "ExpressionBody.kt",
    kind = "inline_func",
    at = { line = "fun triple", word = "triple" },
    refs = 2,
  },
  {
    name = "inline_func_nested_blocks",
    file = "NestedBlocks.kt",
    kind = "inline_func",
    at = { line = "classify(value, name)", word = "classify" },
    refs = 2,
  },
  {
    name = "inline_func_class_member",
    file = "BlankLines.kt",
    kind = "inline_func",
    at = { line = "val total = withVat(base)", word = "withVat" },
    refs = 2,
  },
  {
    name = "inline_func_last_in_file",
    file = "BlankLines.kt",
    kind = "inline_func",
    at = { line = "val v = last(3)", word = "last" },
    refs = 2,
  },

  -- Inline function: argument substitution
  {
    -- Positional, named, reordered, defaults, multi-line, non-simple
    -- arguments, a pure call as a statement.
    name = "inline_func_arguments",
    file = "Arguments.kt",
    kind = "inline_func",
    at = { line = "fun addTax", word = "addTax" },
    refs = 9,
  },
  {
    name = "inline_func_local_renames",
    file = "LocalRenames.kt",
    kind = "inline_func",
    at = { line = "fun describe", word = "describe" },
    refs = 3,
  },
  {
    name = "inline_func_repeated_args",
    file = "RepeatedArgs.kt",
    kind = "inline_func",
    at = { line = "fun twice", word = "twice" },
    refs = 4,
  },
  {
    name = "inline_func_body_statements",
    file = "BodyStatements.kt",
    kind = "inline_func",
    at = { line = "fun logAndScale", word = "logAndScale" },
    refs = 3,
  },
  {
    name = "inline_func_cross_file",
    file = "CrossFileUsage.kt",
    kind = "inline_func",
    at = { line = "val reduced = discount(amount)", word = "discount" },
    refs = 3,
  },

  {
    -- A trailing lambda is declared with its parameter's type.
    name = "inline_func_trailing_lambda",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun applyTwice", word = "applyTwice" },
    refs = 2,
  },

  -- Inline function: nested calls
  {
    name = "inline_func_nested_calls",
    file = "NestedCalls.kt",
    kind = "inline_func",
    at = { line = "fun half", word = "half" },
    refs = 8,
  },
  {
    -- Conditional and expression-body calls are skipped: the function is kept.
    name = "inline_func_nested_calls_skipped",
    file = "NestedCalls.kt",
    kind = "inline_func",
    at = { line = "fun noisy", word = "noisy" },
    refs = 6,
  },
  {
    -- One-line lambda skipped, multi-line lambda inlined.
    name = "inline_func_lambdas",
    file = "Lambdas.kt",
    kind = "inline_func",
    at = { line = "fun loud", word = "loud" },
    refs = 3,
  },

  -- Inline function: method calls
  {
    -- `obj.f()`, complex receiver, call inside the class, safe call skipped.
    name = "inline_func_method",
    file = "Methods.kt",
    kind = "inline_func",
    at = { line = "fun price", word = "price" },
    refs = 5,
  },
  {
    name = "inline_func_method_nested",
    file = "Methods.kt",
    kind = "inline_func",
    at = { line = "fun label", word = "label" },
    refs = 2,
  },
  {
    name = "inline_func_extension",
    file = "Methods.kt",
    kind = "inline_func",
    at = { line = "fun String.shout", word = "shout" },
    refs = 2,
  },
  {
    name = "inline_func_object",
    file = "Methods.kt",
    kind = "inline_func",
    at = { line = "fun twice", word = "twice" },
    refs = 2,
  },
  {
    -- Private members: skipped from outside the class, inlined inside it.
    name = "inline_func_private_members",
    file = "Methods.kt",
    kind = "inline_func",
    at = { line = "fun hidden", word = "hidden" },
    refs = 3,
  },

  -- Debug prints (Tree-sitter only). In a statement's header (a parameter, a
  -- loop variable, a condition), the print goes into the body.
  {
    name = "print_var_statement",
    file = "DebugPrint.kt",
    kind = "print_var",
    select = { line = "total += price", text = "total" },
  },
  {
    name = "print_var_above",
    file = "DebugPrint.kt",
    kind = "print_var",
    select = { line = "total += price", text = "price" },
    opts = { output_location = "above" },
  },
  {
    name = "print_var_parameter",
    file = "DebugPrint.kt",
    kind = "print_var",
    select = { line = "fun orderTotal", text = "discount" },
  },
  {
    name = "print_var_for_variable",
    file = "DebugPrint.kt",
    kind = "print_var",
    select = { line = "for (price in prices)", text = "price" },
  },
  {
    name = "print_var_while_condition",
    file = "DebugPrint.kt",
    kind = "print_var",
    select = { line = "while (remaining > 0)", text = "remaining" },
  },
  {
    name = "print_var_do_while_condition",
    file = "DebugPrint.kt",
    kind = "print_var",
    select = { line = "} while (attempts < discount)", text = "attempts" },
  },
  {
    name = "print_var_if_condition",
    file = "DebugPrint.kt",
    kind = "print_var",
    select = { line = "if (total > discount)", text = "total" },
  },
  {
    name = "print_var_lambda_parameter",
    file = "DebugPrint.kt",
    kind = "print_var",
    select = { line = "names.forEach { name ->", text = "name" },
  },
  {
    name = "print_var_local_function_parameter",
    file = "DebugPrint.kt",
    kind = "print_var",
    select = { line = "fun label(city: String)", text = "city" },
  },
  {
    name = "print_loc",
    file = "DebugPrint.kt",
    kind = "print_loc",
    at = { line = "total += price", word = "total" },
  },
  {
    name = "print_loc_in_lambda",
    file = "DebugPrint.kt",
    kind = "print_loc",
    at = { line = "labels.add(name.uppercase())", word = "labels" },
  },
  {
    name = "print_exp",
    file = "DebugPrint.kt",
    kind = "print_exp",
    select = { line = "val summary", text = "amount + tip" },
  },
  {
    name = "print_exp_string_escaped",
    file = "DebugPrint.kt",
    kind = "print_exp",
    select = { line = "val summary", text = '"Total: $" + (amount + tip)' },
  },
  {
    name = "debug_cleanup",
    file = "DebugCleanup.kt",
    kind = "cleanup",
    lines = { from = "__PRINT_LOC_START", to = "__PRINT_EXP_END" },
  },

  -- Limitations: these cases record what happens today in the cases
  -- `docs/` lists as not supported (wrong code included), so a change of
  -- behaviour shows up as a diff.

  -- Extract function
  {
    name = "extract_func_multiple_results",
    file = "ExtractFunctionLimits.kt",
    kind = "extract_func",
    lines = { from = "val first = 1", to = "val second = 2" },
    input = "makeValues",
    compiles = false,
    reason = "only the first value is returned (`second` is undefined), and `P` types",
  },
  {
    name = "extract_func_reassigned_var",
    file = "ExtractFunctionLimits.kt",
    kind = "extract_func",
    lines = { from = "counter += 5", to = "counter += 5" },
    input = "addFive",
    compiles = false,
    reason = "`val counter` redeclares the `var`, the parameter is reassigned, and `P` types",
  },
  {
    name = "extract_func_expression",
    file = "ExtractFunctionLimits.kt",
    kind = "extract_func",
    select = { line = "val area = width * height", text = "width * height" },
    input = "computeArea",
    compiles = false,
    reason = "the extracted function doesn't return the expression",
  },
  {
    name = "extract_func_with_return",
    file = "ExtractFunctionLimits.kt",
    kind = "extract_func",
    lines = { from = "if (value < 0) {", to = "} // end of check" },
    input = "checkNegative",
    compiles = false,
    reason = "the `return` now returns from the extracted function",
  },
  {
    name = "extract_func_in_lambda",
    file = "ExtractFunctionLimits.kt",
    kind = "extract_func",
    lines = { from = "val doubled = value * 2", to = "println(doubled)" },
    input = "printDouble",
    compiles = false,
    reason = placeholder_types,
  },
  {
    name = "extract_func_to_file",
    file = "ExtractFunctionLimits.kt",
    kind = "extract_func_to_file",
    lines = { from = "val area = width * height", to = "val area = width * height" },
    input = { "calculateArea", "src/main/kotlin/ExtractedArea.kt" },
    compiles = false,
    reason = "the new file has no `package` and the function is `private`, and `P` types",
  },

  -- Extract variable
  {
    name = "extract_var_every_occurrence",
    file = "ExtractVariableLimits.kt",
    kind = "extract_var",
    select = { line = "println(width * height)", text = "width * height" },
    input = "area",
  },
  {
    name = "extract_var_conditional",
    file = "ExtractVariableLimits.kt",
    kind = "extract_var",
    select = { line = "val ok = items != null", text = "items.size > limit" },
    input = "tooMany",
    compiles = false,
    reason = "the `null` check no longer guards the extracted expression",
  },
  {
    name = "extract_var_in_lambda",
    file = "ExtractVariableLimits.kt",
    kind = "extract_var",
    select = { line = "items.forEach { println(it * 2) }", text = "it * 2" },
    input = "doubled",
  },
  {
    name = "extract_var_expression_body",
    file = "ExtractVariableLimits.kt",
    kind = "extract_var",
    select = { line = "fun expressionBody", text = "width * 3" },
    input = "tripled",
  },

  -- Inline variable
  {
    name = "inline_var_side_effects",
    file = "InlineVariableLimits.kt",
    kind = "inline_var",
    at = { line = "val id = nextId()", word = "id" },
    refs = 3,
  },
  {
    name = "inline_var_string_template",
    file = "InlineVariableLimits.kt",
    kind = "inline_var",
    at = { line = "val total = price * 2", word = "total" },
    refs = 2,
  },
  {
    name = "inline_var_reassigned",
    file = "InlineVariableLimits.kt",
    kind = "inline_var",
    at = { line = "var count = 1", word = "count" },
    refs = 3,
    compiles = false,
    reason = "the assignment target is replaced too: `(1) += 1`",
  },
  {
    name = "inline_var_class_property",
    file = "InlineVariableLimits.kt",
    kind = "inline_var",
    at = { line = "val start = 10", word = "start" },
    refs = 3,
    compiles = false,
    reason = "`counter.start` isn't replaced, but the property is deleted",
  },
  {
    name = "inline_var_parameter",
    file = "InlineVariableLimits.kt",
    kind = "inline_var",
    at = { line = "println(amount)", word = "amount" },
    refs = 2,
  },

  -- Inline function
  {
    name = "inline_func_vararg",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun sumAll", word = "sumAll" },
    refs = 2,
    compiles = false,
    reason = "the vararg parameter gets only the first argument",
  },
  {
    name = "inline_func_early_return",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun clamp", word = "clamp" },
    refs = 2,
  },
  {
    name = "inline_func_default_uses_param",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun area", word = "area" },
    refs = 2,
    compiles = false,
    reason = "falls back to one `val` per parameter, without the default value",
  },
  {
    name = "inline_func_empty_body",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun doNothing", word = "doNothing" },
    refs = 2,
  },
  {
    name = "inline_func_function_reference",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun isEven", word = "isEven" },
    refs = 2,
    compiles = false,
    reason = "`::isEven` still refers to the deleted function",
  },
  {
    name = "inline_func_extension_implicit_member",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun String.exclaim", word = "exclaim" },
    refs = 2,
    compiles = false,
    reason = "the receiver's implicit members aren't qualified",
  },
  {
    name = "inline_func_inherited_member",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun speak", word = "speak" },
    refs = 2,
    compiles = false,
    reason = "inherited members aren't qualified",
  },
  {
    name = "inline_func_lambda_shadows_member",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun scaled", word = "scaled" },
    refs = 2,
    compiles = false,
    reason = "the lambda parameter is qualified like the member",
  },
  {
    name = "inline_func_conservative_rename",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun greetAll", word = "greetAll" },
    refs = 2,
  },
  {
    name = "inline_func_unit_in_expression",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun logValue", word = "logValue" },
    refs = 2,
  },
  {
    name = "inline_func_blank_lines_in_body",
    file = "InlineFunctionLimits.kt",
    kind = "inline_func",
    at = { line = "fun printTwoLines", word = "printTwoLines" },
    refs = 2,
  },

  -- Debug prints
  {
    name = "print_var_braceless_loop",
    file = "DebugPrintLimits.kt",
    kind = "print_var",
    select = { line = "for (number in numbers)", text = "number" },
    compiles = false,
    reason = "the print goes after the loop, where the loop variable doesn't exist",
  },
  {
    name = "print_var_lambda_result",
    file = "DebugPrintLimits.kt",
    kind = "print_var",
    select = { line = "n * 2", text = "n" },
    compiles = false,
    reason = "the print becomes the lambda's result",
  },
  {
    name = "print_var_catch_parameter",
    file = "DebugPrintLimits.kt",
    kind = "print_var",
    select = { line = "catch (error", text = "error" },
  },
}
