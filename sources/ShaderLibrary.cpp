#include "ShaderLibrary.hpp"

void ShaderLibrary::Load(const std::string& name, const std::string& vertPath, const std::string& fragPath)
{
    m_Shaders.emplace(std::make_pair(name, Shader(vertPath, fragPath)));
}

Shader* ShaderLibrary::Get(const std::string& name)
{
    return &m_Shaders.at(name);
}