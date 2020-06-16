#ifndef LEGACYOBJECTS_H_INCLUDED
#define LEGACYOBJECTS_H_INCLUDED

#include <Node.hpp>
#include <PoolArrays.hpp>
#include <Vector2.hpp>
#include <Color.hpp>
#include <Variant.hpp>

namespace Legacy {
    godot::PoolStringArray extractObjectProperties(godot::String objectStr);
    void generateObjectList(godot::Node* worldAPI, godot::String objectName, godot::PoolStringArray objectArray);
    
    // Extraction functions
    struct material {
        int texture;
        godot::Color colour;
    };
    
    inline godot::Vector2 extractVec2(godot::String x, godot::String y);
    inline int extractInt(godot::String integer);
    inline godot::String extractStr(godot::String str);
    godot::Variant extractTexColour(godot::String str);

    // Object creation functions
    void wall_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void triwall_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void plat_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void diaplat_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void triplat_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void ground_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void pillar_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void ramp_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void hole_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    
    // Entitiy creation functions
    void start_createEntity(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void message_createEntity(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
    void portal_createEntity(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize);
}
    
#endif // LEGACYOBJECTS_H_INCLUDED
