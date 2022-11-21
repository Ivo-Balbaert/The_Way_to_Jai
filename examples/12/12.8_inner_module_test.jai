#import "Basic";
#import "TestScope";

main :: () {
    s1 := Struct1.{number = 42}; // (1) Error: Undeclared identifier 'Str'.
    print("%", s1);     // => {42}
}