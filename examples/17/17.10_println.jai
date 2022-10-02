#import "Basic";

main :: () {
    n := 7;
    m := 42;
    println("Hello, world!"); // => Hello, world!
    println(1);               // => 1
    println("% %", n, m);     // => 7 42
    println("The end.");      // => The end
}

println :: inline (arg: Any) {      
    print("%\n", arg); // print knows the type of arg
}

println :: inline (msg: string, args: ..Any) {   // (2)
    print(msg, ..args);
    print("\n");
}

// =>
// Hello, world!
// 1
// 7 42
// The end.