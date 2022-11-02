#import "Basic";
#import "Compiler";

build :: () {
  w2 := get_current_workspace();        // (1)
  print("The current workspace is %\n", w2); // => The current workspace is 2
 
  w3 := compiler_create_workspace();    // (2)
  if !w3 {
    print("Workspace creation failed.\n");
    return;
  }
  print("The workspace w3 is %\n", w3); // => The workspace w3 is 3

  ws4 := compiler_create_workspace("Workspace 4");
  // do build for workspace 4...
  ws5 := compiler_create_workspace("Workspace 5");
  // do build for workspace 5...

}

main :: () { }

#run build();