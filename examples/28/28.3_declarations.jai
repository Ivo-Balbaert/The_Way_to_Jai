main :: () {
    #asm {
        var: gpr; // declared a general purpose register named 'var'
        mov var, 1; // assign var = 1
    }

    #asm {
        // declared a general purpose register named 'var2', and mov 1 into it
        mov var2: gpr, 1; // assign var2 = 1
    }

    #asm {
        // implicitly declare 'var3' without specifying the type
        mov var3:, 1;
    }
}