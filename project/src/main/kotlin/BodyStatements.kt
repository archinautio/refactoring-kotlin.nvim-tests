package demo

fun logAndScale(value: Int, factor: Int): Int {
    println("scaling $value")
    if (factor > 1) {
        println("by $factor")
    }
    return value * factor
}

fun useLogAndScale(value: Int) {
    val scaled = logAndScale(compute(), 3)
    val other = logAndScale(value, scaled)
    println(other)
}
