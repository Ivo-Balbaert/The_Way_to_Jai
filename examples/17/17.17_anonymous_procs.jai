#import "Basic";

main :: () {
    () {                            // (1)
      if 2 == {
         case 2;    print("one\n");
         case 3;    print("two");
         case 4;    print("four");
      }
    }();                            // (1B) => one

    anproc := () {                  // (1C)
      if 2 == {
         case 2;    print("one in anproc\n");
         case 3;    print("two");
         case 4;    print("four");
      }
    };  
    anproc();                       // (1D) => one in anproc

    a := () -> int {                // (2)
      if 2 == {
         case 2; return 1;
         case 3; return 2;
         case 4; {
            // do some stuff
         }
      }
      return 0;
    }();                            // (2B)
    print("a is %\n", a);  // => a is 1

    s := 3; 
    b := (s : int) -> int {         // (3)
       if s == {
            case 2; return 1;
            case 3; return 2;
            case 4; {
                // do some stuff
            }
            case;
        }
        return 0;
   }(s);                            // (3B)
   print("b is %\n", b);  // => b is 2
}

/*

*/