#include "realsense.hpp"

#include <cstring>

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

RealSense *RealSense::singleton = nullptr;

void RealSense::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("poll_frame"), &RealSense::poll_frame);
	ClassDB::bind_method(D_METHOD("open"), &RealSense::open);
	ClassDB::bind_method(D_METHOD("close"), &RealSense::close);
	ClassDB::bind_method(D_METHOD("get_colour_image"), &RealSense::get_colour_image);
	ClassDB::bind_method(D_METHOD("get_depth_image"), &RealSense::get_depth_image);
}

RealSense *RealSense::get_singleton()
{
	return singleton;
}

RealSense::RealSense()
{
	ERR_FAIL_COND(singleton != nullptr);
	singleton = this;

	colour_image_data.resize(1280 * 720 * 3);
	colour_image_data.fill(0);

	depth_image_data.resize(1280 * 720 * 2);
	depth_image_data.fill(0);

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
}

void RealSense::close()
{
	pipe.stop();
}

bool RealSense::poll_frame()
{
	if(pipe.poll_for_frames(&frames)) {
		auto aligned = align->process(frames);

		auto depth = aligned.get_depth_frame();
		depth = hole_filter.process(depth);
		//depth = spatial_filter.process(depth);
		//depth = temporal_filter.process(depth);
		
		auto colour = aligned.get_color_frame();
		memcpy(colour_image_data.begin().operator->(), colour.get_data(), colour.get_width() * colour.get_height() * colour.get_bytes_per_pixel());

		memcpy(depth_image_data.begin().operator->(), depth.get_data(), 1280 * 720 * 2);

		return true;
	} 

	return false;
}

PackedByteArray RealSense::get_colour_image()
{
  return colour_image_data;
}

PackedByteArray RealSense::get_depth_image()
{
  return depth_image_data;
}
