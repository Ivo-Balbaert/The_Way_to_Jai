#import "Basic";

old_function :: () #deprecated "please use new_function :: () instead" {}

new_function :: () {}


main :: ()  {
    old_function(); 
    // => Warning: This procedure is deprecated. Note: "please use new_function :: () instead"
}
