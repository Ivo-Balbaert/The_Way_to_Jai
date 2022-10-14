#import "Basic";

main :: () {
  builder: String_Builder;       // (1)
  defer free_buffers(*builder);  // (2) 
  init_string_builder(*builder); // (3)

  append(*builder, "One!");      // (4)
  append(*builder, "Two!");
  append(*builder, "Three!");

  n := 69105;
  exclamation := "For sure!!";
  print_to_builder(*builder, " ... number %, exclamation %.", n, exclamation); // (5)

  print("The length of the builder buffer is %\n", builder_string_length(*builder)); // (6)
  // => The length of the builder buffer is 56

  s := builder_to_string(*builder); // (7)
  print("The result string that came out of the builder is % bytes long.\n", s.count);
  // => The result string that came out of the builder is 56 bytes long.
  print("It is: '%'.\n", s);
  // => It is: 'One!Two!Three! ... number 69105, exclamation For sure!!.'.
}