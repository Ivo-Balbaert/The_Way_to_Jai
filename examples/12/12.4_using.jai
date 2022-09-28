#import "Basic";

Person :: struct {
    name: string;
}

Patient :: struct {
    using pe: Person;
    disease: string;   
}

main :: () {
    pat1 : Patient;  
    pat1.name = "Johnson"; // (1)
    pat1.disease = "Bronchitis";
    print("Patient is: %\n", pat1); // => Patient is: {{"Johnson"}, "Bronchitis"}

    using pat1;            // (2)
    print("Patient has name: %\n", name); // => Patient has name: Johnson
}

