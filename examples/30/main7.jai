dynlib :: #library,no_static_library "dynlib";
dll_func :: () #no_context #elsewhere dynlib;

main :: () {
    dll_func();
}

