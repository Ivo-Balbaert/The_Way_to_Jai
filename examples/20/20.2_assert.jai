#assert true "This will never show\n";
#assert false "I just wanted you to fail\n";

// => at compile-time:
// Error: Compile-time assertion failed. "I just wanted you to fail
// "

//     #assert true "This will never show\n";
//     #assert false "I just wanted you to fail\n";

// Info: In Workspace 2 ("Target Program"), building target 'assert'.

