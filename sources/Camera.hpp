#pragma once

#include <glm/glm.hpp>

struct GLFWwindow;

class Camera
{
    private:
        glm::vec3 m_Position;
        glm::vec3 m_ViewDirection = glm::vec3(0, 0, -1);
        glm::vec3 m_Up = glm::vec3(0, 1, 0);
        glm::vec3 m_Right;
        glm::vec3 m_WorldUp = glm::vec3(0, 1, 0);

        glm::mat4 m_Projection;
        glm::mat4 m_View;

        float m_Yaw = -90.0f;
        float m_Pitch = 0.0f;

        const float m_Speed = 0.5f;

        float lastX =  600.0f / 2.0f;
        float lastY =  500.0f / 2.0f;
        bool firstMouse = true;

        void RecalculateViewMatrix();
        void RecalculateVectors();
    public:
        Camera(const glm::vec3& position);

        void OnUpdate(GLFWwindow* pWindow, float dt);

        const glm::vec3& GetPosition() const { return m_Position; }
        const glm::vec3& GetViewDirection() const { return m_ViewDirection; }

        const glm::mat4& GetProjectionMatrix() const { return m_Projection; }
        const glm::mat4& GetViewMatrix() const { return m_View; }
};