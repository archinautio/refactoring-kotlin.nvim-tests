package demo

fun discount(amount: Int, percent: Int = 10): Int {
    return amount - amount * percent / 100
}
