main :: () {
  a: *int;
  b := *a;
  c := *b; // Too many levels of pointer indirection! c is of Type (***int)
}
