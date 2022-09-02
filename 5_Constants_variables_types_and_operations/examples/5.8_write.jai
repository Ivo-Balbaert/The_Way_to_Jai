main :: () {
  write_string("Hello, World!\n");               // => Hello, World!
  write_strings("Hello", ",", " World!", "\n");  // => Hello, World!
  write_number(-42);            // => -42
  write_nonnegative_number(42); // => 42
}

/*
Hello, World!
Hello, World!
-4242
*/