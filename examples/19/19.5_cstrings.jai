#import "Basic";
#import "String";

main :: ()  {
    str1 := "London";
    // C string manipulation functions:
    strc := to_c_string(str1);
    print("the C string is %\n", strc); // => the C string is 15f_e30c_5710
    print("the C string is %\n", << strc); // => the C string is 76 // ASCII value of 'L'
    print("Its length is %\n", c_style_strlen(strc)); // => Its length is 6
    print("the original string is %\n", to_string(strc)); // => the original string is London
}