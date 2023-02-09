#import "Basic";
#import "String";
#import "File";               

CSVFILE :: "assets/people.csv";

Person :: struct {
    index: string;
    user_id: string;
    first_name: string;
    last_name: string;
    sex: string;
    email: string;
    phone: string;
    birth_date: string;
    job_title: string;
}

SOA :: struct(T: Type, count: int) {    
  #insert -> string {                   
    builder: String_Builder;           
    defer free_buffers(*builder);
    t_info := type_info(T);             
    for fields: t_info.members {        
      print_to_builder(*builder, "  %1: [%2] type_of(T.%1);\n", fields.name, count);  
    }
    result := builder_to_string(*builder);  
    return result;
  }
}

main :: () {
    data, success := read_entire_file(CSVFILE);    
    if !success {
        print("Error. Cannot open file %.\n", CSVFILE);
        exit(-1);
    }

    print("File % successfully read.\n", CSVFILE);

    lines: [..] string;
    _lines := split(data, "\n");
    for _lines {
        line := trim(it);
        array_add(*lines, line);
    }
    defer array_free(lines);

    persons: [..] Person;   // array of structs
    defer array_free(persons);

    for lines {
        if it_index == 0    continue;  // header line 
        pers_info := split(it, ",");
        p := New(Person);
        defer free(p);
        p.index = pers_info[0];
        p.user_id = pers_info[1];
        p.first_name = pers_info[2];
        p.last_name = pers_info[3];
        p.sex = pers_info[4];
        p.email = pers_info[5];
        p.phone = pers_info[6];
        p.birth_date = pers_info[7];
        p.job_title = pers_info[8];
        array_add(*persons, p);
    }

    print("The persons array of structs is: \n");
    for persons     print("%\n", it);
    // => see in /* */ after program

    // turning into SOA:
    soa_persons: SOA(Person, 10);       
    // transferring data from persons (AOS) to soa_persons (SOA):
    for 0..persons.count - 1 {
        soa_persons.index[it] = persons[it].index;
        soa_persons.user_id[it] = persons[it].user_id;
        soa_persons.first_name[it] = persons[it].first_name;
        soa_persons.last_name[it] = persons[it].last_name;
        soa_persons.sex[it] = persons[it].sex;
        soa_persons.email[it] = persons[it].email;
        soa_persons.phone[it] = persons[it].phone;
        soa_persons.birth_date[it] = persons[it].birth_date;
        soa_persons.job_title[it] = persons[it].job_title;
    }
    print("\n");
    print("The soa_persons struct of arrays is: \n");
     // => see in /* */ after program

    for i: 0..soa_persons.count-1 {    
        print("Person[%]: first_name= %, last_name= %, job_title= %\n", 
        soa_persons.index[i], soa_persons.first_name[i], soa_persons.last_name[i], soa_persons.job_title[i]);
    }  
}

/*
The persons array of structs is:
{index = "1"; user_id = "88F7B33d2bcf9f5"; first_name = "Shelby"; last_name = "Terrell"; sex = "Male"; email = "elijah57@example.net"; phone = "001-084-906-7849x73518"; birth_date = "1945-10-26"; job_title = "Games devel"; }
{index = "2"; user_id = "f90cD3E76f1A9b9"; first_name = "Phillip"; last_name = "Summers"; sex = "Female"; email = "bethany14@example.com"; phone = "214.112.6044x4913"; birth_date = "1910-03-24"; job_title = "Phytotherapi"; }
{index = "3"; user_id = "DbeAb8CcdfeFC2c"; first_name = "Kristine"; last_name = "Travis"; sex = "Male"; email "; }thompson@example.com"; phone = "277.609.7938"; birth_date = "1992-07-02"; job_title = "Homeopath
{index = "4"; user_id = "A31Bee3c201ef58"; first_name = "Yesenia"; last_name = "Martinez"; sex = "Male"; email = "kaitlinkaiser@example.com"; phone = "584.094.6111"; birth_date = "2017-08-03"; job_title = "Market researc"; }
{index = "5"; user_id = "1bA7A3dc874da3c"; first_name = "Lori"; last_name = "Todd"; sex = "Male"; email = "buchananmanuel@example.net"; phone = "689-207-3558x7233"; birth_date = "1938-12-01"; job_title = "Veterinary surg"; }
{index = "6"; user_id = "bfDD7CDEF5D865B"; first_name = "Erin"; last_name = "Day"; sex = "Male"; email = "tconner@example.org"; phone = "001-171-649-9856x5553"; birth_date = "2015-10-28"; job_title = "Waste management of"; }r
{index = "7"; user_id = "bE9EEf34cB72AF7"; first_name = "Katherine"; last_name = "Buck"; sex = "Female"; email = "conniecowan@example.com"; phone = "+1-773-151-6685x49162"; birth_date = "1989-01-22"; job_title = "Intelli"; }e analyst
{index = "8"; user_id = "2EFC6A4e77FaEaC"; first_name = "Ricardo"; last_name = "Hinton"; sex = "Male"; email = "wyattbishop@example.com"; phone = "001-447-699-7998x88612"; birth_date = "1924-03-26"; job_title = "Hydrogeo"; }st
{index = "9"; user_id = "baDcC4DeefD8dEB"; first_name = "Dave"; last_name = "Farrell"; sex = "Male"; email = ""; }ann@example.net"; phone = "603-428-2429x27392"; birth_date = "2018-10-06"; job_title = "Lawyer
{index = "10"; user_id = "8e4FB470FE19bF0"; first_name = "Isaiah"; last_name = "Downs"; sex = "Male"; email = "virginiaterrell@example.org"; phone = "+1-511-372-1544x8206"; birth_date = "1964-09-20"; job_title = ""Engineer"; }

The soa_persons struct of arrays is:
Person[1]: first_name= Shelby, last_name= Terrell, job_title= Games developer
Person[2]: first_name= Phillip, last_name= Summers, job_title= Phytotherapist
Person[3]: first_name= Kristine, last_name= Travis, job_title= Homeopath
Person[4]: first_name= Yesenia, last_name= Martinez, job_title= Market researcher
Person[5]: first_name= Lori, last_name= Todd, job_title= Veterinary surgeon
Person[6]: first_name= Erin, last_name= Day, job_title= Waste management officer
Person[7]: first_name= Katherine, last_name= Buck, job_title= Intelligence analyst
Person[8]: first_name= Ricardo, last_name= Hinton, job_title= Hydrogeologist
Person[9]: first_name= Dave, last_name= Farrell, job_title= Lawyer
Person[10]: first_name= Isaiah, last_name= Downs, job_title= "Engineer
*/