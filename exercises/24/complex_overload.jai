#import "Basic";

Complex :: struct { 
        a, b: float;
}

operator + :: (x: Complex, y: Complex) -> Complex {
    r: Complex = ---;
    r.a = x.a + y.a;
    r.b = x.b + y.b;

    return r;
}

operator * :: (x: Complex, y: Complex) -> Complex {
    r: Complex = ---;
    r.a = x.a*y.a - x.b*y.b;
    r.b = x.a*y.b + y.a*x.b;

    return r;
}

main :: () {
    a := Complex.{1,1};
    b := Complex.{2,-2};
    print("a + b is: %\n", a + b); // => a + b is: {3, -1}
    print("a * b is: %\n", a * b); // => a * b is: {4, 0}

    a *= b;
    a += b;
    print("a is: %\n", a); // => a is: {6, -2}
}
