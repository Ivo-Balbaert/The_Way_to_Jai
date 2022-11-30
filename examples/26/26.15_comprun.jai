#import "Basic";

comprun :: (x: $T) {  
    #run print("Compiling 'comprun' for T == %.\n", T);  // (1) 
    print("The value of x is %, of type %.\n", x, T);    // (2) 
}
 
main :: () {
    a: u8 = 5;
    b: u8 = 11;    
    comprun(a);   // (3)
    comprun(b);
    comprun(a * 3 + b);

    comprun(1.1);  // (4)
    comprun(3.33); // (5)
    comprun("Hello, Sailor!"); // (6)

    comprun(b - a);  // (7) 
}

/*
Compiling 'comprun' for T == u8.
Compiling 'comprun' for T == string.
Compiling 'comprun' for T == float32.
Linker ...
After compilation...
The value of x is 5, of type u8.
The value of x is 11, of type u8.
The value of x is 26, of type u8.
The value of x is 1.1, of type float32.
The value of x is 3.33, of type float32.
The value of x is Hello, Sailor!, of type string.
The value of x is 6, of type u8.
*/