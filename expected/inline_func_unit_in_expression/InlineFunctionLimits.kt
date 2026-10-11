package demo

fun sumAll(vararg numbers: Int): Int {
    return numbers.sum()
}

fun useSumAll() {
    println(sumAll(1, 2, 3))
}

fun clamp(value: Int): Int {
    if (value < 0) {
        return 0
    }
    return value
}

fun useClamp() {
    val clamped = clamp(-5)
    println(clamped)
}

fun area(width: Int, height: Int = width): Int {
    return width * height
}

fun useArea() {
    val square = area(3)
    println(square)
}

fun isEven(n: Int) = n % 2 == 0

fun useIsEven(values: List<Int>) {
    println(values.filter(::isEven))
    println(isEven(4))
}

fun String.exclaim() = uppercase() + "!"

fun useExclaim() {
    println("hi".exclaim())
}

open class Animal {
    val sound = "woof"
}

class Dog : Animal() {
    fun speak() = sound + "!"
}

fun useDog(dog: Dog) {
    println(dog.speak())
}

class Box(val size: Int) {
    fun scaled(factors: List<Int>) = factors.map { size -> size * 2 }
}

fun useBox(box: Box) {
    println(box.scaled(listOf(1, 2)))
}

fun greetAll(name: String) {
    val greeting = "Hello $name"
    println(greeting)
}

fun useGreetAll() {
    greetAll("Ann")
    listOf(1).forEach {
        val greeting = it
        println(greeting)
    }
}

fun useLogValue() {
    println(1)
    val logged = listOf(Unit)
    println(logged)
}

fun applyTwice(value: Int, transform: (Int) -> Int): Int {
    return transform(transform(value))
}

fun useApplyTwice() {
    val result = applyTwice(3) { it + 1 }
    println(result)
}

fun printTwoLines(n: Int) {
    println(n)

    println(n + 1)
}

fun usePrintTwoLines() {
    printTwoLines(2)
}

fun doNothing() {}

fun useDoNothing() {
    doNothing()
}
