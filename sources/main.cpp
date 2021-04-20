#include <iostream>
#include <stdexcept>
#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include "ShaderLibrary.hpp"

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

glm::vec3 position = glm::vec3(0.0);

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

        auto shader = lib.Get("Main");

        while (!glfwWindowShouldClose(pWindow))
        {
            glfwPollEvents();

            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glViewport(0, 0, width, height);

            glm::vec2 cursor_pos = GetCursorPos(pWindow);

			float mx = (cursor_pos.x / width - 0.5f) * 0.05;
			float my = (cursor_pos.y / height - 0.5f) * 0.05;

			glm::vec3 dir(0.0);
			glm::vec3 temp_dir;

			if (glfwGetKey(pWindow, GLFW_KEY_D)) 
                dir = glm::vec3(1.0f, 0.0f, 0.0f);
			else 
            if (glfwGetKey(pWindow, GLFW_KEY_A)) 
                dir = glm::vec3(-1.0f, 0.0f, 0.0f);

			if (glfwGetKey(pWindow, GLFW_KEY_W)) 
                dir = glm::vec3(0.0f, -1.0f, 0.0f);
			else 
            if (glfwGetKey(pWindow, GLFW_KEY_S))
                dir = glm::vec3(0.0f, 1.0f, 0.0f);

			temp_dir.z = dir.z * cos(-my) - dir.x * sin(-my);
			temp_dir.x = dir.z * sin(-my) + dir.x * cos(-my);
			temp_dir.y = dir.y;
			dir.x = temp_dir.x * cos(mx) - temp_dir.y * sin(mx);
			dir.y = temp_dir.x * sin(mx) + temp_dir.y * cos(mx);
			dir.z = temp_dir.z;

			position += (dir * 0.05f);

            shader->Bind();
            shader->SetVec2("u_resolution", GetResolution(pWindow));
            shader->SetVec2("u_mouse", GetCursorPos(pWindow));
            shader->SetVec3("u_pos", position);
            shader->SetFloat("u_time", glfwGetTime());

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
