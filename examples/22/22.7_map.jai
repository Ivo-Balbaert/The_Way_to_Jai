#import "Basic";

map :: (array: [] $T, f: (T) -> $R) -> [] R {   // (1)
    result: [] R;
    result.count = array.count;
    result.data = alloc(result.count * size_of(R)); 
    for array result[it_index] = f(it);
    return result;
}

square :: (n: int) -> int { return n*n; }       // (2)

main :: () {
    N :: 5;
    a: [N] int;
    for 0..N-1 a[it] = it + 1;
    print("a is %\n", a); // => a is [1, 2, 3, 4, 5]

    b := map(a, square);                        // (3)
    print("b is %\n", b); // => b is [1, 4, 9, 16, 25]

    c := map(a, x => x * x);                    // (4)
    print("c is %\n", c); // => c is [1, 4, 9, 16, 25]

    d := map(a, x => -x);                    
    print("d is %\n", d); // => d is [-1, -2, -3, -4, -5]

    e := map(a, x => x + 100);                    
    print("e is %\n", e); // => e is [101, 102, 103, 104, 105]
}


