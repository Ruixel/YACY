#ifndef LEGACYOBJECTS_H_INCLUDED
#define LEGACYOBJECTS_H_INCLUDED

#include <Spatial.hpp>
#include <PoolArrays.hpp>
#include <Vector2.hpp>
#include <Color.hpp>

namespace Legacy {
    godot::PoolStringArray extractObjectProperties(godot::String objectStr);
    void generateObjectList(godot::Spatial* worldAPI, godot::String objectName, godot::PoolStringArray objectArray);
    
    inline godot::Vector2 extractVec2(godot::String x, godot::String y);
    inline int extractInt(godot::String integer);
    godot::Color extractColour(godot::String colour);
    
    void wall_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize);
}
    
#endif // LEGACYOBJECTS_H_INCLUDED
