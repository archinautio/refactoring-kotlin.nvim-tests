package demo

// Prints a greeting.
fun commentedGreeting() {
    println("Hello")
}

private fun sayGoodbye() {
    println("Goodbye")
    println("See you")
}

fun uncommentedFarewell() {
    sayGoodbye()
}

class Notifier {
    // Sends the first notice.
    fun firstNotice() {
        println("First")
    }

    fun secondNotice() {
        println("Second")
        println("Done")
    }
}
