#pragma once

class Quad
{
    private:
        unsigned int m_VAO;
        unsigned int m_VBO;
    public:
        Quad();
        ~Quad();
        void Draw();
};