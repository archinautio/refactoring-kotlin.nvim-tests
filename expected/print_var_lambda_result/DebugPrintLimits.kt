package demo

// Debug prints: what isn't supported.

fun debugBracelessLoop(numbers: List<Int>) {
    for (number in numbers) println(number)
}

fun debugLambdaResult(numbers: List<Int>): List<Int> {
    val doubled: List<Int> = numbers.map { n ->
        n * 2
        // __PRINT_VAR_START
        println("┆debugLambdaResult#(anon)┆ ╎n╎ ┊1┊: $n")// __PRINT_VAR_END
    }
    return doubled
}

fun debugCatchParameter(text: String): Int {
    try {
        return text.toInt()
    } catch (error: NumberFormatException) {
        return 0
    }
}
