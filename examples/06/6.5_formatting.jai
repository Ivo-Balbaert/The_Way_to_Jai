#import "Basic";

main :: () {
    // Formatting:
    i := 108;
    print("% ", formatInt(i, minimum_digits=2)); // => 108
    print("% ", formatInt(i, base=16, minimum_digits=2)); // => 6c
    i2 := 0xFF;
    print("i2 = %\n", formatInt(i2, base=16)); // => i2 = ff
    j := 7;
    print("% ", formatInt(j, minimum_digits=2)); // => 07
    
    f1 := 2.25193;
    f2 := 3.1400;
    LEADING_WIDTH :: 4;
    print("% \n", formatFloat(f1, width=LEADING_WIDTH, trailing_width=3, zero_removal=.NO)); // => 2.252
    print("% \n", formatFloat(f2, width=1, trailing_width=3, zero_removal=.NO)); // => 3.140
    print("% \n", formatFloat(f2, width=1, trailing_width=3, zero_removal=.YES)); // => 3.14

    print("Scientific-notation-formatted float: %, Decimal value: %\n",  
        formatFloat(12342345234.0, mode=.SCIENTIFIC), 12342345234.0);
}

/*
108 6c i2 = ff
07 2.252
3.140
3.14
Scientific-notation-formatted float: 1.234235e+10, Decimal value: 12342345234
*/
