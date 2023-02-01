#import "Basic";
#import "TestScope";

main :: () {
    s1 := Struct1.{number = 42}; 
    print("%", s1);     // => {42}
}