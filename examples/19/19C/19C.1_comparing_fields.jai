#import "Basic";

Person :: struct {
    name:         string;
    address:      string;
    phone_number: [9] u8;
    year_born:    int;
    month_born:   int;
    day_born:     int;
}

Business :: struct {
    name:           string;
    annual_revenue: s64;
    stock_symbol:   string;
    phone_number:   [9] u8;
    address:        string;
    number_of_employees: int;
}

conflicting_names :: (a: *Type_Info_Struct, b: *Type_Info_Struct) -> [] string { // (1)
    results: [..] string;
    for ma: a.members {   // (2)
        for mb: b.members {
            if ma.name == mb.name {
                array_add(*results, ma.name);
                continue ma;  // (3) 
            }
        }
    }
    return results;
}

main :: () {
    conflicting := conflicting_names(type_info(Person), type_info(Business));
    print("conflicting between Person and Business:\n%\n", conflicting);
    // => conflicting between Person and Business: 
    // ["name", "address", "phone_number"]
}

