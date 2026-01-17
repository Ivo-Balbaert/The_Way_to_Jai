#import "Basic";

main :: () {
    // 6.2.2 - arithmetic operations:
    score1 := 42;
    score2 := 13;
    total_score := score1 + score2;
    print("total_score is %\n", total_score); // => total_score is 55

    print("8 / 3 is %\n", 8 / 3); // => 8 / 3 is 2
    print("8.0 / 3 is %\n", 8.0 / 3); // => 8.0 / 3 is 2.666667
    print("8 \% 3 is %\n", 8 % 3); // => 8 % 3 is 2
    
    // (1) Dividing by zero
    // print("8 / 0 is %\n", 8 / 0); // => Error: Division by zero.
    // print("8.0 / 0 is %\n", 8.0 / 0); // => Error: Division by zero.
    z := 0;
    // print("8 / z is %\n", 8 / z); // => Runtime error, program stops after this line
    /*
    The program crashed. Printing the stack trace:
handle_exception                  c:\jai\modules\Runtime_Support_Crash_Handler.jai:211    
... (skipping OS-internal procedures)
main                              d:\Jai\The_Way_to_Jai\examples\6\6.3_numbers.jai:18 
    */

    // Mixing of different types:
    a: s32 = -5_069_105;
    b: u8  = 10;
    c: u16 = 50;
    d := a + b; 
    print("d is %\n", d); // => d is -5068898
    print("total_score has type %\n", type_of(total_score));
    // => total_score has type s64
    // total_score *= 3.14; // (2) => Error: Number mismatch. Type wanted: s64; type given: float32.
    message := "YOU WON!";
    // score3 := total_score + message; 
    // (3) => Error: Type mismatch between the arguments of binary operator + (left type: s64; right type: string).

    // (4) Size of integers:
    // This number won't fit into 16 bits
    // i: s16 = 80000;  // => Error: Loss of information (trying to fit 64 bits into 16 bits). Can't do this without an explicit cast. Type wanted: s16; type given: s64.
    // -1 is signed, so it is out of range of what a u32 can store. 
    // j: u32 = -1; // => Error: Number signedness mismatch. Type wanted: u32; type given: s64.    
    // b = c; // Error: Loss of information (trying to fit 16 bits into 8 bits). Can't do this without an explicit cast. Type wanted: u8; type given: u16.

    // (5) Casting:
    b = cast(u8) c;
    b = xx c;
    foo: u8 = xx ifx true then #char "." else #char "#";
    // cast u8 to float works:
    f: float;
    g: u8 = 74;
    f = cast(float) g;
    print("%\n", f); // => 74
    // cast error at runtime:
    // b = cast(u8) a;
    // (6) => Cast bounds check failed.  Number must be in [0, 255]; it was -5069105.  Site is D:/Jai/The Book of Jai/3_Constants_Variables_Types_Operations/code/5_numbers.jai:19. Panic.
    // b = xx a; // => Same error
    b = cast, no_check(u8) a;
    print("a is % and b is %\n", a, b); // => a is -5069105 and b is 207
    a, b += 1;
    print("a is % and b is %\n", a, b); // =>  is -5069104 and b is 208
 
    // Casting float to integer type truncates:
    pi := 3.14; 
    e: u8;
    e = cast(u8) pi;
    e = xx pi; // autocast, equivalent of cast above
    print("e is %\n", e); // (7) => e is 3

    // Cast of bool to int:
    e = xx true;
    print("e is %\n", e); // (8A) => e is 1
    e = xx false;
    print("e is %\n", e); // (8B) => e is 0
    // Cast of int to bool:
    b1: bool = cast(bool) 0;
    print("%\n", b1);       // (8C) => false
    b1 = cast(bool) -50;  // same for positive integers
    print("%\n", b1);       // (8D) => true
    
    // (9) Precedence
    count := 10;
    print("%\n", count/2 - 1);   // => 4
    print("%\n", (count/2) - 1); // => 4
    print("%\n", count/(2 - 1)); // => 10
}