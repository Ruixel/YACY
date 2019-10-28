#ifndef LEGACYOBJECTS_H_INCLUDED
#define LEGACYOBJECTS_H_INCLUDED

#include <Spatial.hpp>
#include <PoolArrays.hpp>
#include <Vector2.hpp>
#include <Color.hpp>
#include <Variant.hpp>

namespace Legacy {
    godot::PoolStringArray extractObjectProperties(godot::String objectStr);
    void generateObjectList(godot::Spatial* worldAPI, godot::String objectName, godot::PoolStringArray objectArray);
    
    // Extraction functions
    struct material {
        int texture;
        godot::Color colour;
    };
    
    inline godot::Vector2 extractVec2(godot::String x, godot::String y);
    inline int extractInt(godot::String integer);
    godot::Variant extractTexColour(godot::String str);

    // Object creation functions
    void wall_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void triwall_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void plat_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void diaplat_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void triplat_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void pillar_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void ramp_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize);
}
    
#endif // LEGACYOBJECTS_H_INCLUDED
