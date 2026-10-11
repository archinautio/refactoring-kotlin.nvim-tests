package demo

fun useDiscount(amount: Int) {
    val reduced = discount(amount)
    println(discount(amount, 20) + reduced)
}
