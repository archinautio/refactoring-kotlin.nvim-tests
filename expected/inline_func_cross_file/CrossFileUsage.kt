package demo

fun useDiscount(amount: Int) {
    val reduced = amount - amount * 10 / 100
    println(amount - amount * 20 / 100 + reduced)
}
