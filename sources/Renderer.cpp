#include <glad/glad.h>
#include "Renderer.hpp"
#include "Shader.hpp"

Renderer::Renderer(int width, int height)
    : m_Width(width), m_Height(height)
{
    CreateFramebuffers();
    CreateShaders();
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
    CreateDefaultFbTex(m_AccumFBO, m_AccumTexture);
    CreateDefaultFbTex(m_OutputFBO, m_OutputTexture);
}

void Renderer::CreateShaders()
{
    m_PathTraceShader   = std::make_shared<Shader>("../shaders/vert.glsl", "../shaders/frag.glsl");
    m_OutputShader      = std::make_shared<Shader>("../shaders/vert.glsl", "../shaders/output.glsl");

    m_OutputShader->SetInt("outputTexture", 0);
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

void Renderer::Draw()
{
    static int frameCount = 0;

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_PathTraceTexture);

    glBindFramebuffer(GL_FRAMEBUFFER, m_PathTraceFBO);
    m_PathTraceShader->Bind();
    m_Quad.Draw();

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    m_OutputShader->Bind();
    m_Quad.Draw();

    frameCount++;
}