#import "Basic";

Person :: struct {
    name: string;
    sex: string;
}

main :: () {
    pers1 := Person.{"Angelina Jolie", "F"};
    pers2 := Person.{"Brad Pitt", "M"};
    pers1, pers2 = swap(pers1, pers2); 
    print("pers1 is % and pers2 is %\n", pers1, pers2);
    // => pers1 is {"Brad Pitt", "M"} and pers2 is {"Angelina Jolie", "F"}
}








   
