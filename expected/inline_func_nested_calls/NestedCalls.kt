package demo

fun noisy(n: Int): Int {
    println("noisy $n")
    return n + 1
}

fun useNested(xs: List<Int>, flag: Boolean) {
    val base = 10
    println(base / 2)
    val a = (base + 1) / 2 * 3
    val b = 4 / 2 + compute() / 2
    println(noisy(base) + noisy(base * 2))
    var c = 0
    c = noisy(base / 2)
    println((base / 2).toString())
    val d = xs.map { it / 2 }
    println("$a $b $c $d")
}

fun useConditional(flag: Boolean): Int {
    val e = if (flag) noisy(1) else 0
    return e
}

fun exprBody() = noisy(5)
