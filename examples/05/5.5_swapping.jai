#import "Basic";

main :: () {
    n := 2;
    m := 3;
    n, m = m, n;                        
    print("n is % and m is %\n", n, m); // => n is 3 and m is 2

    s, p := "abc", 13;
  // this gives an error:
  // s, p = p, s; // => Error: Type mismatch. Type wanted: string; type given: s64.  

  // There is a swapping procedure in module Basic:
    n2 := 2; m2 := 3;
    swap(*n2, *m2);
    print("n2 is % and m2 is %\n", n2, m2); // => n2 is 3 and m2 is 2       
}

/*
n is 3 and m is 2
n is 2 and m is 3
n2 is 3 and m2 is 2
*/