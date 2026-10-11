package demo

fun repeatedExpression(width: Int, height: Int) {
    println(width * height)
    println(width * height + 1)
}

fun otherScope(width: Int, height: Int) = width * height

fun conditionalExpression(items: List<Int>?, limit: Int) {
    val tooMany = items.size > limit
    val ok = items != null && tooMany
    println(ok)
}

fun lambdaExpression(items: List<Int>) {
    items.forEach { println(it * 2) }
}

fun expressionBody(width: Int) = width * 3
