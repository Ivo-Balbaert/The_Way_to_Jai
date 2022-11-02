#import "Basic";

main :: () { 
  print("In file % line %\n", #file, #line); // (1)
  // => In file d:/Jai/The_Way_to_Jai/examples/30/30.2_location.jai line 4
  print("Filepath is %\n", #filepath);       // (2)
  // => Filepath is d:/Jai/The_Way_to_Jai/examples/30/
}