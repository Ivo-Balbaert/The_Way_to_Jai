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
    tie := cast(*Type_Info) type_info(Employee);
    if is_subclass_of(tie, "Person") {
        print("Employee is a subclass of Person\n");
    } else {
         print("Employee is NOT a subclass of Person\n"); 
    }
    // => Employee is a subclass of Person

    // Test if Patient is a subclass of Person:
    tip := cast(*Type_Info) type_info(Patient);
    if is_subclass_of(tip, "Person") {
        print("Patient is a subclass of Person\n");
    } else {
        print("Patient is NOT a subclass of Person\n");  
    }
    // => Patient is NOT a subclass of Person
}


