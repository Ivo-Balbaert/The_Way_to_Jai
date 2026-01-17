# 4B - Options for giving code at the command-line
Remark: For the purposes of this section, delete or comment out the line `n := 42;` in the source code of 4.1_hello_sailor.jai. We are supplying the value of n on the command-line here. 

With `-run arg`, you can start a #run directive that parses and runs 'arg' as code.  
      Example:  `jai -run write_string(\"Hello!\n\") 4.1_hello_sailor.jai`   
The string Hello! is then shown at the start of the compiler output, after which the given program is compiled.
Remark: In Windows, this only works at a cmd prompt window, not in a Terminal.

With `-add arg`, you can add the string 'arg' to the target program as code.  
       Example: `jai -add "n := 42" 4.1_hello_sailor.jai`  
Now the variable n is know in the program, and we can print it out with for example:  `print("%", n);`

See *4.1_hello_sailor.jai*
```jai
#import "Basic";

main :: () {
    print("Hello, Sailor from Jai!\n");
    print("n is %\n", n);
}
```

Which produces as output when run:
```
Hello, Sailor from Jai!
n is 42
```

The `-verbose` option gives some extra information about what the meta-program is doing, for example:  
	`jai -run write_string(\"Hello!\n\") -add "n := 42" -verbose 4.1_hello_sailor.jai`  
shows the following at the start of the compiler output:
            
```jai
4.1_hello_sailor.jai
options.output_path = "D:/Jai/The_Way_to_Jai/examples/4/";
options.output_executable_name = "4.1_hello_sailor";
Changing working directory to 'D:/Jai/The_Way_to_Jai/examples/4/'.
Input files: ["D:\Jai\The_Way_to_Jai\examples\4\4.1_hello_sailor.jai"]
Add strings: ["n := 42"]
Run strings: ["write_string("Hello!\n")"]
Plugins:     [2ee_65e8]
Hello!
Running linker: … (abbreviated)_
```