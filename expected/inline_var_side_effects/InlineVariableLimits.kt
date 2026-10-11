package demo

fun nextId(): Int = 7

fun inlineSideEffects() {
    println((nextId()))
    println((nextId()) + 1)
}

fun inlineInTemplate(price: Int) {
    val total = price * 2
    println("Total: $total")
}

fun inlineReassigned() {
    var count = 1
    count += 1
    println(count)
}

class Counter {
    val start = 10
    fun next() = start + 1
}

fun useCounter(counter: Counter) = counter.start

fun inlineParameter(amount: Int) {
    println(amount)
}
