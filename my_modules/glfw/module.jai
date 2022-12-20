// Bindings for GLFW 3.

// @@ Module options:
GLFW_EXPOSE_NATIVE_WIN32 :: false;
GLFW_EXPOSE_NATIVE_MACOS :: false;
GLFW_EXPOSE_NATIVE_X11 :: false;
GLFW_EXPOSE_NATIVE_WAYLAND :: false;
GLFW_EXPOSE_NATIVE_MIR :: false;
GLFW_EXPOSE_NATIVE_WGL :: false;
GLFW_EXPOSE_NATIVE_NSGL :: false;
GLFW_EXPOSE_NATIVE_GLX :: false;
GLFW_EXPOSE_NATIVE_EGL :: false;
GLFW_EXPOSE_VULKAN :: OS == .WINDOWS;   // Vulkan module only available on Windows ATM.

#if GLFW_EXPOSE_VULKAN {
    #import "Vulkan";
}

#load "glfw3.jai";
