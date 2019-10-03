#ifndef LEGACYOBJECTS_H_INCLUDED
#define LEGACYOBJECTS_H_INCLUDED

#include <Spatial.hpp>
#include <PoolArrays.hpp>

namespace Legacy {
    godot::PoolStringArray extractObjectProperties(godot::String object);
    void generateObjectList(godot::String objectName, godot::PoolStringArray objectArray);
    
    class GenericObject {
    public:
        void parseObjectArray(godot::PoolStringArray objectArray);
            
        virtual void createObject(godot::PoolStringArray propertyArray) = 0;
        virtual void addToScene(godot::Spatial* worldAPI) = 0;
    };
    
    class Wall : public GenericObject {
        virtual void createObject(godot::PoolStringArray propertyArray);
        virtual void addToScene(godot::Spatial* worldAPI);
    };
}
    
#endif // LEGACYOBJECTS_H_INCLUDED
