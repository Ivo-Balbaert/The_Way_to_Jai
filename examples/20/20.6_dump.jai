#import "Basic";

add :: (n: int, m: int) -> int #dump {      // (1)
    return n + m;
}
    
main :: () {
    print("Adding 2 and 3 gives %\n", add(2, 3)); // => Adding 2 and 3 gives 5
}

/*
Disassembly of 'add' at d:/Jai/testing/test.jai:3
- Stack size 0

-------- Basic Block 0 -------- defines v4-20 --------

           (no dominating)

   0|        binop   v4, v1 + v2
   1| return_value   v4 -> 1
   2|       return
   */