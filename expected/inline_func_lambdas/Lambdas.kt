package demo

fun loud(n: Int): Int {
    println("loud $n")
    return n * 10
}

fun useLambdas(xs: List<Int>) {
    val a = xs.map { loud(it) }
    val b = xs.map { x ->
        println("loud $x")
        x * 10 + 1
    }
    println("$a $b")
}
