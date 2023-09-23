using System.Collections.Generic;
using Godot;
using YACY.Util;

namespace YACY.MeshGen;

public class PlatformGenerator
{
	public static Mesh GeneratePlatform(Vector2 position, Vector2 size, int level, float heightOffset, string textureName,
		Color color, bool transparent = false, float outlineWidth = 0.0f, float normalOffset = 0.0f)
	{
		var surfaceTool = new SurfaceTool();
		surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

		var texture = Core.GetManager<TextureManager>().Textures[textureName]?.TextureInfo;

		var height = (level + heightOffset + 0.001f) * Constants.LevelHeight;

		var halfSize = size.X / 2;
		var start = new Vector2(position.X - halfSize, position.Y - halfSize);
		var end = new Vector2(position.X + halfSize, position.Y + halfSize);

		var platVertices = new List<Vector3>();
		platVertices.Add(new Vector3(start.X, height, start.Y));
		platVertices.Add(new Vector3(end.X, height, start.Y));
		platVertices.Add(new Vector3(end.X, height, end.Y));
		platVertices.Add(new Vector3(start.X, height, end.Y));

		var index = 0;
		FloorHelper.AddQuad(surfaceTool, platVertices, texture, color, ref index);
		FloorHelper.AddQuad(surfaceTool, platVertices, texture, color, ref index, true);
	
		surfaceTool.Index();
		
		surfaceTool.SetMaterial(transparent
			? WallHelper.ArrayTextureMaterialPreview
			: WallHelper.ArrayTextureMaterial);

		return surfaceTool.Commit();
	}
}