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
        else if (objectName == "Plat") plat_createObject(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "TriWall") triwall_createObject(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "Pillar") pillar_createObject(worldAPI, objectArray, objectProperties.size());
    }
    
    inline godot::Vector2 extractVec2(godot::String x, godot::String y)
    {
        return godot::Vector2(x.to_float(), y.to_float());
    }
    
    inline int extractInt(godot::String integer)
    {
        return integer.to_int();
    }
    
    // The CY save file will either use a user-defined colour or a texture
    godot::Variant extractTexColour(godot::String str)
    {
        // Check whether it's a texture (int) or a colour property (Color)
        if (str.is_valid_integer()) {
            return godot::Variant(str.to_int());
        } else {
            // Extract the Colour Property
            int valueEnd;
            int pointer = 7;
            
            auto getComponent = [&](float& cVal)
            {
                valueEnd = str.find(",", pointer);
                if (valueEnd != -1)
                    cVal = str.substr(pointer, valueEnd - pointer).to_float() / 255.f;
                else 
                    cVal = str.substr(pointer, str.length() - pointer).to_float() / 255.f;
                pointer = valueEnd + 2;
            };

            godot::Color colour;
            getComponent(colour.r);
            getComponent(colour.g);
            getComponent(colour.b);
            return godot::Variant(colour);
        }
    }


    // Wall
    // [displacement_x, displacement_y, start_x, start_y, front_material, back_material, height, level] 
    void wall_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize) 
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                      // Displacement              // Start Position            // Front Material         // Height           // Level
            if      (objectSize == 8) worldAPI->call("create_wall", extractVec2(obj[0], obj[1]), extractVec2(obj[2], obj[3]), extractTexColour(obj[4]), extractInt(obj[6]), extractInt(obj[7]));
            else if (objectSize == 7) worldAPI->call("create_wall", extractVec2(obj[0], obj[1]), extractVec2(obj[2], obj[3]), extractTexColour(obj[4]), 1,                  extractInt(obj[6]));
        }
    }
    
    // Platform
    // [position_x, position_y, size, material, height, level]
    void plat_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize) 
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                      // Position                  // Size             // Material               // Height           // Level
            if      (objectSize == 6) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractTexColour(obj[3]), extractInt(obj[4]), extractInt(obj[5]));
            else if (objectSize == 5) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractTexColour(obj[3]), 1,                  extractInt(obj[4]));
            else if (objectSize == 4) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), 5,                        1,                  extractInt(obj[3]));
        }
    }

    // TriWalls 
    // [position_x, position_y, inverted, material, direction, level]
    void triwall_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize)
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                               // Position                  // Is Inverted      // Mateiral               // Direction        // Level
            worldAPI->call("create_triwall", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractTexColour(obj[3]), extractInt(obj[4]), extractInt(obj[5]));
        }
    }
    // Pillars
    // [position_x, position_y, isDiagonal, material, size, height, level]
    void pillar_createObject(godot::Spatial* worldAPI, godot::PoolStringArray objectArray, int objectSize)
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                        // Position                  // isDiagonal       // Size             // Material               // Height           // Level
            if      (objectSize == 7) worldAPI->call("create_pillar", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractInt(obj[4]), extractTexColour(obj[3]), extractInt(obj[5]), extractInt(obj[6]));
            else if (objectSize == 4) worldAPI->call("create_pillar", extractVec2(obj[0], obj[1]), 1,                  1,                  extractTexColour(obj[2]), 1,                  extractInt(obj[3]));
        }
    }


}
