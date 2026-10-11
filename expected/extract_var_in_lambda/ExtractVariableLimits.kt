package demo

fun repeatedExpression(width: Int, height: Int) {
    println(width * height)
    println(width * height + 1)
}

fun otherScope(width: Int, height: Int) = width * height

fun conditionalExpression(items: List<Int>?, limit: Int) {
    val ok = items != null && items.size > limit
    println(ok)
}

fun lambdaExpression(items: List<Int>) {
    items.forEach { val doubled = it * 2
    println(doubled) }
}

fun expressionBody(width: Int) = width * 3
