#version 330 core

uniform vec2 u_resolution;
uniform float u_time;
uniform vec3 u_position;
uniform vec2 u_mouse;

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
	vec3 emission;
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
	vec3 emission;
	vec3 hit;
	vec3 normal;
	vec3 mask;
	float cosine;
};

CastResult SphereCast(Ray ray)
{
	
	CastResult res;
	vec3 color = vec3(0.0);
	for (int s = 0; s < SPHERES_COUNT; ++s)
	{
		float t = HitSphere(ray, spheres[s]);

		if (t > 0.0 && t < min_hit_distance)
		{
			res.hit = ray.origin + t * ray.direction;
			res.normal = normalize(res.hit - spheres[s].center);
			color = spheres[s].material.color;
			res.emission = spheres[s].material.emission;
			min_hit_distance = t;
			// res.cosine = dot(normalize(light.position - sphere.center), normal)
		}
	}

	res.color = color;
	return res;
}

vec3 SceneIntersect(Ray ray)
{
	vec3 color = vec3(0.0);
	vec3 mask = vec3(1.0);

	for (int i = 0; i < 1; ++i)
	{
		CastResult res = SphereCast(ray);
		vec3 new_dir = normalize(reflect(ray.direction, res.normal));
		float cosine = dot(new_dir, ray.direction);
		ray.origin = res.hit;
		ray.direction = new_dir;
	
		if (length(res.emission) != 0.0)
		{
			return res.color;
		}

		color += res.color *  mask;
		mask *= color * cosine;
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
	sphere.center = vec3(-0.3, 0.0, -1.0);
	sphere.radius = 0.2;
	sphere.material = mat;
	sphere.material.emission = vec3(0.4, 0.4, 0.4);
	spheres[0] = sphere;

	sphere.radius = 0.2;
	sphere.material.color = vec3(0.3, 0.2, 0.2);
	sphere.material.albedo = vec2(1.0, 0.0);
	sphere.center = vec3(0.3, 0.0, -1.0);

	spheres[1] = sphere;
	spheres[1].material.emission = vec3(0.0);
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
	ray.origin = u_position;
	ray.direction = normalize(vec3(coord, -1.0));
	vec2 mouse = u_mouse / u_resolution;

	ray.direction.zx *= rot(-mouse.x) * 1.2;
	ray.direction.yz *= rot(-mouse.y) * 1.2;

	frag_color = vec4(SceneIntersect(ray), 1.0);
}