#version 330 core

in vec2 texCoord;

uniform sampler2D u_sample;
uniform sampler2D u_acc;

out vec4 fragColor;

void main()
{
    vec3 color = texture(u_acc, texCoord).rgb + texture(u_sample, texCoord).rgb;
    fragColor = vec4(color, 1.0);
}