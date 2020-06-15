#ifndef LEGACYWORLDLOADER_H_INCLUDED
#define LEGACYWORLDLOADER_H_INCLUDED

#include <Godot.hpp>
#include <GodotGlobal.hpp>
#include <Node.hpp>
#include <Spatial.hpp>
#include <HTTPClient.hpp>
#include "Legacy/LegacyLevel.h"
#include <NodePath.hpp>

namespace godot {

class LegacyWorldLoader : public Node {
    GODOT_CLASS(LegacyWorldLoader, Node)
    
private:
    NodePath loaderNode;
    Ref<HTTPClient> client;
    
public:
    static void _register_methods();

	void _init();
    void _ready();
    
    void loadLevelFromFilesystem(String fileName);
    void loadLevelFromLocalhost(int gameNumber);
    void loadLevelFromString(String levelContents);
    
    
};

}
#endif // LEGACYWORLDLOADER_H_INCLUDED
