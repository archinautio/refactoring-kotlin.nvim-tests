package demo

fun compute(): Int = 42

fun useAddTax(price: Int) {
    val base = 10
    val a = base * 3
    val b = base * 2
    val c = base * 4
    val d = compute() * 3
    val price1 = compute()
    val rate = compute()
    val e = price1 * rate
    val f = (base + 1) * 2
    val g = base * 3
    println(listOf(a, b, c, d, e, f, g))
}
