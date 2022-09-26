#import "Basic";

main :: () {
  // Check if a value var is not 0:
    var := 3.14;
    print("%\n", !var); // => false
    if var {
        print("var is not 0\n"); // => var is not 0
	}

    count := 7;
	if !count exit;    // if count is 0, stop

  // test on empty string:
    str := "Jai";
    if str  print("str is not empty\n");  // => str is not empty
    str = "";   // empty string
    if !str  print("str is empty\n");  // => str is empty

  // pointers:
    ptr: *int;
    print("%\n", ptr); // => null
    if !ptr print("This is a null pointer\n"); // => This is a null pointer
}