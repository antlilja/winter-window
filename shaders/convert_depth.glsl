#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer DepthBufferIn {
	uint data[];
} depth_buffer_in;

layout(set = 0, binding = 1, std430) restrict buffer DepthBufferOut {
	float data[];
} depth_buffer_out;

void main() {
	uint data = depth_buffer_in.data[(gl_GlobalInvocationID.x + 848 * gl_GlobalInvocationID.y) / 2];
    vec2 unpacked = unpackUnorm2x16(data);
    if (gl_GlobalInvocationID.x % 2 == 0) {
        depth_buffer_out.data[gl_GlobalInvocationID.x + 848 * gl_GlobalInvocationID.y] = unpacked.x * 10.0f;
    } else {
        depth_buffer_out.data[gl_GlobalInvocationID.x + 848 * gl_GlobalInvocationID.y] = unpacked.y * 10.0f;  
    }
}

