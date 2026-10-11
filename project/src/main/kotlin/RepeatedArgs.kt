package demo

fun twice(x: Int) = x + x

fun useTwice() {
    val base = 10
    val a = twice(base)
    val b = twice(compute())
    val c = twice(x = base + 1)
    println("$a $b $c")
}
