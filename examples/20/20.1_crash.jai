// #run main(); // uncomment this for debugging at compile-time

main :: () {
    a := 0;
    b := 1 / a; // (1) Causes a crash
    
    write_string("Done!"); // (2) will never be reached!
}

