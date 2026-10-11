package demo

class Store {
    fun price(): Int {
        val base = 10
        val total = base * 2
        return total
    }

    fun name() = "shop"
}

fun useLast() {
    val v = last(3)
    println(v)
}

fun last(k: Int) = k + 1
