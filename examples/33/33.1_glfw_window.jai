#import "GL";
#import "glfw";

main :: () {
  if !glfwInit() then return;       // (1)
  defer glfwTerminate();            // (1B)

  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 2);    // (2)
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
  window := glfwCreateWindow(640, 480, "GLFW Window", null, null);  // (3)
  if !window then return;
  defer glfwDestroyWindow(window);

  glfwMakeContextCurrent(window);    // (4)
  while !glfwWindowShouldClose(window) {    // (5) render loop
    processInput(window);            // (6)

    glfwSwapBuffers(window);
    glfwPollEvents();
  }
}

processInput :: (window: *GLFWwindow ) {  // (6B)
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, 1);
    }
}