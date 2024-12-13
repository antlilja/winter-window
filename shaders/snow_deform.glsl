#[compute]
#version 450

layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout(push_constant, std430) uniform pc {
    float delta_time;
    float regen_rate;
};

layout(set = 0, binding = 0, rgba8) uniform readonly image2D viewport;
layout(set = 0, binding = 1, r32f) uniform readonly image2D noise;
layout(set = 0, binding = 2, r32f) uniform image2D memory;

void main() {
    ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
    float viewport_value = imageLoad(viewport, coord).r;
    float noise_value = imageLoad(noise, coord).r;
    float memory_value = imageLoad(memory, coord).r;
    
    float new_value = memory_value;
    if (viewport_value < memory_value) {
        new_value = viewport_value;
        noise_value = min(noise_value, viewport_value);
    }

    new_value += delta_time * regen_rate;
    new_value = min(new_value, noise_value);

    imageStore(memory, coord, vec4(new_value));
}
