#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include "Renderer.hpp"
#include "Shader.hpp"
#include "Camera.hpp"

Renderer::Renderer(int width, int height)
    : m_Width(width), m_Height(height)
{
    CreateFramebuffers();
    CreateShaders();

    m_Camera = std::make_shared<Camera>(glm::vec3(0.0, 0.0, -1.0));
}

Renderer::~Renderer()
{
    glDeleteTextures(1, &m_OutputTexture);
    glDeleteTextures(1, &m_AccumTexture);
    glDeleteTextures(1, &m_PathTraceTexture);

    glDeleteFramebuffers(1, &m_OutputFBO);
    glDeleteFramebuffers(1, &m_AccumTexture);
    glDeleteFramebuffers(1, &m_PathTraceFBO);
}

void Renderer::CreateFramebuffers()
{
    CreateDefaultFbTex(m_PathTraceFBO, m_PathTraceTexture);
    CreateAccumFbTex(m_AccumFBO, m_AccumTexture);
    CreateDefaultFbTex(m_OutputFBO, m_OutputTexture);
}

void Renderer::CreateShaders()
{
    m_PathTraceShader   = std::make_shared<Shader>("../shaders/vert.glsl", "../shaders/frag.glsl");
    m_AccumShader       = std::make_shared<Shader>("../shaders/vert.glsl", "../shaders/accum.glsl");
    m_OutputShader      = std::make_shared<Shader>("../shaders/vert.glsl", "../shaders/output.glsl");
}

void Renderer::CreateDefaultFbTex(unsigned int& fbo, unsigned int& tex)
{
    glGenFramebuffers(1, &fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);

    //Create Texture for FBO
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, m_Width, m_Height, 0, GL_RGB, GL_UNSIGNED_BYTE, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glBindTexture(GL_TEXTURE_2D, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex, 0);

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void Renderer::CreateAccumFbTex(unsigned int& fbo, unsigned int& tex)
{
    glGenFramebuffers(1, &fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);

    //Create Texture for FBO
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, m_Width, m_Height, 0, GL_RGBA, GL_FLOAT, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glBindTexture(GL_TEXTURE_2D, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex, 0);

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void Renderer::Draw(GLFWwindow* pWindow, float dt)
{
    static int frameCount = 0;

    m_Camera->OnUpdate(pWindow, dt);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_PathTraceTexture);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, m_AccumTexture);

    glBindFramebuffer(GL_FRAMEBUFFER, m_PathTraceFBO);
    m_PathTraceShader->Bind();
    // m_PathTraceShader->SetInt("u_acc", 0);
    m_PathTraceShader->SetVec2("u_resolution", glm::vec2(m_Width, m_Height));
    m_PathTraceShader->SetFloat("u_time", glfwGetTime());
    double mousex, mousey;
    glfwGetCursorPos(pWindow, &mousex, &mousey);
    m_PathTraceShader->SetVec2("u_mouse", glm::vec2(mousex, mousey));
    m_PathTraceShader->SetMat4("u_view_projection", m_Camera->GetProjectionMatrix() * m_Camera->GetViewMatrix());
    m_Quad.Draw();
    


    glBindFramebuffer(GL_FRAMEBUFFER, m_AccumFBO);
    m_AccumShader->Bind();
    m_AccumShader->SetInt("u_sample", 0);
    m_AccumShader->SetInt("u_acc", 1);
    m_Quad.Draw();

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    m_OutputShader->Bind();
    m_OutputShader->SetInt("outputTexture", 1);
    m_OutputShader->SetInt("u_fc", frameCount);
    m_Quad.Draw();

    frameCount++;
}