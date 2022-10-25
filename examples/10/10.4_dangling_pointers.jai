#import "Basic";

main :: () {
  a := New(int);
  print("%\n", a);    // => 14a_f407_6710
  print("%\n", << a); // => 0
  << a = 5;
  print("%\n", << a); // => 5

  free(a);
  print("%\n", << a); // => 5
  print("%\n", a);    // => 14a_f407_6710
  a = null;
  print("%\n", a);    // => null
}