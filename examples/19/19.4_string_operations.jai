#import "Basic";
#import "String";

main :: ()  {
    str1 := "London";
    str2 := "Antwerp";

    copy := copy_string(str1);
    print("copy is: %\n", copy); // => copy is: London

    // Conversions to and from numbers:
    // string to numbers
    i, ok := string_to_int("42");     // (1)
    if ok print("the integer is %\n", i); // => the integer is 42
    j, ok2 := string_to_int("abc");
    if ok2 print("the integer is %\n", j); 
    else print("this is not an integer!\n"); // => this is not an integer!
    f, ok3 := string_to_float("3.1415"); // (2)
    if ok3 print("the float is %\n", f); // => the float is 3.1415

    str3 := "108";
    i, ok = parse_int(*str3);
    print("i is % and ok is %\n", i, ok); // => i is 108 and ok is true
    
    str3 = "108";  // parse_int empties str3
    i, ok = to_integer(str3);             // (2B)  
    print("i is % and ok is %\n", i, ok); // => i is 108 and ok is true
    if !ok {
        print("Expected to read an integer, but got '%'!\n", i);
        // for str3 == "abc"
        // => Expected to read an integer, but got '0'!
        exit(-1);
    }
    
    a := 4;
    str := sprint("%", a);                  // (2C)
    print("a is %, str is -%-\n", a, str);  // => a is 4, str is -4-
    print("str is type %\n", type_of(str)); // => str is type string
    
    // Comparison functions:
    n := compare(str1, str2); // (3) 
    print("n is %\n", n);       // => 1
    if n > 0  print("str1 comes after str2\n"); // => str1 comes after str2
    who := "Ant";
    if contains(str2, who)  print("%s are living in %\n", who, str2); // => Ants are living in Antwerp
    if begins_with(str2, who) {
        print("Antwerp is a city of ants!\n"); // => Antwerp is a city of ants!
    }

    // (4) Concatenating strings and splitting strings:
    print(join("a","b","c","d")); // => abcd
    print("\n");
    print(join(.. .["One", "Two", "Three"], separator = "::")); // => One::Two::Three
    print("\n");
    print(join(.. .["One", "Two", "Three"], separator = "::", before_first = true, after_last = false)); 
    // => ::One::Two::Three
    print("\n");
    print(join(.. .["One", "Two", "Three"], separator = "::", before_first = true, after_last = true)); 
    // => ::One::Two::Three::
    print("\n");
    s := join(.. .["foo", "bar", "puf"], ", ");
    print("s is '%'\n", s); // => s is 'foo, bar, puf'
    s2 := "Hello, Sailor! How are you?";
    print("s2 splitted: %\n", split(s2, " ")); // => s2 splitted: ["Hello,", "Sailor!", "How", "are", "you?"]
    for split(s2, " ") {  // (4B)
	    print("% / ", it);
    }
    print("\n");


    // search:
    print("'on' is found at position % in %\n",find_index_from_left(str1, "on"), str1); // (5)
    // => 'on' is found at position 1 in London
    print("'on' is found at position % in %\n",find_index_from_right(str1, "on"), str1);
    // => 'on' is found at position 4 in London

    // (6) changing:
    print("+"); print(trim("\t   Hello, Sailor!          \t")); print("+"); // => +Hello, Sailor!+
    print("\n");
    print(replace("Antwerpen", "n", "m")); // => Amtwerpem
    print("\n");
    print(slice("London", 2, 3)); // => ndo
    print("\n");
}