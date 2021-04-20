#pragma once

#include <glad/glad.h>
#include <glm/glm.hpp>

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

class Shader
{
    private:
        unsigned int m_ID;
        void CheckCompileErrors(unsigned int shader, std::string type);
    public:
        Shader(const std::string& vertexPath, const std::string& fragmentPath);

        void Bind() const;
        void Unbind() const;
        
        void SetInt(const std::string &name, int value) const;
        void SetFloat(const std::string& name, float value) const;
        void SetVec2(const std::string& name, const glm::vec2& vec) const;
        void SetVec3(const std::string& name, const glm::vec3& vec) const;
        void SetMat4(const std::string &name, const glm::mat4 &mat) const;
};