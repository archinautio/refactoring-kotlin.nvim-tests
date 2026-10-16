package demo

// A labelled loop: the label isn't part of the loop's node.

fun firstOverLimit(prices: List<Int>, limit: Int): Int {
    var found = -1
    search@ for (price in prices.sorted()) {
        
// __PRINT_VAR_START
        println("┆firstOverLimit#for┆ ╎price╎ ┊1┊: $price")// __PRINT_VAR_END
        if (price > limit) {
            found = price
            break@search
        }
    }
    return found
}
