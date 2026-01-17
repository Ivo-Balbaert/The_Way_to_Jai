## 19C - Getting console input
(The code in this section comes from the Jai Community Wiki.)  
Getting string input from a user at a console (terminal) window is quite straightforward on a Linux platform:  

See *19.7_linux_input.jai*:
```jai
#import "Basic";
#import "POSIX";

main :: () {
  buffer: [4096] u8;
  bytes_read := read(STDIN_FILENO, buffer.data, buffer.count-1);  // (1)
  // <= This is my input!
  str := to_string(buffer.data, bytes_read);                      // (2)
  print("Here is the string from console input: %\n", str);
  // => Here is the string from console input: This is my input!
}
```

In line (1) the `read` from module _POSIX_ waits for user input. The characters the user enters until pressing the ENTER key are stored in the `buffer` array. The `to_string` proc in line (2) (discussed in § 19.7) converts this into a string `str`. `read` is in fact a C function from libc.  
(See § 50 for another example where `read` is used.)


On Windows we can directly use the Windows APIs (namely the `ReadConsoleA` function from the Windows kernel32 system library), which makes our code a bit more complex: 

See *19.8_windows_input.jai*. 
```jai
#import "Basic";
#import "Windows";

kernel32 :: #system_library "kernel32";

stdin, stdout: HANDLE;

ReadConsoleA  :: (
    hConsoleHandle: HANDLE, 
    buff : *u8, 
    chars_to_read : s32,  
    chars_read : *s32, 
    lpInputControl := *void 
) -> bool #foreign kernel32;

input :: () -> string {
    MAX_BYTES_TO_READ :: 1024;
    temp : [MAX_BYTES_TO_READ] u8;
    result: string = ---;
    bytes_read : s32;
    
    if !ReadConsoleA( stdin, temp.data, xx temp.count, *bytes_read )
        return "";

    result.data  = alloc(bytes_read);
    result.count = bytes_read;
    memcpy(result.data, temp.data, bytes_read);
    return result;
}

main :: () {
    stdin = GetStdHandle( STD_INPUT_HANDLE );
    str := input();   // (1) <= This is my input!
    print("You gave this input: %\n", str);
    // => You gave this input: This is my input!
}
```

Again the input is read into a []u8 buffer `temp` and then copied with `memcpy` to the `result` string.
