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
    val v = last(3)
    println(v)
}

fun last(k: Int) = k + 1
