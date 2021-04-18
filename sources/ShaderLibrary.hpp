#pragma once
#include <unordered_map>
#include <glad/glad.h>
#include "Shader.hpp"

class ShaderLibrary
{
    private:
        std::unordered_map<std::string, Shader> m_Shaders;
    public:
        void Load(const std::string& name, const std::string& vertPath, const std::string& fragPath);
        Shader* Get(const std::string& name);
};