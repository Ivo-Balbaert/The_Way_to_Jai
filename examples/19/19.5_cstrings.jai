#import "Basic";
#import "String";

main :: ()  {
    str1 := "London";
    c_string := to_c_string(str1); // c_string is 0 terminated
    defer free(c_string); // (1)
    print("the C string is %\n", c_string); // => the C string is 1ad_d867_56f0
    print("the C string is %\n", << c_string); // => the C string is 76 // ASCII value of 'L'
    print("Its length is %\n", c_style_strlen(c_string)); // => Its length is 6
    // alternative way:
    len := 0;
    while << c_string {
        len += 1;
        c_string += 1; // (2) pointer arithmetic
    }
    print("The length of c_string is %\n", len); // => The length of c_string is 6
    print("the original string is %\n", to_string(c_string)); 
    // => the original string is London
}