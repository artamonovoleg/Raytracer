#version 330 core

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;
uniform mat4 u_view_projection;
uniform sampler2D u_acc;
uniform vec2 u_seed1;
uniform vec2 u_seed2;

in vec2 texCoord;
out vec4 frag_color;

float near = 0.1;
float far = 300.0;

uvec4 R_STATE;

uint TausStep(uint z, int S1, int S2, int S3, uint M)
{
	uint b = (((z << S1) ^ z) >> S2);
	return (((z & M) << S3) ^ b);	
}

uint LCGStep(uint z, uint A, uint C)
{
	return (A * z + C);	
}

vec2 hash22(vec2 p)
{
	p += u_seed1.x;
	vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
	p3 += dot(p3, p3.yzx+33.33);
	return fract((p3.xx+p3.yz)*p3.zy);
}

float random()
{
	R_STATE.x = TausStep(R_STATE.x, 13, 19, 12, uint(4294967294));
	R_STATE.y = TausStep(R_STATE.y, 2, 25, 4, uint(4294967288));
	R_STATE.z = TausStep(R_STATE.z, 3, 11, 17, uint(4294967280));
	R_STATE.w = LCGStep(R_STATE.w, uint(1664525), uint(1013904223));
	return 2.3283064365387e-10 * float((R_STATE.x ^ R_STATE.y ^ R_STATE.z ^ R_STATE.w));
}

vec3 randomOnSphere() {
	vec3 rand = vec3(random(), random(), random());
	float theta = rand.x * 2.0 * 3.14159265;
	float v = rand.y;
	float phi = acos(2.0 * v - 1.0);
	float r = pow(rand.z, 1.0 / 3.0);
	float x = r * sin(phi) * cos(theta);
	float y = r * sin(phi) * sin(theta);
	float z = r * cos(phi);
	return vec3(x, y, z);
}


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
	vec3 col = vec3(0);
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
	vec3 color = vec3(0.0, 0.0, 0.0);
	vec3 mask = vec3(1.0);

	CastResult res;
	res.ray = ray;
	for (int i = 0; i < 8; i++)
	{
		res = CastRay(res.ray);
		if (res.it > 9000.0)
		{
			color += mask * vec3(0.25);
			break;
		}
		Ray newRay;
		newRay.origin = res.hit;

		vec2 co = gl_FragCoord.xy / u_resolution;
        vec3 dir = vec3(random() * co.x, random() * co.y, random() * u_time);
		newRay.direction = normalize(dir);
		res.ray = newRay;

		/* the mask colour picks up surface colours at each bounce */
		mask *= res.color; 
		color += mask * vec3(1.0); // vec3 - emission

		/* perform cosine-weighted importance sampling for diffuse surfaces*/
		mask *= dot(newRay.direction, res.normal); 
	}

	return vec4(color, 1.0);
}

void main()
{
	float aspect_ratio = u_resolution.x / u_resolution.y;
	vec2 coord = (gl_FragCoord.xy / u_resolution) - vec2(0.5);

    vec2 uvRes = hash22(coord + 1.0) * u_resolution + u_resolution;
	R_STATE.x = uint(u_seed1.x + uvRes.x);
	R_STATE.y = uint(u_seed1.y + uvRes.x);
	R_STATE.z = uint(u_seed2.x + uvRes.y);
	R_STATE.w = uint(u_seed2.y + uvRes.y);

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

	vec3 col = SceneIntersect(ray).rgb;
	frag_color = vec4(col, 1.0);
}