package demo

class Calculator {
    fun total(prices: List<Int>, taxRate: Double): Double {
        val subtotal = prices.sum()
        val tax = subtotal * taxRate
        println("Subtotal: $subtotal")
        val result = subtotal + tax
        return result
    }
}

fun square(x: Int): Int {
    return x * x
}

fun greet(name: String) {
    val message = "Hello, $name"
    println(message)
}

fun main() {
    val base = 4
    val squared = square((base * 2))
    println(squared + (base * 2))
    greet("Kotlin")
    println(Calculator().total(listOf(1, 2, 3), 0.21))
}
