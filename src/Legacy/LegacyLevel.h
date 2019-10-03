#ifndef LEGACYLEVEL_H_INCLUDED
#define LEGACYLEVEL_H_INCLUDED

#include <Godot.hpp>
#include <GodotGlobal.hpp>
#include <PoolArrays.hpp>

#include "LegacyObjects.h"

class LegacyLevel {
    struct Header {
        godot::String title;
        godot::String author;
        float version;
    };
        
private:
    Header levelHeader;
    
public:
    void parseLevelCode(godot::String levelCode);
    
};


#endif // LEGACYLEVEL_H_INCLUDED