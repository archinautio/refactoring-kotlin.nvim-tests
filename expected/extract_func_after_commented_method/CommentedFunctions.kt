package demo

// Prints a greeting.
fun commentedGreeting() {
    println("Hello")
}

fun uncommentedFarewell() {
    println("Goodbye")
    println("See you")
}

class Notifier {
    // Sends the first notice.
    fun firstNotice() {
        println("First")
    }

    private fun sendSecond() {
        println("Second")
        println("Done")
    }

    fun secondNotice() {
        sendSecond()
    }
}
