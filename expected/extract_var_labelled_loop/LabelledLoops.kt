package demo

// A labelled loop: the label isn't part of the loop's node.

fun firstOverLimit(prices: List<Int>, limit: Int): Int {
    var found = -1
    val sortedPrices = prices.sorted()
    search@ for (price in sortedPrices) {
        if (price > limit) {
            found = price
            break@search
        }
    }
    return found
}
