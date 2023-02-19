#import "Basic";
#import "Compiler";

// #expand makes this a "macro" so it can
// access variables in its surrounding scope
do_stuff :: (c: Code) #expand {
  // splat the code four times
  #insert c;
  #insert c;
  #insert c;
  #insert c;
}

main :: () {
    n := 3;

    // generate a snippet of code
    c : Code : #code { n *= 3; };

    // at compile-time: expand do_stuff macro
    // at run-time: execute code four times
    do_stuff(c);

    print("%\n", n); // => 243
}