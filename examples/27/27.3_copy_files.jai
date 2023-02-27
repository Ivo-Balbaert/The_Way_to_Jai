#import "Basic";
#import "File_Utilities";

main :: () {
    base := "D:\\Jai\\testing";
    src_folder := tprint("%\\%", base, "foldera");
    dest_folder := tprint("%\\%", base, "folderb");
    files := string.["example.txt", "linked_list.jai", "people.csv"];
    for files {
		file_src := tprint("%/%", src_folder, it);
		file_dest := tprint("%/%", dest_folder, it);
		copy_file(file_src, file_dest);
    }
}
