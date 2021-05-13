#include <GLFW/glfw3.h>
#include <glm/gtc/matrix_transform.hpp>
#include "Camera.hpp"

Camera::Camera(const glm::vec3& position)
    : m_Position(position)
{
    m_Projection = glm::perspective(glm::radians(45.0f), 600.0f / 500.0f, 0.1f, 80.0f);
    m_View = glm::lookAt(m_Position, m_Position - m_ViewDirection, m_Up);
}

void Camera::RecalculateViewMatrix()
{
    m_View = glm::lookAt(m_Position, m_Position - m_ViewDirection, m_Up);
}

void Camera::RecalculateVectors()
{
    glm::vec3 front;
    front.x = cos(glm::radians(m_Yaw)) * cos(glm::radians(m_Pitch));
    front.y = sin(glm::radians(m_Pitch));
    front.z = sin(glm::radians(m_Yaw)) * cos(glm::radians(m_Pitch));
    m_ViewDirection = glm::normalize(front);
    // also re-calculate the Right and Up vector
    m_Right = glm::normalize(glm::cross(m_ViewDirection, m_WorldUp));  // normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
    m_Up    = glm::normalize(glm::cross(m_Right, m_ViewDirection));
}

void Camera::OnUpdate(GLFWwindow* pWindow, float dt)
{

    if (glfwGetKey(pWindow, GLFW_KEY_W))
        m_Position -= m_Speed * m_ViewDirection * dt;
    if (glfwGetKey(pWindow, GLFW_KEY_S))
        m_Position += m_Speed * m_ViewDirection * dt;
    if (glfwGetKey(pWindow, GLFW_KEY_A))
        m_Position += glm::normalize(glm::cross(m_ViewDirection, m_Up)) * m_Speed * dt;
    if (glfwGetKey(pWindow, GLFW_KEY_D))
        m_Position -= glm::normalize(glm::cross(m_ViewDirection, m_Up)) * m_Speed * dt;

    double xpos;
    double ypos;
    glfwGetCursorPos(pWindow, &xpos, &ypos);

    if (firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }

    float xoffset = xpos - lastX;
    float yoffset = lastY - ypos; // reversed since y-coordinates go from bottom to top
    lastX = xpos;
    lastY = ypos;

    xoffset *= 0.1;
    yoffset *= 0.1;

    m_Yaw   += xoffset;
    m_Pitch += yoffset;

    if (m_Pitch > 89.0f)
        m_Pitch = 89.0f;
    if (m_Pitch < -89.0f)
        m_Pitch = -89.0f;

    RecalculateVectors();

    RecalculateViewMatrix();
}