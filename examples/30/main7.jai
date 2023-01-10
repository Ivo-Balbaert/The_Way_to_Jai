#import "Basic";

dll_func :: () #foreign dynlib;
dynlib :: #library "dynlib";

main :: () {
    dll_func();
}

