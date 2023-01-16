# Chapter 16 - Types in depth

We previously talked about types in § 9. 
At compile time Jai deduces all there is to know about the types of all variables and objects.
This info is heavily used in meta-programming at compile-time (see § 26).

In this chapter we'll see which data-structures from built-in modules are used for this processing. Most of these are defined in module _Preload_.

>To see how type inference works in depth, read the masterfully written 090_how_typechecking_works article in the how_to/ folder of the compiler.)

## 16.1 Definition of Any
We encountered the Any type in § 9.4, it is defined as follows:   

```c++
Any_Struct :: struct {  
    type: *Type_Info;
    value_pointer: *void;
}
```

It is a struct of two values: 
- the **type** info, which is a pointer to a Type_Info struct with specific details about the assigned value type;
- and the **value_pointer** pointer to the value, which is a *void because we don't know the type of the value, that's why its Any!. 
To extract the value, you first need to cast the value_pointer to a pointer of the right type, and then dereference this pointer.  
Any is a type-safe version of a void pointer.  
But what is this Type_Info ?

## 16.2 Type_Info and Type_Info_Tag
Type_Info contains metadata for the types that appear in your program. It can be casted to more specific structs for additional info.
(See for example 16.1_types_in_depth.jai, line (6B))
This is its definition:

```c++
Type_Info :: struct {
    type:           Type_Info_Tag; 
    runtime_size:   s64;
}
```

The `type` field is of type `Type_Info_Tag`, the 2nd field is the size in bytes.

`Type_Info_Tag` itself is an enum, basically an enumeration of all supported type categories:

```c++
Type_Info_Tag :: enum u32 {
    INTEGER              :: 0;
    FLOAT                :: 1;
    BOOL                 :: 2;
    STRING               :: 3;
    POINTER              :: 4;
    PROCEDURE            :: 5;
    VOID                 :: 6;
    STRUCT               :: 7;
    ARRAY                :: 8;
    OVERLOAD_SET         :: 9;
    ANY                  :: 10;
    ENUM                 :: 11;
    POLYMORPHIC_VARIABLE :: 12;
    TYPE                 :: 13;
    CODE                 :: 14;
//    UNARY_DEREFERENCE :: 15;
//    UNARY_LITERAL :: 16;
    VARIANT              :: 18;
}
```
It literally enumerates all types than can occur in Jai.  
Then for nearly every type, there is a struct which comprises a Type_Info struct, as well as some other useful info for that specific type, like if it is signed or not for an integer. Here is an example:

```c++
Type_Info_Integer :: struct {
    using #as info: Type_Info;
    signed: bool;
}
```

## 16.3 Ways to dig into type information
See *16.1_types_in_depth.jai*:

```c++
#import "Basic";
#import "Math";

Complex :: struct { real, imag: float; }

Operating_Systems :: enum u16 #specified {
        VMS      :: 1;
        ATT_UNIX :: 2;
        WINDOWS  :: 3;
        GNU_SLASH_LINUX :: 4;
}

Direction :: enum {
    NORTH;      
    SOUTH;      
    EAST;      
    WEST;         
}

Thing1 :: struct {
    using #as v: Vector3;
    name: string;
}

Other :: struct {
    y:           float;
    temperature: float64;
    time:        Apollo_Time;
    x:           float;
}

uses_vector3_with_as :: (T: Type) -> bool {    // (6)
    ti := cast(*Type_Info) T;                  
    if ti.type != .STRUCT return false;

    tis := cast(*Type_Info_Struct) ti;         // (6B)
    for tis.members {
        if !(it.flags & .AS)             continue;
        if it.type != type_info(Vector3) continue;
        // We found a relevant member!
        return true;
    }
    return false;
}

main :: () {
    // a variable can also contain a composite type:
    var := Vector3;
    print("% is of type %\n", var, type_of(var)); // => Vector3 is of type Type

    n : s32 = 5;
    a: Any = n;
    print("a's Type_Info is: %\n", << a.type); // (1) => a's Type_Info is: {INTEGER, 4}
    print("a's type is: %\n", a.type.type); // => a's type is: INTEGER
    print("a's value_pointer is: %\n", a.value_pointer); // => c3_2d9c_f844
    print("The value inside a's value_pointer is: %\n", << cast(*s32) a.value_pointer); 
    // => The value inside a's value_pointer is: 5

    if a.type.type == Type_Info_Tag.FLOAT // (2)
        print("a is a float\n");
    else if a.type.type == Type_Info_Tag.INTEGER
        print("a is an int\n"); // => a is an int

    infor := type_info(Vector3);
    print("Type of infor is: %\n", type_of(infor)); // => Type of infor is: *Type_Info_Struct
    z_info :=  get_field(type_info(Vector3), "z");
    print("Type_Info_Struct_Member for z: %\n", <<z_info);
    // => Type_Info_Struct_Member for z: {name = "z"; type = 7ff6_99f1_4870; offset_in_bytes = 8; 

    for member: infor.members {   // (2B)
        print("%\n", member.name); // => x, y, z
    }
    print("\n");

    // type_info():
    typ1 := << type_info(float64); // (3)
    print("Type info of float64 is %\n", typ1); // => Type info of float64 is {{FLOAT, 8}}
    print("The type of typ1 is %\n", typ1.type); // => The type of typ1 is FLOAT

    typ2 := << type_info(Vector3);
    print("Type info of Vector3 is %\n", typ2); // => 
    // Type info of Vector3 is {info = {STRUCT, 12}; name = "Vector3"; 
    // specified_parameters = []; members = [{name = "x"; type = 7ff6_21db_41b0; offset_in_bytes = 0; 
    // flags = 0; notes = []; offset_into_constant_storage = 0; }, 
    // {name = "y"; type = 7ff6_21db_41b0; offset_in_bytes = 4; flags = 0; notes = []; 
    // offset_into_constant_storage = 0; }, 
    // {name = "z"; type = 7ff6_21db_41b0; offset_in_bytes = 8; flags = 0; notes = []; 
    // offset_into_constant_storage = 0; }]; status_flags = 0; nontextual_flags = 0; 
    // textual_flags = 0; polymorph_source_struct = null; initializer = null; 
    // constant_storage_size = 0; constant_storage_buffer = null; }
    print("The type of typ2 is %\n", typ2.type); // => The type of typ2 is STRUCT

    // (4) without using type_info():
    c1 := Complex.{3.14, 42.7};
    print("c1 is: % and has type %\n", c1, type_of(c1)); 
    // => c1 is: {3.14, 42.700001} and has type Complex
    TC := cast(*Type_Info) Complex;
    print("%\n", TC.type);  // => STRUCT
    if TC.type != .STRUCT then exit;
    SC := cast(*Type_Info_Struct) TC;       
    print("%\n", SC.name); // => Complex
    if SC.name == "Complex" then print("This is type COMPLEX\n"); // => This is type COMPLEX
    print("c1 is of type: ");
    print("%\n", (cast(*Type_Info_Struct) type_of(c1)).name);
    // => c1 is of type: Complex

    // (5) enum_type_flags
    info := type_info(Direction); // this is a *Type_Info_Enum
    print("enum '%' is ", info.name); // => enum 'Direction' is
    if info.enum_type_flags & .SPECIFIED    print("specified.\n");
    else print("*NOT* specified.\n");       // => *NOT* specified.
    
    info = type_info(Operating_Systems); 
    print("enum '%' is ", info.name); // => enum 'Operating_Systems' is .
    if info.enum_type_flags & .SPECIFIED    print("specified.\n"); // => specified
    else print("*NOT* specified.\n");  

    // (7) Checking whether a struct uses Vector3 with #as
    print("Thing1 uses #as with Vector3: %\n", uses_vector3_with_as(Thing1)); // => true
    print("Other uses #as with Vector3: %\n", uses_vector3_with_as(Other));   // => false

    print("The type of main is %\n", type_of(main));  // (8)
    // => The type of main is procedure ()
}
```

## 16.3.1 Cast to Any, .type and .type.type
As shown in line (1) and following, if a is a variable of type Any, then the type stored in the Any is:      
`<< a.type`, for example: {INTEGER, 4} or {STRUCT, 48}
`a.type.type` gives you the type like INTEGER or STRUCT; this is a member value from Type_Info_Tag.  
If Type1 is the type of the variable contained in the Any, then:
`<< cast(*Type1) a.value_pointer` will give you the value it contains.

We can test on a.type.type with if/else or if/case as in line (2).

## 16.3.2 The type_info() proc
There is also a `type_info()` proc: its argument must be a type and it returns a *Type_Info. Through it you can access all specific info from the specific Type_Info_ struct.
The `get_field` proc gives you detailed info on a specified field.
It is particularly handy when used on structs: see line 2B, where we iterate over the struct fields `members` with a for-loop (we can do that because members is an array. It was first introduced in § 15.5.

It is commonly used in polymorphic procedures (see § 22 =) to test the type of a $T argument.  
If you call `<< type_info(Type1)` on any Type1, it will give you all the info it has on that type (see line (3) and following).

The same info can be obtained by doing an explicit  
cast(*Type_Info_Struct), as shown from line (4).

Also:   `type_info(Any).type is .ANY`

In line (8) we see that the type of main is `procedure()`.

## 16.3.3 Checking whether an enum is #specified
A field `enum_type_flags` in Type_Info_Enum can give you more info on the enum, for example: a flag SPECIFIED tells you whether an enum has been specified, see line (5) and following.

## 16.3.4 Checking whether a struct uses another struct with #as
Proc `uses_vector3_with_as` starting in line (6) shows how you can detect this with reflection info. We test it in line (7) on a struct type Thing1 that fulfills the requirement, and a struct Other which does not. 

## 16.3.5 Type info available at runtime
Much of the Type_Info provided by the compiler is also available at runtime, because the compiler bakes that data into your executable. Specifically this includes types for which your program calls type_info(), or any type referenced by those, recursively.  For example, the `print` procedure uses this runtime type info to do its job. 

In certain cases you might not need all this type info, and/or you want to reduce the size of the executable. There are some directives available that help you do just that:  
* **#type_info_none** : a struct with that directive will have no runtime type info, example: `NoThing :: struct #type_info_none { ... }`  
* **#type_info_procedures_are_void_pointers** : in structs that have this directive, procedures do not retain their info at runtime.

The same can also be done with compiler flags like this:
```
#run compiler_set_type_info_flags(NoThing, .NO_TYPE_INFO);
#run compiler_set_type_info_flags(Bundle_B, .PROCEDURES_ARE_VOID_POINTERS);
```

This way you don't have to modify the code for the structs itself.

## 16.3.6 Checking whether a struct is a subclass of another struct
In § 12.8 we introduced the `using #as` clause, which allows to define a struct as a subclass of another struct, so in program _12.6_#using_as.jai_ Employee was a subclass of Person. Module _Compiler_ has a proc called `is_subclass_of` which tests just that. Let's use it with the structs from the 12.6 example:
See *16.2_is_subclass_of*:

```c++
#import "Basic";
#import "Compiler";

Person :: struct {
    name: string;
}

Patient :: struct {     // (1)
    using as: Person;
    disease: string;   
}

Employee :: struct {    // (2)
    using #as p: Person;
    profession: string;
}

main :: () {
    pat1: Patient;  
    pat1.name = "Johnson"; 
   
    emp1: Employee;
    emp1.name = "Gates";
    emp1.profession = "software engineer";
    print("%\n", emp1); // => {{"Gates"}, "software engineer"}

    p1: Person;
    p1 = emp1;
    print("%\n", p1); // => {"Gates"}

    // Test if Employee is a subclass of Person:
    tie := cast(*Type_Info) type_info(Employee);  // (3)
    if is_subclass_of(tie, "Person") {
        print("Employee is a subclass of Person\n");
    } else {
         print("Employee is NOT a subclass of Person\n"); 
    }

    // Test if Patient is a subclass of Person:
    tip := cast(*Type_Info) type_info(Patient);
    if is_subclass_of(tip, "Person") {
        print("Patient is a subclass of Person\n");
    } else {
        print("Patient is NOT a subclass of Person\n");  
    }
}

/*
Employee is a subclass of Person
Patient is NOT a subclass of Person
*/
```

If we do a `tis := cast(*Type_Info) type_info(Subclass);`  
then we can check this with: `is_subclass_of(tis, "Person")`.
This could also be done for the struct hierarchy defined in § 23B.