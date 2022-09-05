#import "Basic";
#import "Random";

main :: () {
    // 6.2.2 - arithmetic operations:
    score1 := 42;
    score2 := 13;
    total_score := score1 + score2;
    print("total_score is %\n", total_score); // => total_score is 55

    print("8 / 3 is %\n", 8 / 3); // => 8 / 3 is 2
    print("8.0 / 3 is %\n", 8.0 / 3); // => 8.0 / 3 is 2.666667
    print("8 %% 3 is %\n", 8 % 3); // => 8 % 3 is 2
    
    // dividing by zero
    // print("8 / 0 is %\n", 8 / 0); // => Error: Division by zero.
    // print("8.0 / 0 is %\n", 8.0 / 0); // => // => Error: Division by zero.
    z := 0;
    // print("8 / z is %\n", 8 / z); // => Runtime error, program stops after this line

    // Mixing of different types:
    a: s32 = -5_069_105;
    b: u8  = 10;
    c: u16 = 50;
    d := a + b; // => d is -5068898
    print("d is %\n", d); // => 
    // total_score *= 3.14; // Error: Number mismatch. Type wanted: s64; type given: float32.
    message := "YOU WON!";
    // score3 := total_score + message; 
    // => Error: Type mismatch between the arguments of binary operator + (left type: s64; right type: string).

    // Size of integers:
    // This number won't fit into 16 bits
    // i: s16 = 80000;  // => Error: Loss of information (trying to fit 64 bits into 16 bits). Can't do this without an explicit cast. Type wanted: s16; type given: s64.
    // -1 is signed, so it is out of range of what a u32 can store. 
    // j: u32 = -1; // => Error: Number signedness mismatch. Type wanted: u32; type given: s64.    
    // b = c; // Error: Loss of information (trying to fit 16 bits into 8 bits). Can't do this without an explicit cast. Type wanted: u8; type given: u16.

    // Casting:
    b = cast(u8) c;
    b = xx c;
    // cast u8 to float works:
    f: float;
    g: u8 = 74;
    f = cast(float) g;
    print("%\n", f); // => 74
    // cast error at runtime:
    // b = cast(u8) a;
    // => Cast bounds check failed.  Number must be in [0, 255]; it was -5069105.  Site is D:/Jai/The Book of Jai/3_Constants_Variables_Types_Operations/code/5_numbers.jai:19. Panic.
    // b = xx a; // => Error
    b = cast, no_check(u8) a;
    print("a is % and b is %\n", a, b); // => a is -5069105 and b is 207
    a, b += 1;
    print("a is % and b is %\n", a, b); // =>  is -5069104 and b is 208
 
    // Casting float to integer type truncates:
    pi := 3.14; 
    e: u8;
    e = cast(u8) pi;
    e = xx pi;
    print("e is %\n", e); // => e is 3

    // Precedence
    count := 10;
    print("%\n", count/2 - 1);   // => 4
    print("%\n", (count/2) - 1); // => 4
    print("%\n", count/(2 - 1)); // => 10

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