#import "Basic";

dll_func :: () #foreign dynlib #c_call;
dynlib :: #library "dynlib";

main :: () {
    dll_func();
}

