# 19C_Comparing field names of structs.md
(Code snippet taken from how_to/044_using_advanced)

See _19C.1_comparing_fields.jai_:
```jai
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
```
We compare the field names of the structs Person and Business, which have a few names in common. This is done in the procedure `conflicting_names` (see line (1)), which gets the type_info of both structs as arguments, and returns the duplicate field names as an array of strings.  
In a nested for-loop starting in line (2), the names of the first struct are compared with the names of the second struct. When a match is found, the field name is added to the results array, and we continue with the next field of the first struct (line (3)).
