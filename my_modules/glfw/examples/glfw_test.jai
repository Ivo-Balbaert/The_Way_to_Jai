#import "glfw";
#import "GL";
#import "Basic";

Vertex :: struct {
    x, y : float;
    r, g, b : float;
}

vertices : [3]Vertex;
//{
//    { -0.6f, -0.4f, 1.f, 0.f, 0.f },
//    {  0.6f, -0.4f, 0.f, 1.f, 0.f },
//    {   0.f,  0.6f, 0.f, 0.f, 1.f }
//}



vertex_shader_text := #string END
uniform mat4 MVP;
attribute vec3 vCol;
attribute vec2 vPos;
varying vec3 color;
void main() {
    gl_Position = MVP * vec4(vPos, 0.0, 1.0);
    color = vCol;
}
END

fragment_shader_text := #string END
varying vec3 color;
void main() {
    gl_FragColor = vec4(color, 1.0);
}
END

error_callback :: (error: s32, description: *u8) #c_call {
    //print("Error: %\n", to_string(description));
}

key_callback :: (window: *GLFWwindow, key: s32, scancode: s32, action: s32, mods: s32) #c_call {
    if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS {
        glfwSetWindowShouldClose(window, GLFW_TRUE);
    }
}

main :: () {

    glfwSetErrorCallback(error_callback);
    if !glfwInit() {
        exit(-1/*EXIT_FAILURE*/);
    }
    
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    window := glfwCreateWindow(640, 480, "Simple example", null, null);
    
    if !window {
        glfwTerminate();
        exit(-1/*EXIT_FAILURE*/);
    }

    glfwSetKeyCallback(window, key_callback);
    glfwMakeContextCurrent(window);
    
    gl_load(*gl, glfwGetProcAddress);
    using gl;

    glfwSwapInterval(1);

    // NOTE: OpenGL error checks have been omitted for brevity

    vertex_buffer : GLuint;
    glGenBuffers(1, *vertex_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertex_buffer);
    glBufferData(GL_ARRAY_BUFFER, size_of(type_of(vertices)), vertices.data, GL_STATIC_DRAW);

    vertex_shader := glCreateShader(GL_VERTEX_SHADER);
    _glShaderSource(vertex_shader, vertex_shader_text);
    glCompileShader(vertex_shader);

    fragment_shader := glCreateShader(GL_FRAGMENT_SHADER);
    _glShaderSource(fragment_shader, fragment_shader_text);
    glCompileShader(fragment_shader);

    program := glCreateProgram();
    glAttachShader(program, vertex_shader);
    glAttachShader(program, fragment_shader);
    glLinkProgram(program);

    mvp_location := glGetUniformLocation(program, "MVP");
    vpos_location := glGetAttribLocation(program, "vPos");
    vcol_location := glGetAttribLocation(program, "vCol");

    //glEnableVertexAttribArray(vpos_location);
    //glVertexAttribPointer(vpos_location, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 5, (void*) 0); 
    //glEnableVertexAttribArray(vcol_location);
    //glVertexAttribPointer(vcol_location, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 5, (void*) (sizeof(float) * 2));
    
    while !glfwWindowShouldClose(window) {

        width, height : s32;
        glfwGetFramebufferSize(window, *width, *height);
        glViewport(0, 0, xx width, xx height);

        glClear(GL_COLOR_BUFFER_BIT);

       
        //mat4x4 m, p, mvp;
        ratio := cast(float) width / height;
        //mat4x4_identity(m);
        //mat4x4_rotate_Z(m, m, (float) glfwGetTime());
        //mat4x4_ortho(p, -ratio, ratio, -1.f, 1.f, 1.f, -1.f);
        //mat4x4_mul(mvp, p, m);

        glUseProgram(program);
        //glUniformMatrix4fv(mvp_location, 1, GL_FALSE, (const GLfloat*) mvp);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    glfwDestroyWindow(window);
    glfwTerminate();
    
    exit(0/*EXIT_SUCCESS*/);
}
