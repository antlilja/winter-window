#pragma once

#include <memory>

#include <godot_cpp/core/class_db.hpp>

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/classes/rendering_device.hpp>
#include <godot_cpp/classes/texture2drd.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/image_texture.hpp>

#include <godot_cpp/variant/packed_byte_array.hpp>

#include <librealsense2/rs.hpp>

using namespace godot;

class RealSense : public Object
{
	GDCLASS(RealSense, Object);

	static RealSense *singleton;

	rs2::frameset frames;
	rs2::context context;
	rs2::pipeline pipe;
	std::unique_ptr<rs2::align> align;
	rs2::hole_filling_filter hole_filter;
	//rs2::spatial_filter spatial_filter;
	//rs2::temporal_filter temporal_filter;

	RenderingDevice* rd;
	// RID pipeline;
	// RID uniform_set;

	Ref<Image> colour_image;
	Ref<ImageTexture> colour_image_texture;

	PackedByteArray depth_image_data;
	RID depth_texture_rid;
	Ref<Texture2DRD> depth_texture;
	// RID output_depth_texture_rid;
	// Ref<Texture2DRD> output_depth_texture;

protected:
	static void _bind_methods();

public:
	static RealSense *get_singleton();

	RealSense();
	~RealSense();

	void process_frame();
	void open();
	void close();
	Ref<ImageTexture> get_colour_texture();
	Ref<Texture2DRD> get_depth_texture();
};
