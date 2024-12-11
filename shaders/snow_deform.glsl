#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba8) uniform readonly image2D viewport;
layout(set = 0, binding = 1, r32f) uniform image2D memory;

void main() {
    ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
    float viewport_value = imageLoad(viewport, coord).r;

    float memory_value = imageLoad(memory, coord).r;
    
    if (viewport_value < 4.98f / 5.0f && memory_value < viewport_value) {
        imageStore(memory, coord, vec4(viewport_value));
    }
}

