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

    fun secondNotice() {
        println("Second")
        println("Done")
    }
}
