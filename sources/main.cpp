#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <stdexcept>

#include "Shader.hpp"
#include "Renderer.hpp"
#include "Quad.hpp"

int main()
{
    glfwInit();
    int width = 800, height = 600;
    
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif

    GLFWwindow* pWindow = glfwCreateWindow(width, height, "Pathtracer", nullptr, nullptr);
    if (!pWindow)
        throw std::runtime_error("Failed to create window");

    glfwMakeContextCurrent(pWindow);

    glfwSetFramebufferSizeCallback(pWindow, [](GLFWwindow*, int width, int height)
    {
        glViewport(0, 0, width, height);
    });

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
        throw std::runtime_error("Failed to initialize glad");

    Quad quad;
    Shader shader("../shaders/vert.glsl", "../shaders/frag.glsl");

    Renderer renderer(800, 600);

    while (!glfwWindowShouldClose(pWindow))
    {
        glClearColor(0.0, 0.0, 0.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        // shader.Bind();
        // quad.Draw();
        renderer.Draw();
        
        glfwSwapBuffers(pWindow);
        glfwPollEvents();
    }

    glfwDestroyWindow(pWindow);
    glfwTerminate();
    return 0;
}