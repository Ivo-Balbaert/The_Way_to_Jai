#import "GL";
#import "glfw";

main :: () {
  if !glfwInit() then return;
  defer glfwTerminate();

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
  window := glfwCreateWindow(640, 480, "GLFW Window", null, null);  // (1)
  if !window then return;
  defer glfwDestroyWindow(window);

  glfwMakeContextCurrent(window);
  while !glfwWindowShouldClose(window) {
    glfwSwapBuffers(window);
    glfwPollEvents();
  }
}

