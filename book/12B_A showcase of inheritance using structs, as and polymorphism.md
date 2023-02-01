# 23B Document types: a showcase of inheritance using structs, as and polymorphism
(Example taken from how_to\008_types.jai)

We'll now combine all our previous knowledge to construct an OO-like type-inheritance system.

In the program below, we construct a hierarchy of data structures,
with a type tag that tells you which sub-type you are dealing with.
This example exhibits quite a lot of OO-like features.

See *23B.1_documents.jai*:
```c++
#import "Basic";

Document :: struct {      // (1)
    type:     Type;       
    filename: string;    
}

Video_File :: struct {    // (2)
    using #as base: Document;  // (3)
    
    duration:           float;
    width, height:      int;
    frames_per_second:  u16;
    number_of_channels: u8;
}

Audio_File :: struct {      // (4)
    using #as base: Document;  
    
    duration:      float;
    sampling_rate: u32;
}

Executable_File :: struct {     // (5)
        using #as base: Document;

        base.type = Executable_File;  // (5B)
        is_a_rootkit := false;
}

report :: (d: Document) {       // (6)
    print("Document type %, filename '%'.\n", d.type, d.filename);
}

full_report :: (doc: *Document) {  // (7)
    if doc.type == {
        case Video_File;
        vid := cast(*Video_File) doc;
        print("'%' is a video, % seconds long. Its resolution is %x%, % channels, and it runs at % frames per second.\n",
                vid.filename, vid.duration, vid.width, vid.height, vid.number_of_channels, vid.frames_per_second);
        case Audio_File;
        aud := cast(*Audio_File) doc;
        print("'%' is an audio, % seconds long, sampled at % Hz.\n", 
                aud.filename, aud.duration, aud.sampling_rate);
        case;
        print("Error: Document of invalid type!\n");
    }
}

make_document :: ($T: Type, name: string) -> T {  // (8) 
    doc: T;
    doc.type     = T;
    doc.filename = name;
    return doc;
}

heap_document :: ($T: Type, name: string) -> *T { //  (11) 
    doc: *T = alloc(size_of(T));  
    doc.type     = T;
    doc.filename = name;
    return doc;
}

main :: () {
    v: Video_File;
    v.type              = Video_File;
    v.filename          = "im_on_a_boat.fmv";
    v.frames_per_second = 30;
    
    a: Audio_File;
    a.type          = Audio_File;
    a.filename      = "i_threw_it_on_the_ground.wav";
    a.sampling_rate = 44100;

    report(v); // => Document type Video_File, filename 'im_on_a_boat.fmv'.
    report(a); // => Document type Audio_File, filename 'i_threw_it_on_the_ground.wav'.

    vid := make_document(Video_File, "always_be_closing.mp4");        // (9)
    aud := make_document(Audio_File, "apple_pie_from_scratch.wav");   // (10)

    report(vid); // => Document type Video_File, filename 'always_be_closing.mp4'.
    report(aud); // => Document type Audio_File, filename 'apple_pie_from_scratch.wav'.

    heap_vid := heap_document(Video_File, "blow_up_the_moon.mp4"); //  (12)
    heap_aud := heap_document(Audio_File, "some_summers_they_drop_like_flys.wav");

    defer free(heap_vid);   // (13)
    defer free(heap_aud);

    report(<< heap_vid); // (14) => Document type Video_File, filename 'blow_up_the_moon.mp4'.
    report(<< heap_aud); // => Document type Audio_File, filename 'some_summers_they_drop_like_flys.wav'.

    heap_vid.width  = 800;
    heap_vid.height = 600;
    heap_vid.number_of_channels = 4;
    heap_vid.duration = 133.3;
    heap_vid.frames_per_second = 30;
    full_report(heap_vid);
    // => 'blow_up_the_moon.mp4' is a video, 133.300003 seconds long. 
    // Its resolution is 800x600, 4 channels, and it runs at 30 frames per second.

    heap_aud.duration = 192.5;
    heap_aud.sampling_rate = 44100;
    full_report(heap_aud);
    // => 'some_summers_they_drop_like_flys.wav' is an audio, 192.5 seconds long, 
    // sampled at 44100 Hz.

    exe: Executable_File;
    exe.is_a_rootkit = true;
    report(exe); 
    // => Document type Executable_File, filename ''.
}
```

In line (1), we declare the `Document` struct. It is the base type: other things will be kinds of documents. The `type` field lets us know what kind of Document we are dealing with. The `filename` field is common to all Documents.

`Video_File` is the first specialized document. It starts with  line (3):  `using #as base: Document;`  

The base type Document is stated at the start of our struct, which makes it easy to find. `using` (see § 12.7) pulls in the names from Document so they can be used as if they were members of Video_File. #as (see § 12.8) means we can implicitly cast from Video_File to Document.  
Line (4) shows another Document tye struct called `Audio_File`.

In line (6), we have a procedure `report` that takes a Document as its argument.  
In `main` we create a Video_File v and Audio_File a instance, and call report with these as parameter. This is allowed, because of the #as they automatically cast to Document.  

`make_document` in line (7) is a polymorphic procedure (see § 22),
that takes something of type T and returns T, in what appears to be a Document, because it needs members type and filename.
We call it in lines (9) and (10), first for type Video_File, then for type Audio_File. Two specialized procs where compiled for these types. They return a Document of the type that was passed.
Notice that these instances are created on the stack. `report` knows how to handle them, as shown iin the following lines.

Next we create a proc `heap_document` starting in line (11), which takes something of type T, and returns a pointer to a heap-allocated Document of the appropriate type. We know that it is heap-allocated because `alloc` returns us a pointer to a series of contiguous bytes allocated on the heap.
Starting in line (12) we construct two Documents on the heap. Note that we now have to free their memory, as in line (13).
We can still call `report` on them, but now we have to send a dereferenced pointer as the parameter.  

In line (7) we show a more complete `full_report` proc, which takes a *Document. It is a pointer, but without problem we can access its fields(we don't need to use <<). Inside it, we make an if-case construct, so that we can report document specialized info.

Line (5) defines an Executable_File document type. It shows that the base type can be set as default value in the struct itself (it happened in the struct's initializer, sort of a recursive definition here), so that we don't need to set this externally in a procedure. 





