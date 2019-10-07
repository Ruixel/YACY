#include "LegacyObjects.h"

namespace Legacy {
    godot::PoolStringArray extractObjectProperties(godot::String objectStr) {
        godot::PoolStringArray objectProperties;
        
        // First, remove any excess characters (such as [ and ])
        godot::String cleanObjectStr = godot::String();
        int maxLength = objectStr.length() - 1;
        bool isInTextProperty = false;
        for (int c = 0; c < maxLength; c++) {
            wchar_t letter = objectStr[c];
            if ((letter != '[' and letter != ']') or isInTextProperty) {
                cleanObjectStr += godot::String(letter);
            }
            
            if (letter == '"') 
                isInTextProperty = !isInTextProperty;
        }
        
        // Afterwards, extract each property (incl. color and text types)
        int cIdx = 0;
        godot::String prop;
        maxLength = cleanObjectStr.length();
        while (cIdx < maxLength && objectProperties.size() < 15) {
            wchar_t c = cleanObjectStr[cIdx];
            
            // Check if it's a numerical value
            if (iswdigit(c) or c == '-') {
                int endIdx = cleanObjectStr.find(", ", cIdx);
                if (endIdx != -1) {
                    prop = cleanObjectStr.substr(cIdx, endIdx - cIdx);
                    cIdx = endIdx;
                } else {
                    prop = cleanObjectStr.substr(cIdx, maxLength - cIdx);
                    cIdx = maxLength;
                }
                
                objectProperties.append(prop);
                
            
            // Check if colour property
            } else if (c == 'c') {
                int endIdx = cleanObjectStr.find(")", cIdx);
                prop = cleanObjectStr.substr(cIdx, endIdx - cIdx);
                
                objectProperties.append(prop);
                cIdx = endIdx;
                
            // Check if text property
            } else if (c == '"') {
                int endIdx = cleanObjectStr.find("\"", cIdx + 1);
                prop = cleanObjectStr.substr(cIdx, endIdx - cIdx + 1);
                
                objectProperties.append(prop);
                cIdx = endIdx;
            }
            
            cIdx++;
        }
        
        return objectProperties;
    }

    
    void generateObjectList(godot::Spatial* worldAPI, godot::String objectName, godot::PoolStringArray objectArray)
    {
        godot::Godot::print("Obj size: " + godot::String::num(objectArray.size()));
        if (objectArray.size() == 0)
            return;
        
        const godot::String obj = objectArray[0];
        godot::PoolStringArray objectProperties = extractObjectProperties(obj);
        
        if (objectName == "walls") wall_createObject(worldAPI, objectArray, objectProperties.size());
        
    }
    
    inline godot::Vector2 extractVec2(godot::String x, godot::String y)
    {
        return godot::Vector2(x.to_float(), y.to_float());
    }
    
    inline int extractInt(godot::String integer)
    {
        return integer.to_int();
    }

    void wall_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize) 
    {
        godot::Godot::print("Hello world#$@!");
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            if      (objectSize == 8) worldAPI->call("create_wall", extractVec2(obj[0], obj[1]), extractVec2(obj[2], obj[3]), extractInt(obj[4]), extractInt(obj[7]));
            else if (objectSize == 7) worldAPI->call("create_wall", extractVec2(obj[0], obj[1]), extractVec2(obj[2], obj[3]), extractInt(obj[4]), extractInt(obj[6]));
        }
    }

}
