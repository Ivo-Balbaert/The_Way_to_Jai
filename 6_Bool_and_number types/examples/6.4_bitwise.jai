#import "Basic";

main :: () {
    // Bitwise operators:
    ab := 0b00_01;
    al := ab << 1;
    print("al is: %\n", al); // => al is: 2
    ar := al >> 1;
    print("ar is the same as ab: %\n", ar == ab); // => ar is the same as ab: true
    alr := ab <<< 1;
    print("alr is: %\n", alr); // => alr is: 2

    print("11001100 & 10001000 is %\n", 0b11001100 & 0b10001000); // => 136
    print("11001100 # 10000011 is %\n", 0b11001100 | 0b10000011); // => 207
    
    // test if even:
    n := 8;
    print("%\n", n % 2 == 0); // => true
    print("%\n", n & 1 == 0); // => true
}

/*
al is: 2
ar is the same as ab: true
alr is: 2
11001100 & 10001000 is 136
11001100 # 10000011 is 207
true
true
*/