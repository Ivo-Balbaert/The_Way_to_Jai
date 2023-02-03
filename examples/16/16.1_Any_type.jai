#import "Basic";

main :: () {
    x: Any = 3.0;  
    print("x contains this float: %\n", << cast(*float) x.value_pointer); // (0A)
    // => x contains this float: 3
    x = "foo";
    print("now x contains this string: %\n", << cast(*string) x.value_pointer); // (0B)
    // => now x contains this string: foo

    n: s32 = 5;
    a: Any = n;
    print("a's Type_Info is: %\n", << a.type); // (1) => a's Type_Info is: {INTEGER, 4}
    print("a's type is: %\n", a.type.type); // => a's type is: INTEGER
    print("a's value_pointer is: %\n", a.value_pointer); // => c3_2d9c_f844
    print("The value inside a's value_pointer is: %\n", << cast(*s32) a.value_pointer); // (0C)
    // => The value inside a's value_pointer is: 5

    if  a.type.type == {        // (2)
        case Type_Info_Tag.FLOAT;     print("a is a float\n");
        case Type_Info_Tag.INTEGER;   print("a is an int\n"); // => a is an int
    }
}