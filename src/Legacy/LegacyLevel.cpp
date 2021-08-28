#include "LegacyLevel.h"
#include <Godot.hpp>

// Parses Adobe Shockwave Lingo's file structure for CY levels
// This works by iterating through each #object, and 
void LegacyLevel::parseLevelCode(godot::String levelCode, godot::Node* worldApi) {
    int strPtr = 0; // String index
    int depth = 0;  // Depth inside brackets
    int objects = 0; // Keeps track of the number of objects in a level
    
    int levelCodeSize = levelCode.length();
    
    while(strPtr != levelCodeSize - 1) {
        wchar_t cChar = levelCode[strPtr];
        
        switch (cChar) {
            // Brackets represent objects or an array
            case '[': depth++; break;
            case ']': depth--; break;
            
            // This represents an object/list's name
            case '"':
            case '#':
                strPtr++;
                
                // Name is ended by a colon, use it to extract it as a string
                char strEndChar = cChar == '#' ? ':' : '"';
                int nameEndPos = levelCode.find(strEndChar, strPtr+1);
                int nameLength = nameEndPos - strPtr;
                godot::String name = levelCode.substr(strPtr, nameLength);
                
                godot::Godot::print("Extracted " + name);
                strPtr = nameEndPos + 2;
                if (strEndChar == '"') strPtr++;
                
                // Figure out if the object is a variant or a list
                if (levelCode[strPtr] == '[') {
                    // It's a list, extract the contents to be parsed separately
                    int listStartPtr = strPtr + 1;
                    int listDepth = depth;
                    
                    // Extract each object as a string
                    godot::PoolStringArray objStrings;
                    int objStartPtr = strPtr;
                    int objectDepth = depth+1;
                    
                    depth++; strPtr++;
                    
                    // Extract each object in the list 
                    bool isInTextProperty = false;
                    while (depth > listDepth && strPtr != levelCodeSize - 2) {
                        wchar_t c = levelCode[strPtr];
                        
                        // TODO: Problem arises if a string value has brackets, causing the depth to be incorrect
                        switch (c) {
                            case '[': 
                                if (isInTextProperty) break;
                                depth++; 
                                
                                // If new object, set point to the start of it
                                if (depth == objectDepth+1)
                                    objStartPtr = strPtr; 
                            break;
                            case ']': 
                                if (isInTextProperty) break;
                                depth--; 
                                
                                if (depth == objectDepth) {
                                    int objStrLength = strPtr - objStartPtr + 1;
                                    godot::String obj = levelCode.substr(objStartPtr, objStrLength);
                                    //godot::Godot::print("Extracted object: " + obj);
                                    objStrings.append(obj);
                                    
                                    objects++;
                                }
                                
                                break;
                            case '"':
                                isInTextProperty = !isInTextProperty;
                        }
                        strPtr++;
                    }
                    
                    Legacy::generateObjectList(worldApi, name, objStrings);
                        
                } else {
                    // It's a variant
                    strPtr = levelCode.find(",", strPtr);
                }
                
                break;
        }
        
        // Once the pointer reaches a depth of 0, the main object has finalised parsing
        if (depth == 0) {
            return;
        }
        
        strPtr++;
        //godot::Godot::print("pointer at " + godot::String::num(strPtr) + " with depth " + godot::String::num(depth));
    }
    
    godot::Godot::print("Found " + godot::String::num(objects) + " objects");
    worldApi->call_deferred("finalise");
}
