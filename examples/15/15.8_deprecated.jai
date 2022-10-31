#import "Basic";

old_function :: () #deprecated "please use the new_function :: () instead" {

}

new_function :: () {

}


main :: ()  {
    old_function(); 
    // => Warning: This procedure is deprecated. Note: "please use the new_function :: () instead"
}
