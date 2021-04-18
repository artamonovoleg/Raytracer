#version 330 core

uniform vec2 u_resolution;
uniform float u_time;

out vec4 frag_color;

struct Ray
{
	vec3 origin;
	vec3 direction;
};

struct Light
{
	vec3 position;
	vec3 color;
};

struct Material
{
	vec3 color;
};

struct Sphere
{
	vec3 center;
	float radius;
	Material material;
};

float HitSphere(Ray ray, Sphere sphere)
{
	vec3 oc = ray.origin - sphere.center;
	float a = dot(ray.direction, ray.direction);
	float b = dot(oc, ray.direction);
	float c = dot(oc, oc) - sphere.radius * sphere.radius;
	float discriminant = b * b - a * c;
	if (discriminant < 0)
		return -1.0;
	else
		return (-b - sqrt(discriminant)) / a;
}

const int MAX_HIT_DISTANCE = 1000;
const int SPHERES_COUNT = 2;
Sphere spheres[SPHERES_COUNT];

const int LIGHTS_COUNT = 2;
Light lights[LIGHTS_COUNT];


vec3 CalculateLight(Light light, Sphere sphere, vec3 normal)
{
	return dot(normalize(light.position - sphere.center), normal) * light.color;
}

void main()
{
	float aspect_ratio = u_resolution.x / u_resolution.y;
	vec2 coord = gl_FragCoord.xy / u_resolution - vec2(0.5);	
	coord.x *= aspect_ratio;
	/// Create scene objects
	Material mat;
	mat.color = vec3(0.2, 0.3, 0.4);

	Sphere sphere;
	sphere.center = vec3(-0.2, 0.0, -1.0);
	sphere.radius = 0.2;
	sphere.material = mat;

	spheres[0] = sphere;

	sphere.radius = 0.2;
	sphere.material.color = vec3(0.3, 0.2, 0.2);
	sphere.center = vec3(0.3, 0.0, -1.0);

	spheres[1] = sphere;
	///

	/// Create scene light
	Light light;
	light.position = vec3(0.0);
	light.color = vec3(1.0, 0.0, 0.0);
	lights[0] = light;

	light.color = vec3(0.0, 0.0, 1.0);
	lights[1] = light;
	///

	vec3 color;

	// Create ray
	Ray ray;
	ray.origin = vec3(0.0, 0.0, 0.0);
	ray.direction = normalize(vec3(coord, -1.0));

	// need to find nearest object
	float min_hit_distance = MAX_HIT_DISTANCE;

	// change light position for better understanding
	lights[0].position = vec3(cos(u_time), 0.0, 0.0);
	lights[1].position = vec3(sin(u_time), 0.0, 0.0);

	for (int s = 0; s < SPHERES_COUNT; ++s)
	{
		float t = HitSphere(ray, spheres[s]);

		if (t > 0.0 && t < min_hit_distance)
		{
			vec3 hit = ray.origin + t * ray.direction;
			vec3 N = normalize(hit - spheres[s].center);

			vec3 diffuse_light = vec3(0.0);

			for (int l = 0; l < LIGHTS_COUNT; ++l)
				diffuse_light += CalculateLight(lights[l], spheres[s], N);
			
			color = spheres[s].material.color * diffuse_light;

			min_hit_distance = t;
		}
	}


	frag_color = vec4(color, 1.0);
}
