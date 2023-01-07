#import "Basic";

swap :: (a: Code, b: Code) #expand {
  t := (#insert a);
  (#insert a) = (#insert b);
  (#insert b) = t;
}

main :: () {
    a, b := 3, 5;
    print("Pre-swap:  a is %, b is %\n", a, b);
    swap(a, b);    // (2)
    print("Post-swap: a is %, b is %\n", a, b);
}

/*
Pre-swap:  a is 3, b is 5
Post-swap: a is 5, b is 3
*/