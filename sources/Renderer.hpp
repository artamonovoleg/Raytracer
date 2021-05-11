#pragma once

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
        
        void CreateDefaultFbTex(unsigned int fbo, unsigned int tex);
    public:
        Renderer(int width, int height);
        ~Renderer();
};