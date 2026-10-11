package demo

class Store {
    fun price(): Int {
        val base = 10
        val total = withVat(base)
        return total
    }

    fun withVat(amount: Int): Int {
        return amount * 2
    }

    fun name() = "shop"
}

fun useLast() {
    val v = 3 + 1
    println(v)
}
