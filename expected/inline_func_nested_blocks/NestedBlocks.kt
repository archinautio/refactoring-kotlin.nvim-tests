package demo

class Reporter {
    fun report(value: Int) {
        val name = "value"
        if (value > 10) {
            println("$name is big")
        } else {
            println("$name is small")
        }
        println("done")
    }
}
