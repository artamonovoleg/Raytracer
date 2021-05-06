#version 330 core

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;
uniform mat4 u_view_projection;

out vec4 frag_color;

float near = 0.1;
float far = 300.0;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

struct Ray
{
	vec3 origin;
	vec3 direction;
};

struct Sphere
{
	vec3 center;
	float radius;
	vec3 color;
	vec3 emission;
};

Sphere CreateSphere(vec3 center, float radius, vec3 color)
{
	Sphere sphere;
	sphere.center = center;
	sphere.radius = radius;
	sphere.color = color;
	return sphere;
}

float SphereIntersection(Ray ray, Sphere sphere)
{
	vec3 oc = ray.origin - sphere.center;
	float a = dot(ray.direction, ray.direction);
	float b = dot(oc, ray.direction);
	float c = dot(oc, oc) - sphere.radius * sphere.radius;
	float discriminant = b * b - a * c;
	if (discriminant < 0)
		return 10000.0;
	else
		return (-b - sqrt(discriminant)) / a;
	
}

const int SPHERES_COUNT = 4;
Sphere spheres[SPHERES_COUNT];

float min_intersection_dist = 10000.0;

struct CastResult
{
	vec3 color;
	Ray ray;
	vec3 hit;
	vec3 normal;
	float it;
};

CastResult CastRay(Ray ray)
{
	float it = 10000.0;
	vec3 col = vec3(0.0, 0.0, 0.0);
	CastResult res;
	res.it = it;

	for (int i = 0; i < SPHERES_COUNT; ++i)
	{
		it = SphereIntersection(ray, spheres[i]);
		if (it > 0 && it < min_intersection_dist)
		{
			min_intersection_dist = it;
			col = spheres[i].color;
			res.hit = ray.origin + min_intersection_dist * ray.direction;
			res.it = it;
			res.normal = normalize(res.hit - spheres[i].center);
		}
	}
	
	res.color = col;
	res.ray = ray;
	return res;
}

vec4 SceneIntersect(Ray ray)
{
	vec3 color = vec3(0.0);
	vec3 mask = vec3(1.0);

	CastResult res;
	res.ray = ray;
	for (int i = 0; i < 10; i++)
	{
		res = CastRay(res.ray);
		if (res.it > 9000.0)
		{
			color += mask * vec3(1.0);
			break;
		}
		Ray newRay;
		newRay.origin = res.hit;

		vec2 co = gl_FragCoord.xy / u_resolution;
		vec2 dir = vec2(rand(co));
		dir.y = rand(dir);

		// newRay.direction = normalize(reflect(res.ray.direction, res.normal));
		newRay.direction = normalize(vec3(dir, rand(dir - co)));
		res.ray = newRay;

		/* the mask colour picks up surface colours at each bounce */
		mask *= res.color; 
		color += mask * vec3(0.0); // vec3 - emission

		/* perform cosine-weighted importance sampling for diffuse surfaces*/
		mask *= dot(newRay.direction, res.normal); 
	}

	return vec4(color, 1.0);
}

void main()
{
	float aspect_ratio = u_resolution.x / u_resolution.y;
	vec2 coord = (gl_FragCoord.xy / u_resolution) - vec2(0.5);

	float ndcDepth = far - near;
	float ndcSum = far + near;
    vec4 camRay = inverse(u_view_projection) * vec4(coord * ndcDepth, ndcSum, ndcDepth);
    vec4 camOrigin = inverse(u_view_projection) * vec4(coord, -1.0, 1.0 );

    Ray ray;
    ray.origin = camOrigin.xyz;
    ray.direction = normalize(camRay).xyz;

	spheres[0] = CreateSphere(vec3(-0.4, -0.2, -1.5), 0.4, vec3(1.0));
	spheres[1] = CreateSphere(vec3(0.2, -0.3, -2.0), 0.4, vec3(0.3, 0.2, 0.4));
	spheres[2] = CreateSphere(vec3(0.5, 0.3, -3.0), 1.0, vec3(0.63, 0.88, 0.66));
	spheres[3] = CreateSphere(vec3(-0.7, 0.0, -2.0), 0.6, vec3(0.96, 0.65, 0.84));

	frag_color = SceneIntersect(ray);
}