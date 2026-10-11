package demo

class Calculator {
    fun total(prices: List<Int>, taxRate: Double): Double {
        val subtotal = prices.sum()
        val taxed = subtotal * taxRate
        val tax = taxed
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
    val doubled = base * 2
    val squared = square(doubled)
    println(squared + doubled)
    greet("Kotlin")
    println(Calculator().total(listOf(1, 2, 3), 0.21))
}
