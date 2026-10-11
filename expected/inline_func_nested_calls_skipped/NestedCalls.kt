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
    println("noisy $base")
    val n = base * 2
    println("noisy $n")
    println(base + 1 + (n + 1))
    var c = 0
    val n1 = half(base)
    println("noisy $n1")
    c = n1 + 1
    println(half(base).toString())
    val d = xs.map { half(it) }
    println("$a $b $c $d")
}

fun useConditional(flag: Boolean): Int {
    val e = if (flag) noisy(1) else 0
    return e
}

fun exprBody() = noisy(5)
