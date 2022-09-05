#import "Basic";
#import "Random";

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
    m := 8;
    print("%\n", (m & 1) == 0); // => true

    // Formatting:
    i := 108;
    print("% ", formatInt(i, minimum_digits=2)); // => 108
    print("% ", formatInt(i, base=16, minimum_digits=2)); // => 6c
    j := 7;
    print("% ", formatInt(j, minimum_digits=2)); // => 07
    
    f1 := 2.25193;
    f2 := 3.1400;
    LEADING_WIDTH :: 4;
    print("% \n", formatFloat(f1, width=LEADING_WIDTH, trailing_width=3, zero_removal=.NO)); // => 2.252
    print("% \n", formatFloat(f2, width=1, trailing_width=3, zero_removal=.NO)); // => 3.140
    print("% \n", formatFloat(f2, width=1, trailing_width=3, zero_removal=.YES)); // => 3.14

    // Random numbers: 
    print("A random integer: %\n", random_get()); // => 1137526400306752306
    print("A random float between 0 and 1: %\n", random_get_zero_to_one()); // => 0.709799
    print("A random float between 0 and 100: %\n", random_get_within_range(0, 100)); // => 75.796494
}