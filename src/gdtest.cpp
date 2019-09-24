#include "gdtest.h"
#include <MultiplayerAPI.hpp>

using namespace godot;

void GDTest::_register_methods() {
	register_method("a_method", &GDTest::a_method);

//	register_property<GDTest, String>("data", &GDTest::_data, String("Hello world"));
	register_property<GDTest, String>("data", &GDTest::set_data, &GDTest::get_data, String("Hello world"));
    register_property<GDTest, int>("cat", &GDTest::_cat, 64);
}

void GDTest::_init() {
}

void GDTest::set_data(String new_data) {
	_data = new_data;
}

String GDTest::get_data() const {
	return _data;
}

String GDTest::a_method() {
    Godot::print ("Testing 123" + _data);
	return _data;
}
