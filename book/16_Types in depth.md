# Chapter 16 - Types in depth

We previously talked about types in § 9. 
At compile time Jai deduces all there is to know about the types of all variables and other code objects.
This info can then be used in meta-programming at compile-time (see § 26).

In this chapter we'll see which data-structures from built-in modules are used for this processing. Most of these are defined in module _Preload_.

>To see how type inference works in depth, read the masterfully written 090_how_typechecking_works article in the how_to/ folder of the compiler.)

## 16.1 Definition of Any, .type and .type.type
We encountered the Any type in § 9.5, it is defined as follows (see module _Preload_):   

```c++
Any_Struct :: struct {  
    type: *Type_Info;
    value_pointer: *void;
}
```

It is a struct of two values: 
- the **type** info, which is a pointer to a Type_Info struct with specific details about the type of the assigned value if you ask for it;
- and the **value_pointer** pointer to the value, which is a *void because we don't know the type of the value, that's why its Any!.
In § 9.5 we saw that its size is 16 bytes (on a 64 bit system). Now we see why: it contains 2 pointers, each 8 bytes in size.
To extract the value, you first need to cast the value_pointer to a pointer of the right type, and then dereference this pointer.  
Any is a type-safe version of a void pointer.
Here are some ways to extract info of an Any variable:  

See *16.1_Any_type.jai*:
```c++
#import "Basic";

main :: () {
    x: Any = 3.0; 
    print("x contains this float: %\n", << cast(*float) x.value_pointer); // (0A)
    // => x contains this float: 3
    x = "foo";
    print("now x contains this string: %\n", << cast(*string) x.value_pointer); // (0B)
    // => now x contains this string: foo

    n: s32 = 5;
    a: Any = n;
    print("a's Type_Info is: %\n", << a.type); // (1) => a's Type_Info is: {INTEGER, 4}
    print("a's type is: %\n", a.type.type); // => a's type is: INTEGER
    print("a's value_pointer is: %\n", a.value_pointer); // => c3_2d9c_f844
    print("The value inside a's value_pointer is: %\n", << cast(*s32) a.value_pointer);  // (0C)
    // => The value inside a's value_pointer is: 5

    if  a.type.type == {        // (2)
        case Type_Info_Tag.FLOAT;     print("a is a float\n");
        case Type_Info_Tag.INTEGER;   print("a is an int\n"); // => a is an int
    }
}
```
As shown in line (1) and following, if a is a variable of type Any, then the type stored in the Any is:      
`<< a.type`, for example: {INTEGER, 4} or {STRUCT, 48}
`a.type.type` gives you the type like INTEGER or STRUCT; this is a member value from Type_Info_Tag.  
If Type1 is the type of the variable contained in the Any, then:
`<< cast(*Type1) a.value_pointer` will give you the value it contains (0A-C).

We can test on a.type.type with if/else or if/case as in line (2).
But what is this Type_Info ?

## 16.2 Type_Info and Type_Info_Tag
`Type_Info` contains metadata for all types that appear in your program, not just for Any! It can be casted to more specific structs for additional info.
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
For nearly every type, there is a struct which comprises a Type_Info struct, as well as some other useful info for that specific type, like if it is signed or not for an integer. Here is an example:

```c++
Type_Info_Integer :: struct {
    using #as info: Type_Info;
    signed: bool;
}
```

## 16.3 The type_info() proc

See *16.2_type_info_proc.jai*:
```c++
#import "Basic";
#import "Math";

main :: () {
    // type_info():
    typ1 := << type_info(float64); // (3)
    print("Type info of float64 is %\n", typ1); // => Type info of float64 is {{FLOAT, 8}}
    print("The type of typ1 is %\n", typ1.type); // => The type of typ1 is FLOAT
   
    print("%", type_info(Any).type); // => ANY

    // a variable can also contain a composite type:
    var := Vector3;             // (1)
    print("The value of var is %, and it is of type %\n", var, type_of(var)); 
    // => The value of var is Vector3 and it is of type Type

    ti := type_info(Vector3);      // (2)
    print("Type of ti is: %\n", type_of(ti)); // => Type of infor is: *Type_Info_Struct
    for member: ti.members      print("% - ", member.name);       // (2B)
    // => x - y - z - xy - yz - component -

    print("\n");
    z_info :=  get_field(type_info(Vector3), "z");   // (3)
    print("Type_Info_Struct_Member for z: %\n", <<z_info);
    // => Type_Info_Struct_Member for z: {name = "z"; 
    // type = 7ff7_1e05_1b18; offset_in_bytes = 8; flags = 0; notes = []; offset_into_constant_storage = 0; }

    typ2 := << type_info(Vector3);      // (4)
    print("Type info of Vector3 is %\n", typ2); // => 
    // => Type info of Vector3 is {info = {STRUCT, 12}; name = "Vector3"; 
    // specified_parameters = []; members = [{name = "x"; type = 7ff6_21db_41b0; offset_in_bytes = 0; 
    // flags = 0; notes = []; offset_into_constant_storage = 0; }, 
    // {name = "y"; type = 7ff6_21db_41b0; offset_in_bytes = 4; flags = 0; notes = []; 
    // offset_into_constant_storage = 0; }, 
    // {name = "z"; type = 7ff6_21db_41b0; offset_in_bytes = 8; flags = 0; notes = []; 
    // offset_into_constant_storage = 0; }]; status_flags = 0; nontextual_flags = 0; 
    // textual_flags = 0; polymorph_source_struct = null; initializer = null; 
    // constant_storage.count = 0; constant_storage.data = null; }
    print("The type of typ2 is %\n", typ2.type); // => The type of typ2 is STRUCT
    tis := << cast(*Type_Info_Struct) Vector3;   // (5)
    print("Info from tis: %\n", tis);
    // => Info from tis: {info = {STRUCT, 12}; name = "Vector3"; ...
}
```

There is also a `type_info()` proc: its argument must be a type and it returns a *Type_Info. Through it you can access all specific info from the appropriate Type_Info_ struct. We already used it in § 15.5.  
`type_info(Any).type` is .ANY.

Let's dig into the type info of type Vector3, defined in module _Math_, look up its definition, see line (1).  
In line (2) we call `type_info()` on Vector3. The `type_of()` of this variable `ti` is a `*Type_Info_Struct`. In line 2B, we iterate over the struct fields contained in `members` with a for-loop (we can do that because members is an array and we can do a for-loop on arrays (see § 18.2).  

The `get_field` proc (see line (3)) gives you detailed info on a specified field.
It is particularly handy when used on structs. 

type_info is commonly used in polymorphic procedures (see § 22) to test the type of a $T argument. If you call `<< type_info(Type1)` on any Type1, it will give you all the info it has on that type, which can be quite a lot (see line (4) and following).
The same info for a struct can be obtained by doing an explicit  
`<< cast(*Type_Info_Struct)`, as shown from line (5).

## 16.4 Other useful ways to dig into type information

## 16.4.1 Checking whether an enum is #specified
A field `enum_type_flags` in Type_Info_Enum can give you more info on the enum, for example: a flag SPECIFIED tells you whether an enum has been specified (see § 13.4), see line (5) and following.

See *16.3_enum_specified.jai*:

```c++
#import "Basic";
#import "Math";

Direction :: enum {
    NORTH;      
    SOUTH;      
    EAST;      
    WEST;         
}

Operating_Systems :: enum u16 #specified {
        VMS      :: 1;
        ATT_UNIX :: 2;
        WINDOWS  :: 3;
        GNU_SLASH_LINUX :: 4;
}

main :: () {
    info := type_info(Direction); // (5) this is a *Type_Info_Enum
    print("enum '%' is ", info.name); // => enum 'Direction' is
    if info.enum_type_flags & .SPECIFIED    print("specified.\n");
    else print("*NOT* specified.\n");       // => *NOT* specified.
    
    info = type_info(Operating_Systems); 
    print("enum '%' is ", info.name); // => enum 'Operating_Systems' is .
    if info.enum_type_flags & .SPECIFIED    print("specified.\n"); // => specified
    else print("*NOT* specified.\n");
}
```

## 16.4.2 Checking whether a struct is a subclass of another struct
This in fact checks whether a struct is a subclass of another struct.
In § 12.8 we introduced the `using #as` clause, which allows to define a struct as a subclass of another struct, so in program _12.6_#using_as.jai_ Employee was a subclass of Person.

See *16.4_check_#as.jai*:
```c++
#import "Basic";
#import "Math";

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

    tis := cast(*Type_Info_Struct) ti;
    for tis.members {
        if !(it.flags & .AS)             continue;
        if it.type != type_info(Vector3) continue;
        // We found a relevant member!
        return true;
    }
    return false;
}

main :: () {
    // Checking whether a struct uses Vector3 with #as
    print("Other uses #as with Vector3: %\n", uses_vector3_with_as(Other));   
    // => "Other uses #as with Vector3: false 
    print("Thing1 uses #as with Vector3: %\n", uses_vector3_with_as(Thing1)); 
    // => Thing1 uses #as with Vector3: true
}
```

Proc `uses_vector3_with_as` starting in line (6) shows how you can detect this with reflection info. We test it in line (7) on a struct type Thing1 that fulfills the requirement, and a struct Other which does not.

The former code shows how we can do this ourselves, but this has proven to be so useful that module _Compiler_ has a proc called `is_subclass_of` which tests just that. Let's use it with the structs from the 12.6 example:

See *16.5_is_subclass_of*:

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


## 16.4.3 Type info available at runtime
Much of the Type_Info provided by the compiler is also available at runtime, because the compiler by default bakes that data into your executable. Specifically this includes types for which your program calls type_info(), or any type referenced by those, recursively.  For example, the `print` procedure uses this runtime type info to do its job. 

In certain cases you might not need all this type info, and/or you want to reduce the size of the executable. There are some directives available that help you do just that:  
* **#type_info_none** : a struct with that directive will have no runtime type info, example: `NoThing :: struct #type_info_none { ... }`  
* **#type_info_procedures_are_void_pointers** : in structs that have this directive, procedures do not retain their info at runtime.

The same can also be done with compiler flags like this:
```
#run compiler_set_type_info_flags(NoThing, .NO_TYPE_INFO);
#run compiler_set_type_info_flags(Bundle_B, .PROCEDURES_ARE_VOID_POINTERS);
```

This way you don't have to modify the code for the structs itself.

