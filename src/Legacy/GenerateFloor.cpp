#include "GenerateFloor.h"

#include <Material.hpp>

using namespace godot;

void GenerateFloor::_register_methods() 
{
    register_method("generateFloorMesh", &GenerateFloor::generateFloorMesh);
    register_method("_ready", &GenerateFloor::_ready);
    
    register_property<GenerateFloor, NodePath>("WorldAPI", &GenerateFloor::worldAPINodePath, NodePath());
}

void GenerateFloor::_init()
{
}

void GenerateFloor::_ready()
{
    
}

std::vector<p2t::Triangle*> GenerateFloor::getTris(PoolVector2Array vertices, Array holes)
{
    // Convert vertices array into a p2t point vector
    std::vector<p2t::Point*> polygon;
    for (int p = 0; p < vertices.size(); p++) 
        polygon.push_back(new p2t::Point(vertices[p].x, vertices[p].y));

    // Initialise CDT with ground vertices
    p2t::CDT* cdt = new p2t::CDT(polygon);

    // Add holes
    for (int i = 0; i < holes.size(); i++)
    {
        PoolVector2Array hole_vertices = holes[i].call("get_vertices",nullptr,0);
        Godot::print("WHAT " + String::num(vertices[1].x));
        std::vector<p2t::Point*> hole_polygon;
        for (int p = 0; p < hole_vertices.size(); p++) 
            hole_polygon.push_back(new p2t::Point(hole_vertices[p].x, hole_vertices[p].y));
        
        Godot::print("hole poly " + String::num(hole_polygon.size()));
        cdt->AddHole(hole_polygon);
    }

    cdt->Triangulate();
    return cdt->GetTriangles();
}

void GenerateFloor::createPlatTriMesh(Ref<SurfaceTool> sTool, PoolVector3Array tri_vertices, int sIndex, int tex, Color colour)
{
    Node* worldConstants = get_node("/root/WorldConstants");
    Node* worldTextures = get_node("/root/WorldTextures");
    
    Vector3 normal = Vector3(tri_vertices[2] - tri_vertices[0]).cross(tri_vertices[1] - tri_vertices[0]);
    normal.normalize();

    float texture_float = (tex+1.0)/256.f;

	Vector2 texture_scale = worldTextures->call("get_textureScale", tex);
    float texture_size = worldConstants->get("TEXTURE_SIZE");

    for (int i = 0; i < 3; i++) 
    {
        sTool->add_color(Color(colour.r, colour.g, colour.b, texture_float));
        sTool->add_uv(Vector2(tri_vertices[i].x * texture_scale.x * texture_size,  
							  tri_vertices[i].z * texture_scale.y * texture_size));
        sTool->add_normal(normal);
        sTool->add_vertex(tri_vertices[i]);
    }

    for (int ind = 0; ind < 3; ind++)
        sTool->add_index(sIndex + ind);
}

Ref<ArrayMesh> GenerateFloor::generateFloorMesh(PoolVector2Array vertices, int level, 
    int floor_texture, Color floor_colour, int ceil_texture, Color ceil_colour, 
    Array holes) 
{
    Ref<SurfaceTool> sTool = SurfaceTool::_new();
	sTool->begin(Mesh::PRIMITIVE_TRIANGLES);
    
    Node* worldConstants = get_node("/root/WorldConstants");
    Node* worldTextures = get_node("/root/WorldTextures");
	
    Godot::print(worldConstants->get_path());
	float height = (level - 1.f) * (float)(worldConstants->get("LEVEL_HEIGHT"));
	
	// Set colour to white if not using the colour wall
	Color floor_meshColor = floor_colour;
	if (floor_texture != (int)(worldTextures->get("TextureID.COLOR")))
		floor_meshColor = Color(1,1,1);
	
	Color ceil_meshColor = ceil_colour;
	if (ceil_texture != (int)(worldTextures->get("TextureID.COLOR")))
		ceil_meshColor = Color(1,1,1);

    PoolVector2Array v;
    v.insert(0, Vector2(vertices[0].x, vertices[0].y));
	v.insert(1, Vector2(vertices[1].x, vertices[1].y));
	v.insert(2, Vector2(vertices[2].x, vertices[2].y));
    v.insert(3, Vector2(vertices[3].x, vertices[3].y));
    
    // Get GetTriangles
    Node* worldAPI = get_node(worldAPINodePath);
    std::vector<p2t::Triangle*> tris = getTris(v, holes);
    Godot::print("Triangles: " + String::num(tris.size()));
    
    int idx = 0;
    for (int t = 0; t < tris.size(); t++) 
    {
        p2t::Triangle& tri = *tris[t];
        
        PoolVector3Array triangleVector;
        triangleVector.insert(0, Vector3(tri.GetPoint(0)->x, height, tri.GetPoint(0)->y));
        triangleVector.insert(1, Vector3(tri.GetPoint(1)->x, height, tri.GetPoint(1)->y));
        triangleVector.insert(2, Vector3(tri.GetPoint(2)->x, height, tri.GetPoint(2)->y));
        
        createPlatTriMesh(sTool, triangleVector, idx, floor_texture, floor_meshColor);
        
        PoolVector3Array backwardsVector;
        for (int i = 2; i >= 0; i--)
            backwardsVector.push_back(triangleVector[i]);
        
        createPlatTriMesh(sTool, backwardsVector, idx + 3, ceil_texture, ceil_meshColor);
        
        idx += 6;
    }

    
    //createPlatTriMesh(sTool, v, 0, floor_texture, floor_meshColor);

    sTool->set_material(worldTextures->call("getWallMaterial", floor_texture));
    return sTool->commit();
}
