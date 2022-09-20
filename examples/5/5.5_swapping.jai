#import "Basic";

main :: () {
    n := 2;
    m := 3;
  // swap doesn't work like you would expect:
  // n, m = m, n;                        
  // print("n is % and m is %\n", n, m); // => n is 3 and m is 3

    s, p := "abc", 13;
  // this gives an error:
  // s, p = p, s; // => Error: Type mismatch. Type wanted: string; type given: s64.  

  // But there our swapping procedure in Basic:
    Swap(*n, *m);
    print("n is % and m is %\n", n, m); // => n is 3 and m is 2

    n2 := 2; m2 := 3;
    n2, m2 = swap(n2, m2);
    print("n2 is % and m2 is %\n", n2, m2); // => n2 is 3 and m2 is 2       
}

/*
n is 3 and m is 2
n2 is 3 and m2 is 2
*/