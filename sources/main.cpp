#include <iostream>
#include <stdexcept>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include "ShaderLibrary.hpp"
#include "Camera.hpp"

glm::vec2 GetResolution(GLFWwindow* pWindow)
{
    int width, height;
    glfwGetWindowSize(pWindow, &width, &height);
    return glm::vec2(width, height);
}

glm::vec2 GetCursorPos(GLFWwindow* pWindow)
{
    double x, y;
    glfwGetCursorPos(pWindow, &x, &y);
    return glm::vec2(x, y);
}

float lastFrame = 0.0f;

int main()
{
    try
    {
        glfwInit();

        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
        glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);
        #ifdef __APPLE__
            glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_FALSE);
            glfwWindowHint(GLFW_COCOA_RETINA_FRAMEBUFFER, GLFW_FALSE);
        #endif

        int width = 600, height = 500;
        GLFWwindow* pWindow = glfwCreateWindow(width, height, "Fractol", nullptr, nullptr);

        if (!pWindow)
            throw std::runtime_error("Failed to create window");

        glfwMakeContextCurrent(pWindow);
        glfwSetInputMode(pWindow, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

        if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
            throw std::runtime_error("Failed to initialize GLAD");

        // setup OpenGL state
        glClearColor(0.2, 0.3, 0.4, 1.0);

        unsigned int vao, vbo;
        glGenVertexArrays(1, &vao);

        ShaderLibrary lib;
        lib.Load("Main", "../shaders/vert.glsl", "../shaders/frag.glsl");

        Camera camera(glm::vec3(0.0));

        auto shader = lib.Get("Main");

        while (!glfwWindowShouldClose(pWindow) && !glfwGetKey(pWindow, GLFW_KEY_ESCAPE))
        {
            float currentFrame = glfwGetTime();
            float deltaTime = currentFrame - lastFrame;
            lastFrame = currentFrame;  

            glfwPollEvents();

            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glViewport(0, 0, width, height);

            camera.OnUpdate(pWindow, deltaTime);

            shader->Bind();
            shader->SetVec2("u_resolution", GetResolution(pWindow));
            shader->SetVec2("u_mouse", GetCursorPos(pWindow) / GetResolution(pWindow));
            shader->SetFloat("u_time", glfwGetTime());
            shader->SetMat4("u_view_projection", camera.GetProjectionMatrix() * camera.GetViewMatrix());

            glBindVertexArray(vao);
            glDrawArrays(GL_TRIANGLES, 0, 6);

            glfwSwapBuffers(pWindow);
        }
        
        glfwTerminate();
    }
    catch(const std::exception& e)
    {
        std::cerr << e.what() << std::endl;
    }

    return 0;
}
