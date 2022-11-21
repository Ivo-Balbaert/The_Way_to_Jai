#import "Basic";
#module_parameters(VERBOSE := false);           // (1)

#run {                                          // (2)
  if VERBOSE {
    print("The module is in VERBOSE mode\n");
  } else {
    print("The module is in NON_VERBOSE mode\n");
  }
}



