#pragma once

#include <memory>

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/core/class_db.hpp>

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

	PackedByteArray colour_image_data;
	PackedByteArray depth_image_data;

protected:
	static void _bind_methods();

public:
	static RealSense *get_singleton();

	RealSense();
	~RealSense();

	bool poll_frame();
	void open();
	void close();
	PackedByteArray get_colour_image();
	PackedByteArray get_depth_image();
};
