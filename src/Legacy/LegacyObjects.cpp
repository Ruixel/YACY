#include "LegacyObjects.h"

namespace Legacy {
    godot::PoolStringArray extractObjectProperties(godot::String object) {
        godot::PoolStringArray objectProperties;
        
        // First, remove any excess characters (such as [ and ])
        godot::String newObjectString = godot::String();
        int maxLength = object.length() - 1;
        for (int c = 0; c < maxLength; c++) {
            wchar_t letter = object[c];
            if (letter != '[' and letter != ']') {
                newObjectString += godot::String(letter);
            }
        }
        
        // Split an object's properties into a new PoolStringArray
        godot::Godot::print(newObjectString);
        objectProperties = newObjectString.split(", ");
        int maxIndex = objectProperties.size();
        for (int i = 0; i < maxIndex; i++) 
            godot::Godot::print("Extracted property '" + godot::String::num(i) + "' with value: " + objectProperties[i]);
            
        return objectProperties;
    }

    
    void generateObjectList(godot::String objectName, godot::PoolStringArray objectArray)
    {
        godot::Godot::print("Obj size: " + godot::String::num(objectArray.size()));
        if (objectArray.size() == 0)
            return;
        
        const godot::String obj = objectArray[0];
        godot::PoolStringArray objectProperties = extractObjectProperties(obj);
    }

}
