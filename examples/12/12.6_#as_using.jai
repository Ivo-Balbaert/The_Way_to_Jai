#import "Basic";

Person :: struct {
    name: string;
}

Patient :: struct {     // (1)
    using as: Person;
    disease: string;   
}

Employee :: struct {    // (2)
    #as using p: Person;
    profession: string;   
}

main :: () {
    pat1 : Patient;  
    pat1.name = "Johnson"; 
   
    emp1: Employee;
    emp1.name = "Gates";
    emp1.profession = "software engineer";
    print("%\n", emp1); // => {{"Gates"}, "software engineer"}

    p1: Person;
    // p1 = pat1; // (3) Error: Type mismatch: incompatible structs (wanted 'Person', given 'Patient').
    p1 = emp1;
    print("%\n", p1); // (4) => {"Gates"}
}



