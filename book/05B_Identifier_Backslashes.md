# 5B - Identifier Backslashes

This feature is illustrated here (See *5B.ident_back.jai* :)

```c++
#import "Basic";

main :: () {
    current_time: float64;
    last\  _time: float64;    // (1)

    hel\ lo := 5;
    print("%\n", hello);      // => 5
}
```

As you see in line (1)n a \ with a number of spaces can be inserted into an identifier, in order to line up names in code (for example: for variables with similar endings but different starts).  
This increases code readability, but makes searching on variable name harder.
