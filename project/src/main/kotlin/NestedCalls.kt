package demo

fun half(n: Int) = n / 2

fun noisy(n: Int): Int {
    println("noisy $n")
    return n + 1
}

fun useNested(xs: List<Int>, flag: Boolean) {
    val base = 10
    println(half(base))
    val a = half(base + 1) * 3
    val b = half(4) + half(compute())
    println(noisy(base) + noisy(base * 2))
    var c = 0
    c = noisy(half(base))
    println(half(base).toString())
    val d = xs.map { half(it) }
    println("$a $b $c $d")
}

fun useConditional(flag: Boolean): Int {
    val e = if (flag) noisy(1) else 0
    return e
}

fun exprBody() = noisy(5)
