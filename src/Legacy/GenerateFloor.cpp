#include "GenerateFloor.h"

#include <Material.hpp>

using namespace godot;

void GenerateFloor::_register_methods() 
{
    register_method("generateFloorMesh", &GenerateFloor::generateFloorMesh);

    register_method("_ready", &GenerateFloor::_ready);
}

void GenerateFloor::_ready()
{
    worldConstants = get_node("/root/WorldConstants");
    worldTextures = get_node("/root/WorldTextures");
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
        //if (holes[i].get_level)
        /*PoolVector2Array hole_vertices = holes[i].call("get_vertices");
        std::vector<p2t::Point*> hole_polygon;
        for (int p = 0; p < hole_vertices.size(); p++) 
            polygon.push_back(new p2t::Point(hole_vertices[p].x, hole_vertices[p].y));
        
        cdt->AddHole(hole_polygon);*/
    }

    cdt->Triangulate();
    return cdt->GetTriangles();
}

void GenerateFloor::createPlatTriMesh(Ref<SurfaceTool> sTool, PoolVector3Array tri_vertices, 
    int sIndex, int tex, Color colour)
{
    Vector3 normal = Vector3(tri_vertices[2] - tri_vertices[0]).cross(tri_vertices[1] - tri_vertices[0]);
    normal.normalize();

    float texture_float = (tex+1.0)/256.f;

	Vector2 texture_scale = worldTextures->get("textures[" + String::num(tex) + "].texScale");
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
    //Ref<Mesh> newMesh = Mesh::_new();
    //std::vector<p2t::Triangle*> tris = getTris(vertices, holes);

    //for (int tri = 0; tri < tris.size(); tri++) 
    //{

    //}

    Ref<SurfaceTool> sTool = SurfaceTool::_new();
	sTool->begin(Mesh::PRIMITIVE_TRIANGLES);
	
	float height = (level - 1.f) * (float)(worldConstants->get("LEVEL_HEIGHT"));
	
	// Set colour to white if not using the colour wall
	/*Color floor_meshColor = floor_colour;
	if (floor_texture != (int)(worldTextures->get("TextureID.COLOR")))
		floor_meshColor = Color(1,1,1);
	
	Color ceil_meshColor = ceil_colour;
	if (ceil_texture != (int)(worldTextures->get("TextureID.COLOR")))
		ceil_meshColor = Color(1,1,1);

    PoolVector3Array v;
    v.insert(0, Vector3(vertices[0].x, height, vertices[0].y));
	v.insert(1, Vector3(vertices[1].x, height, vertices[1].y));
	v.insert(2, Vector3(vertices[2].x, height, vertices[2].y));
    createPlatTriMesh(sTool, v, 0, floor_texture, floor_meshColor);

    sTool->set_material(worldTextures->call("getWallMaterial", floor_texture));
    return sTool->commit();*/
    return sTool->commit();
}