#version 330 core

in vec2 texCoord;

uniform sampler2D outputTexture;
uniform int u_fc;

out vec4 fragColor;

void main()
{
    fragColor = vec4((texture(outputTexture, texCoord).rgb) / float(u_fc), 1.0);
}