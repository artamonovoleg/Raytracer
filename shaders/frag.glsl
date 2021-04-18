#version 330 core

uniform vec2 u_resolution;
uniform float u_time;

out vec4 fragColor;

vec3 lightPos = vec3(0.0, 0.0, 2.0);


struct Ray
{
	vec3 origin;
	vec3 direction;
};

struct Material
{
	vec3 color;
	vec3 albedo;
};

struct Sphere
{
	vec3 center;
	float radius;
	Material mat;
};

Sphere objects [2];

vec3 HitSphere(Ray ray, Sphere sphere)
{
	vec3 oc = ray.origin - sphere.center;
	float a = dot(ray.direction, ray.direction);
	float b = dot(oc, ray.direction);
	float c = dot(oc, oc) - sphere.radius * sphere.radius;
	float discriminant = b * b - a * c;

	if (discriminant > 0.0)
	{
		float t = (- b - discriminant) / a;
		vec3 hit = (ray.origin + t * ray.direction);
		vec3 N = normalize(hit - sphere.center);
		float diffuse = dot(normalize(lightPos - hit), N);
		return sphere.mat.color * diffuse;
	}
	else
	{
		return vec3(0.0);
	}
}

void main()
{
	float aspectRatio = u_resolution.x / u_resolution.y;
	vec2 coord = gl_FragCoord.xy / u_resolution - vec2(0.5);	
	coord.x *= aspectRatio;

	Material mat;
	mat.color = vec3(1.0, 0.3, 0.4);
	mat.albedo = vec3(1.0);

	Sphere sp;
	sp.center = vec3(0, 0, -1.0);
	sp.radius = 0.2;
	sp.mat = mat;
	
	objects[0] = sp;
	sp.center = vec3(0.5, 0, -1.0);
	objects[1] = sp;

	Ray ray;
	ray.origin = vec3(0, 0, 0);
	ray.direction = normalize(vec3(coord, -1.0));

	lightPos += vec3(cos(u_time), 0, 0);

	vec3 color;

	for (int i = 0; i < 2; ++i)
	{
		color = HitSphere(ray, objects[i]);
		if (color != vec3(0.0))
			break;
	}

	fragColor = vec4(color, 1.0);
}