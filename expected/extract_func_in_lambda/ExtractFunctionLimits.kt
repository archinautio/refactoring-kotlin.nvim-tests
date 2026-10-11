package demo

fun extractTwoResults() {
    val first = 1
    val second = 2
    println(first + second)
}

fun extractReassigned() {
    var counter = 0
    counter += 5
    println(counter)
}

fun extractExpression(width: Int, height: Int): Int {
    val area = width * height
    return area
}

fun extractWithReturn(value: Int): Int {
    if (value < 0) {
        return 0
    } // end of check
    return value * 2
}

private fun printDouble(value: P) {
    val doubled = value * 2
    println(doubled)
}

fun extractInLambda(values: List<Int>) {
    values.forEach { value ->
        printDouble(value)
    }
}
