package demo

fun extractTwoResults() {
    val first = 1
    val second = 2
    println(first + second)
}

private fun addFive(counter: P): P {
    counter += 5

    return counter
}

fun extractReassigned() {
    var counter = 0
    val counter = addFive(counter)
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

fun extractInLambda(values: List<Int>) {
    values.forEach { value ->
        val doubled = value * 2
        println(doubled)
    }
}
