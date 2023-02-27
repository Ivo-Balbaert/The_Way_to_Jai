#import "Basic";
#import "Compiler";
#import "File_Utilities";
#import "File";
#import "Bindings_Generator";

PROJECT_NAME :: "raylib_module_example";


// build entry point:
#run {
	set_build_options_dc(.{do_output=false, write_added_strings=false});

	// (1) - Generate `Raylib` module if it does not exist:
	if !file_exists("local_modules/raylib_win64") {
		generate_raylib_module("raylib_win64", "vendor/raylib_4.2.0_win64_msvc16");
	}

	workspace := compiler_create_workspace(PROJECT_NAME);
	if !workspace {
		print("[build] workspace creation for: % failed!\n", PROJECT_NAME);
		return;
	}

	// Debug configuration:
	options := get_build_options(workspace);
	options.output_executable_name = PROJECT_NAME;
	options.backend = .X64;
	options.intermediate_path = ".build/";
	options.output_path = ".build/";
	options.output_type = .EXECUTABLE;
	options.write_added_strings = false;

	// Add `local_modules` to import path:
	new_import_path: [..]string;
	array_add(*new_import_path, ..options.import_path);
	array_add(*new_import_path, "local_modules");
	options.import_path = new_import_path;

	set_build_options(options, workspace);

	// Add entry point:
	add_build_file("src/main.jai", workspace);
}


// Use to generate module from the given `Raylib` release:
generate_raylib_module :: (module_name: string, raylib_path: string) {
	using options: Generate_Bindings_Options;
	strip_flags = 0;

	// Add definitions for things that are missing:
	header = #string MODULE_HEADER
	// from: <stdarg.h> used by TraceLogCallback
	va_list :: *void;
	MODULE_HEADER

	// Add Raylib files to the generator:
	raylib_library_directory := tprint("%/lib", raylib_path);
	raylib_include_directory := tprint("%/include", raylib_path);

	array_add(*libpaths, raylib_library_directory);
	array_add(*libnames, "raylib");
	array_add(*include_paths, raylib_include_directory);
	array_add(*source_files, ..string.["raylib.h", "raymath.h", "rlgl.h"]);
	array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);

	// Generate module directory:
	raylib_module_directory := tprint("local_modules/%", module_name);
	raylib_module_lib_directory := tprint("%/%/lib", raylib_module_directory, raylib_path);
	raylib_module_file := tprint("%/module.jai", raylib_module_directory);

	make_directory_if_it_does_not_exist(raylib_module_directory, true);

	// Generate bindings and save them as module.jai:
	generate_bindings(options, raylib_module_file);

	// Copy library files to module directory:
	make_directory_if_it_does_not_exist(raylib_module_lib_directory, true);

	for string.["raylib.lib", "raylib.dll", "raylibdll.lib"] {
		file_src := tprint("%/%", raylib_library_directory, it);
		file_dest := tprint("%/%", raylib_module_lib_directory, it);
		copy_file(file_src, file_dest);
	}
}