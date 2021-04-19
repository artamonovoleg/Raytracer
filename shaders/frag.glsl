#version 330 core

uniform vec2 u_resolution;
uniform float u_time;
out vec4 frag_color;

const int BIT_COUNT = 8;

int modi(int x, int y) 
{
	return x - y * (x / y);
}

int or(int a, int b) {
    int result = 0;
    int n = 1;

    for (int i = 0; i < BIT_COUNT; i++) 
	{
        if ((modi(a, 2) == 1) || (modi(b, 2) == 1)) 
            result += n;
        a = a / 2;
        b = b / 2;
        n = n * 2;

        if (!(a > 0 || b > 0))
            break;
    }
    return result;
}

int and(int a, int b) 
{
    int result = 0;
    int n = 1;

    for (int i = 0; i < BIT_COUNT; i++) 
	{
        if ((modi(a, 2) == 1) && (modi(b, 2) == 1))
            result += n;

        a = a / 2;
        b = b / 2;
        n = n * 2;

        if (!(a > 0 && b > 0))
            break;
    }
    return result;
}

int not(int a) 
{
    int result = 0;
    int n = 1;
    
    for (int i = 0; i < BIT_COUNT; i++) 
	{
        if (modi(a, 2) == 0) 
            result += n;    
        a = a / 2;
        n = n * 2;
    }
    return result;
}

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

vec3 CheckerBoard(Ray ray, vec3 previous_color)
{
	if (abs(ray.direction.y) > 1 * pow(10, -3))
	{
		float d = -(ray.origin.y + 4.0) / ray.direction.y; // the checkerboard plane has equation y = -4
        vec3 pt = ray.origin + ray.direction * d;

        if (d > 0.0 && abs(pt.x) < 10.0 && pt.z < -10.0 && pt.z >- 30.0) 
		{
            float checkerboard_dist = d;
			if (checkerboard_dist > min_hit_distance)
				return previous_color;

            vec3 hit = pt;
            vec3 N = vec3(0.0, 1.0, 0.0);

			int val = int(0.5 * hit.x + 1000.0) + int(0.5 * hit.z);

			if (and(val, 1) == 1)
				return vec3(1.0) * 0.3;
			else
				return vec3(1.0, 0.7, 0.3) * 0.3;
        }
	}

	return previous_color;
}

vec3 SceneIntersect(in Ray ray)
{
	vec3 color = sky_color;

	// Spheres intersection
	for (int s = 0; s < SPHERES_COUNT; ++s)
	{
		float t = HitSphere(ray, spheres[s]);

		if (t > 0.0 && t < min_hit_distance)
		{
			vec3 hit = ray.origin + t * ray.direction;
			vec3 N = normalize(hit - spheres[s].center);

			vec3 diffuse_light = vec3(0.0);
			float specular;

			for (int l = 0; l < LIGHTS_COUNT; ++l)
			{
				diffuse_light += CalculateLight(lights[l], spheres[s], N);
				specular = pow(max(0.0, dot(reflect(normalize(lights[l].position), N), ray.direction)), 64.0);
			}
			
			color = spheres[s].material.color * diffuse_light * spheres[s].material.albedo[0] + vec3(1.0) * specular * spheres[s].material.albedo[1];
		
			min_hit_distance = t;
		}
	}

	// Draw checkerboard
	color = CheckerBoard(ray, color);

	return color;
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
	ray.origin = vec3(0.0, 0.0, 0.0);
	ray.direction = normalize(vec3(coord, -1.0));

	// change light position for better understanding
	lights[0].position = vec3(cos(u_time), 0.0, 0.0);

	frag_color = vec4(SceneIntersect(ray), 1.0);
}