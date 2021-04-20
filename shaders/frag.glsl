#version 330 core

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform vec3 u_pos;
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
	vec2 albedo;
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

// need to find nearest object
float min_hit_distance = MAX_HIT_DISTANCE;

vec3 sky_color = vec3(0.2, 0.7, 0.8);

vec3 CalculateLight(Light light, Sphere sphere, vec3 normal)
{
	return dot(normalize(light.position - sphere.center), normal) * light.color;
}

struct CastResult
{
	vec3 color;
	vec3 hit;
	vec3 normal;
};

CastResult SphereCast(Ray ray)
{
	vec3 color = sky_color;

	CastResult res;

	for (int s = 0; s < SPHERES_COUNT; ++s)
	{
		float t = HitSphere(ray, spheres[s]);

		if (t > 0.0 && t < min_hit_distance)
		{
			res.hit = ray.origin + t * ray.direction;
			res.normal = normalize(res.hit - spheres[s].center);

			vec3 diffuse_light = vec3(0.0);
			float specular;

			for (int l = 0; l < LIGHTS_COUNT; ++l)
			{
				diffuse_light += CalculateLight(lights[l], spheres[s], res.normal);
				specular = pow(max(0.0, dot(reflect(normalize(lights[l].position), res.normal), ray.direction)), 64.0);
			}
			
			color = spheres[s].material.color * diffuse_light * spheres[s].material.albedo[0] + vec3(1.0) * specular * spheres[s].material.albedo[1];

			min_hit_distance = t;
		}
	}

	res.color = color;
	return res;
}

vec3 SceneIntersect(Ray ray)
{
	vec3 color = vec3(1.0);

	for (int i = 0; i < 2; ++i)
	{
		CastResult res = SphereCast(ray);
		ray.origin = res.hit;
		ray.direction = normalize(reflect(res.hit, res.normal));
		color *= res.color;
	}

	return color;
}

mat2 rot(float a) 
{
	float s = sin(a);
	float c = cos(a);
	return mat2(c, -s, s, c);
}

void main()
{
	float aspect_ratio = u_resolution.x / u_resolution.y;
	vec2 coord = gl_FragCoord.xy / u_resolution - vec2(0.5);
	coord.x *= aspect_ratio;
	/// Create scene objects
	Material mat;
	mat.color = vec3(0.2, 0.3, 0.4);
	mat.albedo = vec2(1.0);

	Sphere sphere;
	sphere.center = vec3(-0.2, 0.0, -1.0);
	sphere.radius = 0.2;
	sphere.material = mat;

	spheres[0] = sphere;

	sphere.radius = 0.2;
	sphere.material.color = vec3(0.3, 0.2, 0.2);
	sphere.material.albedo = vec2(1.0, 0.0);
	sphere.center = vec3(0.3, 0.0, -1.0);

	spheres[1] = sphere;
	///

	/// Create scene light
	Light light;
	light.position = vec3(0.0);
	light.color = vec3(1.0);
	lights[0] = light;

	light.position = vec3(1.0, 0.0, 0.0);
	lights[1] = light;
	///

	// Create ray
	Ray ray;
	ray.origin = vec3(u_pos.x, 0.0, u_pos.y);
	ray.direction = normalize(vec3(coord, -1.0));
	vec2 mouse = u_mouse / u_resolution;
	ray.direction.zx *= rot(-mouse.x);
	ray.direction.yz *= rot(-mouse.y);

	frag_color = vec4(SceneIntersect(ray), 1.0);
}