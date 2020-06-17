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
            if ((letter != '[' && letter != ']') || isInTextProperty) {
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
            if (iswdigit(c) || c == '-') {
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

    
    void generateObjectList(godot::Node* worldAPI, godot::String objectName, godot::PoolStringArray objectArray)
    {
        godot::Godot::print("Obj size: " + godot::String::num(objectArray.size()));
        if (objectArray.size() == 0)
            return;
        
        const godot::String obj = objectArray[0];
        godot::PoolStringArray objectProperties = extractObjectProperties(obj);
        
        objectName = objectName.to_lower();
        
        if (objectName == "walls") wall_createObject(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "plat") plat_createObject(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "triplat") triplat_createObject(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "diaplat") diaplat_createObject(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "floor") ground_createObject(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "triwall") triwall_createObject(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "pillar") pillar_createObject(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "ramp") ramp_createObject(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "hole") hole_createObject(worldAPI, objectArray, objectProperties.size());
        
        else if (objectName == "begin") start_createEntity(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "board") message_createEntity(worldAPI, objectArray, objectProperties.size());
        else if (objectName == "portal") portal_createEntity(worldAPI, objectArray, objectProperties.size());
    }
    
    inline godot::Vector2 extractVec2(godot::String x, godot::String y)
    {
        return godot::Vector2(x.to_float(), y.to_float());
    }
    
    inline int extractInt(godot::String integer)
    {
        return integer.to_int();
    }
    
    inline godot::String extractStr(godot::String str)
    {
        return str;
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
    void wall_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize) 
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
    void plat_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize) 
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                      // Position                  // Size             // Material               // Height           // Shape  // Level
            if      (objectSize == 6) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractTexColour(obj[3]), extractInt(obj[4]), 0,        extractInt(obj[5]));
            else if (objectSize == 5) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractTexColour(obj[3]), 1,                  0,        extractInt(obj[4]));
            else if (objectSize == 4) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), 5,                        1,                  0,        extractInt(obj[3]));
        }
    }

    // Ground
    // [x1, y1, x2, y2, x3, y3, x4, y4, floor_material, isVisible, ceil_material]
    void ground_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize) 
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                       // Position 1                 // Position 2                // Position 3                // Position 4                // Floor Material         // Is Visible       // Ceiling Material        // Level
            if      (objectSize == 11) worldAPI->call("create_floor", extractVec2(obj[0], obj[1]), extractVec2(obj[2], obj[3]), extractVec2(obj[4], obj[5]), extractVec2(obj[6], obj[7]), extractTexColour(obj[8]), extractInt(obj[9]), extractTexColour(obj[10]), i + 1);
        }
    }
    
    // Diamond Platform
    // [position_x, position_y, size, material, height, level]
    void diaplat_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize) 
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                      // Position                  // Size             // Material               // Height           // Shape  // Level
            if      (objectSize == 6) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractTexColour(obj[3]), extractInt(obj[4]), 1,        extractInt(obj[5]));
            else if (objectSize == 5) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractTexColour(obj[3]), 1,                  1,        extractInt(obj[4]));
            else if (objectSize == 4) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), 5,                        1,                  1,        extractInt(obj[3]));
        }
    }
    
    // Triangular Platform
    // [position_x, position_y, size, material, height, direction, level]
    void triplat_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize) 
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                      // Position                  // Size             // Material               // Height           // Shape                // Level
            if      (objectSize == 7) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractTexColour(obj[3]), extractInt(obj[5]), 1 + extractInt(obj[4]), extractInt(obj[6]));
            else if (objectSize == 6) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractTexColour(obj[3]), 1,                  1 + extractInt(obj[4]), extractInt(obj[5]));
            else if (objectSize == 5) worldAPI->call("create_plat", extractVec2(obj[0], obj[1]), extractInt(obj[2]), 5,                        1,                  1 + extractInt(obj[3]), extractInt(obj[4]));
        }
    }

    // TriWalls 
    // [position_x, position_y, inverted, material, direction, level]
    void triwall_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize)
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
    void pillar_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize)
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                        // Position                  // isDiagonal       // Size             // Material               // Height           // Level
            if      (objectSize == 7) worldAPI->call("create_pillar", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractInt(obj[4]), extractTexColour(obj[3]), extractInt(obj[5]), extractInt(obj[6]));
            else if (objectSize == 4) worldAPI->call("create_pillar", extractVec2(obj[0], obj[1]), 1,                  1,                  extractTexColour(obj[2]), 1,                  extractInt(obj[3]));
        }
    }

    // Ramp
    // [position_x, position_y, direction, material, level]
    void ramp_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize)
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                      // Position                  // Direction        // Material               // Level
            if      (objectSize == 5) worldAPI->call("create_ramp", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractTexColour(obj[3]), extractInt(obj[4]));    
            else if (objectSize == 4) worldAPI->call("create_ramp", extractVec2(obj[0], obj[1]), extractInt(obj[2]), 5,                        extractInt(obj[3])); 
        }
    }
    
    // Hole
    // [position_x, position_y, size, level]
    void hole_createObject(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize)
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                      // Position                  // Size             // Level
            if      (objectSize == 4) worldAPI->call("create_hole", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractInt(obj[3])); 
        }
    }
    
    // Begin (Spawn location)
    // [position_x, position_y, direction, level]
    void start_createEntity(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize)
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            //                             // Position                  // Direction        // Level
            worldAPI->call("create_spawn", extractVec2(obj[0], obj[1]), extractInt(obj[2]), extractInt(obj[3]));    
        }
    }
    
    // Message board
    // [position_x, position_y, message, direction, height, level]
    void message_createEntity(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize)
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                          // Position                  // Message          // Direction     // Height               // Level
            if      (objectSize == 6) worldAPI->call("create_msgBoard", extractVec2(obj[0], obj[1]), extractStr(obj[2]), extractInt(obj[3]), extractInt(obj[4]), extractInt(obj[5]));    
            else if (objectSize == 5) worldAPI->call("create_msgBoard", extractVec2(obj[0], obj[1]), extractStr(obj[2]), extractInt(obj[3]), 1,                  extractInt(obj[4])); 
        }
    }
    
    // Portal
    // [position_x, position_y, title, condition, gameNumber, level]
    void portal_createEntity(godot::Node* worldAPI, godot::PoolStringArray objectArray, int objectSize)
    {
        int objects = objectArray.size();
        for (int i = 0; i < objects; i++) {
            godot::PoolStringArray obj = extractObjectProperties(objectArray[i]);
            
            //                                                          // Position                  // Title           // Condition         // GameNumber       // Level
            if      (objectSize == 6) worldAPI->call("create_portal", extractVec2(obj[0], obj[1]), extractStr(obj[2]), extractInt(obj[3]), extractStr(obj[4]), extractInt(obj[5]));    
        }
    }

}
