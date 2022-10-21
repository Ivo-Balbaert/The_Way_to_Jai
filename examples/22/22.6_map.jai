
#import "Basic";

map :: (array: [] $T, f: (T) -> $R) -> [] R {
    result: [] R;
    result.count = array.count;
    result.data = alloc(result.count * size_of(R)); 
    for array result[it_index] = f(it);
    return result;
}

square :: (n: int) -> int { return n*n; }

main :: () {
    N :: 5;
    a: [N] int;
    for 0..N-1 a[it] = it+1;
    for a print("a[%] = %\n", it_index, it);

    b := map(a, square);
    for b print("b[%] = %\n", it_index, it);
}

/*
a[0] = 1
a[1] = 2
a[2] = 3
a[3] = 4
a[4] = 5
b[0] = 1
b[1] = 4
b[2] = 9
b[3] = 16
b[4] = 25
*/

