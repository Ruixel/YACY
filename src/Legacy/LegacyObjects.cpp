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
            if (iswdigit(c)) {
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
