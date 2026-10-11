package demo

class Shop(val name: String, private val secret: Int) {
    var total = 0

    fun price(n: Int): Int {
        return this.total + n * fee()
    }

    fun fee() = 2

    fun hidden() = secret + 1

    fun internalUse(): Int {
        return price(3) + hidden()
    }
}

fun getShop() = Shop("main", 1)

fun String.shout() = this.uppercase() + "!"

object Utils {
    fun twice(x: Int) = x * 2
}

fun useMethods(shop: Shop?, s: Shop) {
    val a = s.price(5)
    val b = getShop().price(1)
    val text = "Hi ${s.name}"
    println(text)
    println(text)
    val c = "hey".shout()
    val d = Utils.twice(4)
    val e = shop?.price(2)
    val f = s.hidden()
    println("$a $b $c $d $e $f")
}
