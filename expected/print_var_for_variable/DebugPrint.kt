package demo

// Debug prints: print_var, print_loc and print_exp.

fun orderTotal(prices: List<Int>, discount: Int): Int {
    var total = 0
    for (price in prices) {
        
// __PRINT_VAR_START
        println("┆orderTotal#for┆ ╎price╎ ┊1┊: $price")// __PRINT_VAR_END
        total += price
    }
    var remaining = discount
    while (remaining > 0) {
        remaining -= 1
    }
    var attempts = 0
    do {
        attempts += 1
    } while (attempts < discount)
    if (total > discount) {
        total -= discount
    } else {
        total = 0
    }
    return total
}

fun shippingLabels(names: List<String>): List<String> {
    val labels = mutableListOf<String>()
    names.forEach { name ->
        labels.add(name.uppercase())
    }
    fun label(city: String): String {
        return "To: $city"
    }
    labels.add(label("Paris"))
    return labels
}

fun receipt(amount: Int, tip: Int): String {
    val summary = "Total: $" + (amount + tip)
    return summary
}
