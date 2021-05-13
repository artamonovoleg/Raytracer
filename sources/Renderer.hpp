#pragma once

#include <memory>
#include <random>
#include "Quad.hpp"

class Shader;
class Camera;

class Renderer
{
    private:
        int m_Width, m_Height;
        
        unsigned int m_PathTraceFBO;
        unsigned int m_PathTraceTexture;

        unsigned int m_AccumFBO;
        unsigned int m_AccumTexture;

        unsigned int m_OutputFBO;
        unsigned int m_OutputTexture;
        
        std::shared_ptr<Shader> m_PathTraceShader;
        std::shared_ptr<Shader> m_AccumShader;
        std::shared_ptr<Shader> m_OutputShader;

        std::shared_ptr<Camera> m_Camera;

	    std::random_device rd;
	    std::mt19937 e2;
	    std::uniform_real_distribution<> dist;

        Quad m_Quad;

        void CreateDefaultFbTex(unsigned int& fbo, unsigned int& tex);
        void CreateAccumFbTex(unsigned int& fbo, unsigned int& tex);

        void CreateFramebuffers();
        void CreateShaders();
    public:
        Renderer(int width, int height);
        ~Renderer();
        
        void Draw(GLFWwindow* pWindow, float dt);
};