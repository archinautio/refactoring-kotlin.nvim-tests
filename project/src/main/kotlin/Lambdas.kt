package demo

fun loud(n: Int): Int {
    println("loud $n")
    return n * 10
}

fun useLambdas(xs: List<Int>) {
    val a = xs.map { loud(it) }
    val b = xs.map { x ->
        loud(x) + 1
    }
    println("$a $b")
}
