package demo

fun compute(): Int = 42

fun addTax(price: Int, rate: Int = 2): Int {
    return price * rate
}

fun useAddTax(price: Int) {
    val base = 10
    val a = addTax(base, 3)
    val b = addTax(base)
    val c = addTax(rate = 4, price = base)
    val d = addTax(compute(), 3)
    val e = addTax(compute(), compute())
    val f = addTax(base + 1)
    val g = addTax(
        base,
        3,
    )
    addTax(price, 5)
    println(listOf(a, b, c, d, e, f, g))
}
