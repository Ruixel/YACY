using System.Collections.Generic;
using Godot;
using YACY.Util;

namespace YACY.MeshGen;

public class PlatformGenerator
{
	public static Mesh GeneratePlatform(Vector2 position, Vector2 size, int level, int heightOffset, string textureName,
		Color color, float outlineWidth, float normalOffset = 0.0f)
	{
		var surfaceTool = new SurfaceTool();
		surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

		var texture = Core.GetManager<TextureManager>().Textures[textureName]?.TextureInfo;

		var height = (level - 1 + heightOffset + 0.001f) * Constants.LevelHeight;

		var halfSize = 2 / 2;
		var start = new Vector2(position.x - halfSize, position.y - halfSize);
		var end = new Vector2(position.x + halfSize, position.y + halfSize);

		var platVertices = new List<Vector3>();
		platVertices.Add(new Vector3(start.x, height, start.y));
		platVertices.Add(new Vector3(end.x, height, start.y));
		platVertices.Add(new Vector3(end.x, height, end.y));
		platVertices.Add(new Vector3(start.x, height, end.y));

		var index = 0;
		FloorHelper.AddQuad(surfaceTool, platVertices, 1, color, ref index);
		FloorHelper.AddQuad(surfaceTool, platVertices, 1, color, ref index, true);
	
		surfaceTool.Index();
		surfaceTool.SetMaterial(WallHelper.ArrayTextureMaterial);

		return surfaceTool.Commit();
	}
}