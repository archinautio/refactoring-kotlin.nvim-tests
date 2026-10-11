package demo

fun classify(n: Int, label: String) {
    if (n > 10) {
        println("$label is big")
    } else {
        println("$label is small")
    }
}

class Reporter {
    fun report(value: Int) {
        val name = "value"
        classify(value, name)
        println("done")
    }
}
