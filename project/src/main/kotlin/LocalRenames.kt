package demo

fun describe(n: Int, label: String) {
    val message = if (n > 10) "$label is big" else "$label is small"
    println(message)
}

fun useDescribe() {
    val base = 10
    val message = "caller's"
    describe(base, "item")
    describe(base * 2, message)
    println(message)
}
