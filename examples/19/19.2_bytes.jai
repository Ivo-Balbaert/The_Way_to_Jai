#import "Basic";
#import "String"; // for is_any

main :: () {
    print("%\n", to_upper(#char "a")); // => 65 - ASCII value of 'A'
    print("%\n", to_lower(#char "A")); // => 97 - ASCII value of 'a'
    print("%\n", is_digit(#char "7")); // => true
    print("%\n", is_digit(#char "X")); // => false
    print("%\n", is_alpha(#char "i")); // => true
    print("%\n", is_alnum(#char "9")); // => true
    print("%\n", is_space(#char " ")); // => true
    print("%\n", is_space(#char "\t")); // => true
    print("%\n", is_any(#char "l", "Hello!")); // => true
}