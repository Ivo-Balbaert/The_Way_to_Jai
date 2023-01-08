#import "Basic";
#import "POSIX";

main :: () {
  buffer: [4096] u8;
  bytes_read := read(STDIN_FILENO, buffer.data, buffer.count-1);  // (1)
  // <= This is my input!
  str := to_string(buffer.data, bytes_read);
  print("Here is the string from console input: %\n", str);
  // => Here is the string from console input: This is my input!
}