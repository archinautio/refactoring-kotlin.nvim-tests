package demo

fun useLogAndScale(value: Int) {
    val value1 = compute()
    println("scaling $value1")
    if (3 > 1) {
        println("by 3")
    }
    val scaled = value1 * 3
    println("scaling $value")
    if (scaled > 1) {
        println("by $scaled")
    }
    val other = value * scaled
    println(other)
}
