package demo

// A labelled loop: the label isn't part of the loop's node.

fun firstOverLimit(prices: List<Int>, limit: Int): Int {
    var found = -1
    search@ 
// __PRINT_VAR_START
    println("┆firstOverLimit┆ ╎prices╎ ┊1┊: $prices")// __PRINT_VAR_END
    for (price in prices.sorted()) {
        if (price > limit) {
            found = price
            break@search
        }
    }
    return found
}
