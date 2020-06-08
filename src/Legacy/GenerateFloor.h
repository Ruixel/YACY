#ifndef GENERATEFLOOR_H_INCLUDED
#define GENERATEFLOOR_H_INCLUDED

#include <Godot.hpp>
#include <GodotGlobal.hpp>
#include <Node.hpp>
#include <ArrayMesh.hpp>
#include <Ref.hpp>
#include <Array.hpp>
#include <SurfaceTool.hpp>

#include "poly2tri/poly2tri.h"

namespace godot {

class GenerateFloor : public Node {
    GODOT_CLASS(GenerateFloor, Node)

private:
    std::vector<p2t::Triangle*> getTris(PoolVector2Array vertices, Array holes);
    void createPlatTriMesh(Ref<SurfaceTool> sTool, PoolVector3Array tri_vertices, 
        int sIndex, int tex, Color colour);

public:
    static void _register_methods();
    void _init();
    void _ready();

    Ref<ArrayMesh> generateFloorMesh(PoolVector2Array vertices, int level, 
        int floor_texture, Color floor_colour, int ceil_texture, Color ceil_colour, 
        Array holes);
};

}

#endif // GENERATEFLOOR_H_INCLUDED
