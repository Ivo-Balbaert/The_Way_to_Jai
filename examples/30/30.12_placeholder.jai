#import "Basic";

#placeholder TRUTH;                     // (1)

#run {
   #import "Compiler";
   options := get_build_options();
   add_build_string("TRUTH :: true;", -1);  // (2)
}

main :: () {
   print("TRUTH is %, is it a constant? %\n", TRUTH, is_constant(TRUTH));
   // => TRUTH is true, is a constant? true
}