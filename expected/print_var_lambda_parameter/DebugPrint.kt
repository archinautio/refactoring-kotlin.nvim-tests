package demo

// Debug prints: print_var, print_loc and print_exp.

fun orderTotal(prices: List<Int>, discount: Int): Int {
    var total = 0
    for (price in prices) {
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
        
// __PRINT_VAR_START
        println("┆shippingLabels#(anon)┆ ╎name╎ ┊1┊: $name")// __PRINT_VAR_END
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

fun deliveryNote(orderId: Int): String {
    val `delivery note` = "Order $orderId"
    return `delivery note`
}
