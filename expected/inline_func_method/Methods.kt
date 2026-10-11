package demo

class Shop(val name: String, private val secret: Int) {
    var total = 0

    fun price(n: Int): Int {
        return this.total + n * fee()
    }

    fun fee() = 2

    fun label(prefix: String): String {
        val text = "$prefix $name"
        println(text)
        return text
    }

    fun hidden() = secret + 1

    fun internalUse(): Int {
        return this.total + 3 * fee() + hidden()
    }
}

fun getShop() = Shop("main", 1)

fun String.shout() = this.uppercase() + "!"

object Utils {
    fun twice(x: Int) = x * 2
}

fun useMethods(shop: Shop?, s: Shop) {
    val a = s.total + 5 * s.fee()
    val shop1 = getShop()
    val b = shop1.total + 1 * shop1.fee()
    println(s.label("Hi"))
    val c = "hey".shout()
    val d = Utils.twice(4)
    val e = shop?.price(2)
    val f = s.hidden()
    println("$a $b $c $d $e $f")
}
