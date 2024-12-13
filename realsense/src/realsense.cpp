#include "realsense.hpp"

#include <cstring>

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

#include <godot_cpp/classes/rendering_server.hpp>
// #include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/rd_texture_format.hpp>
#include <godot_cpp/classes/rd_texture_view.hpp>
// #include <godot_cpp/classes/rd_uniform.hpp>
// #include <godot_cpp/classes/rd_shader_file.hpp>
// #include <godot_cpp/classes/rd_shader_spirv.hpp>

using namespace godot;

RealSense *RealSense::singleton = nullptr;

void RealSense::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("process_frame"), &RealSense::process_frame);
	ClassDB::bind_method(D_METHOD("open"), &RealSense::open);
	ClassDB::bind_method(D_METHOD("close"), &RealSense::close);
	ClassDB::bind_method(D_METHOD("get_colour_texture"), &RealSense::get_colour_texture);
	ClassDB::bind_method(D_METHOD("get_depth_texture"), &RealSense::get_depth_texture);
}

RealSense *RealSense::get_singleton()
{
	return singleton;
}

RealSense::RealSense()
{
	ERR_FAIL_COND(singleton != nullptr);
	singleton = this;

	colour_image = Image::create_empty(1280, 720, false, Image::FORMAT_RGB8);
	colour_image_texture = ImageTexture::create_from_image(colour_image);

	depth_image_data.resize(1280 * 720 * 2);

	UtilityFunctions::print("RealSense library initialized");
}

RealSense::~RealSense()
{
	ERR_FAIL_COND(singleton != this);
	singleton = nullptr;
	
	UtilityFunctions::print("RealSense library uninitialized");
}

void RealSense::open()
{
	rs2::config cfg;
	cfg.enable_stream(RS2_STREAM_COLOR, 1280, 720, RS2_FORMAT_RGB8, 30);
	cfg.enable_stream(RS2_STREAM_DEPTH, 1280, 720, RS2_FORMAT_Z16, 30);
	auto profile = pipe.start(cfg);

	auto device = profile.get_device();
	auto depth_sensor = device.first<rs2::depth_sensor>();
	depth_sensor.set_option(RS2_OPTION_LASER_POWER, 0.f);

	bool found_colour_stream = false;
	for(const auto& sp : profile.get_streams()) {
	  rs2_stream profile_stream = sp.stream_type();
	  if (profile_stream == RS2_STREAM_COLOR)
    {
    	align = std::make_unique<rs2::align>(profile_stream);
    	found_colour_stream = true;
    	break;
    }
	}

	ERR_FAIL_COND(!found_colour_stream);

	RenderingServer* rs = RenderingServer::get_singleton();
	rd = rs->get_rendering_device();

	// ResourceLoader* rl = ResourceLoader::get_singleton();

	// Ref<RDShaderFile> shader_file = rl->load("res://shaders/convert_depth.glsl");
	// Ref<RDShaderSPIRV> shader_spirv = shader_file->get_spirv();
	// RID shader = rd->shader_create_from_spirv(shader_spirv);

	// pipeline = rd->compute_pipeline_create(shader);

	// Input depth texture
	Ref<RDTextureFormat> depth_format;
	depth_format->set_width(1280);
	depth_format->set_height(720);
	depth_format->set_usage_bits(
															RenderingDevice::TEXTURE_USAGE_SAMPLING_BIT | 
															RenderingDevice::TEXTURE_USAGE_STORAGE_BIT | 
															RenderingDevice::TEXTURE_USAGE_CAN_UPDATE_BIT
	);
	depth_format->set_format(RenderingDevice::DATA_FORMAT_R16_UINT);
	Ref<RDTextureView> depth_texture_view;
	depth_texture_rid = rd->texture_create(depth_format, depth_texture_view);
	depth_texture->set_texture_rd_rid(depth_texture_rid);

	// // Output depth texture
	// Ref<RDTextureFormat> output_depth_format;
	// output_depth_format->set_width(1280);
	// output_depth_format->set_height(720);
	// output_depth_format->set_usage_bits(
	// 																	RenderingDevice::TEXTURE_USAGE_SAMPLING_BIT | 
	// 																	RenderingDevice::TEXTURE_USAGE_STORAGE_BIT |
	// 																	RenderingDevice::TEXTURE_USAGE_COLOR_ATTACHMENT_BIT 
	// );
	// output_depth_format->set_format(RenderingDevice::DATA_FORMAT_R32_SFLOAT);
	// Ref<RDTextureView> output_depth_texture_view;
	// output_depth_texture_rid = rd->texture_create(output_depth_format, output_depth_texture_view);
	// output_depth_texture->set_texture_rd_rid(output_depth_texture_rid);

	// // Uniform set
	// Ref<RDUniform> input_depth_uniform;
	// input_depth_uniform->set_binding(0);
	// input_depth_uniform->set_uniform_type(RenderingDevice::UNIFORM_TYPE_IMAGE);
	// input_depth_uniform->add_id(input_depth_texture_rid);

	// Ref<RDUniform> output_depth_uniform;
	// output_depth_uniform->set_binding(1);
	// output_depth_uniform->set_uniform_type(RenderingDevice::UNIFORM_TYPE_IMAGE);
	// output_depth_uniform->add_id(output_depth_texture_rid);

	// TypedArray<RDUniform> uniforms;
	// uniforms.append(input_depth_uniform);
	// uniforms.append(output_depth_uniform);
	// uniform_set = rd->uniform_set_create(uniforms, shader, 0);
}

void RealSense::close()
{
	pipe.stop();
}

void RealSense::process_frame()
{
	if(pipe.poll_for_frames(&frames)) {
		auto aligned = align->process(frames);

		auto depth = aligned.get_depth_frame();
		depth = hole_filter.process(depth);
		//depth = spatial_filter.process(depth);
		//depth = temporal_filter.process(depth);
		
		auto colour = aligned.get_color_frame();
		memcpy(colour_image->ptrw(), colour.get_data(), colour.get_width() * colour.get_height() * colour.get_bytes_per_pixel());
		colour_image_texture->update(colour_image);

		memcpy(depth_image_data.begin().operator->(), depth.get_data(), 1280 * 720 * 2);
		rd->texture_update(depth_texture_rid, 0, depth_image_data);

		// auto list = rd->compute_list_begin();
		// rd->compute_list_bind_compute_pipeline(list, pipeline);
		// rd->compute_list_bind_uniform_set(list, uniform_set, 0);
		// rd->compute_list_dispatch(list, 1280, 720, 1);
		// rd->compute_list_end();

		// rd->submit();
		// rd->sync();
	} 
}

Ref<ImageTexture> RealSense::get_colour_texture()
{
  return colour_image;
}

Ref<Texture2DRD> RealSense::get_depth_texture()
{
  return depth_texture;
}
