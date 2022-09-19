#import "Basic";

// #run main();

main :: ()  {
  a := "Happy";
  print("a's length is %\n", a.count); // => a's length is 5
  print("a's data starts at % with value %\n", a.data, << a.data); 
  // => a's data starts at 7ff7_d2ed_2007 with value 72
  
  ch := "世界";
  print("ch's length is %\n", ch.count); // => ch's length is 6
  
  multi_line_string := #string END_STRING
  This
  is
  a
  multi-line
  string.
  END_STRING;

  print(multi_line_string);
  /*
   This
  is
  a
  multi-line
  string.
  */

  // implicit cast of string to bool:
  str: string = "Hello."; // same as: str := "Hello.";
  if str {
    print("string is not empty!"); // => string is not empty!
  } else {
    print("string is empty!");
  }

  print(str); // => Hello.
  print("The 5th character of str is: % \n", str[5]); // => The 5th character of str is: 46
  // Bounds checking:
  // print("The 99th character of str is: % \n", str[99]); // => 
/*
   Array bounds check failed. (The attempted index is 99, but the highest valid index is 5). Site is D:/Jai/The Book of Jai/4_Working_with_Strings/code/1_strings.jai:42.
Panic.
*/

  // Looping over the characters in a string:
  for i: 0..str.count-1 {
        print("% -", str[i]);
  } // => 72 -101 -108 -108 -111 -46 -
  for i: 0..ch.count-1 {
        print("% -", ch[i]);
  } // => 228 -184 -150 -231 -149 -140

  // sprint:
  b := "Resounding ";
  newstr := sprint("% %!\n", b, ch);
  print("%\n", newstr); // => Resounding 世界!
  newstr2 := tprint("% %!\n", b, ch);
  print("%\n", newstr2); // => Resounding 世界!

  free(str);
}
