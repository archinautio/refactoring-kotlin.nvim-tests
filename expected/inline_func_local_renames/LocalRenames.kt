package demo

fun useDescribe() {
    val base = 10
    val message = "caller's"
    val message1 = if (base > 10) "item is big" else "item is small"
    println(message1)
    val n = base * 2
    val message2 = if (n > 10) "$message is big" else "$message is small"
    println(message2)
    println(message)
}
