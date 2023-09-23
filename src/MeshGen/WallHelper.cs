using System.Collections.Generic;
using Godot;
using YACY.Legacy;
using YACY.Util;

namespace YACY.MeshGen;

public static class WallHelper
{
	private static readonly int[] QuadIndices = new[] {0, 1, 3, 1, 2, 3};
	
	public static readonly Material ColorMaterial =
			ResourceLoader.Load<StandardMaterial3D>("res://res/materials/test_mat.tres");
	
	public static readonly ShaderMaterial ArrayTextureMaterial =
			ResourceLoader.Load<ShaderMaterial>("res://res/materials/ArrayTexture.tres");
	
	public static readonly ShaderMaterial ArrayTextureMaterialTranslucent =
			ResourceLoader.Load<ShaderMaterial>("res://res/materials/ArrayTexture_translucent.tres");
	
	public static readonly ShaderMaterial ArrayTextureMaterialPreview =
			ResourceLoader.Load<ShaderMaterial>("res://res/materials/ArrayTexture_prototype.tres");


	public static void AddQuad(SurfaceTool surfaceTool, List<Vector3> vertices, TextureInfo? textureInfo, Color color,
		ref int indexOffset, bool generateBack = false, bool readjust = false)
	{
		if (generateBack)
			vertices = new List<Vector3> {vertices[3], vertices[2], vertices[1], vertices[0]};

		var normal = CalculateNormal(vertices);
		var wallLength = Mathf.Sqrt(Mathf.Pow(vertices[2].Z - vertices[0].Z, 2) +
		                            Mathf.Pow(vertices[2].X - vertices[0].X, 2));
		
		// Mostly used for thick walls since sometimes a texture will repeat for a lil bit and it looks off
		if (readjust && wallLength % 1 < 0.25 && wallLength > 1)
		{
			wallLength = Mathf.Floor(wallLength);
		}

		var textureFloat = 0.0f;
		var textureScale = new Vector2(1, 1); // Get it from somewhere
		var textureSize = Constants.TextureSize;

		if (textureInfo.HasValue)
		{
			textureFloat = (textureInfo.Value.Id+1.0f) / 256.0f;
			textureScale = textureInfo.Value.Scale;
		}
		
		color.A = textureFloat;

		for (int i = 0; i < 4; i++)
		{
			var uvX = (i is 0 or 3) ? 0 : wallLength;
			var uvY = (i is 0 or 1) ? vertices[2].Y : vertices[0].Y;

			surfaceTool.SetColor(color);
			surfaceTool.SetUV(new Vector2(uvX * textureScale.X * textureSize, uvY * textureScale.Y * textureSize));
			surfaceTool.SetNormal(normal);
			surfaceTool.AddVertex(vertices[(4 - i) % 4]);
		}

		foreach (var quadIndex in QuadIndices)
		{
			surfaceTool.AddIndex(quadIndex + indexOffset);
		}

		indexOffset += 4;
	}

	public static Mesh AddPlane(List<Vector3> vertices)
	{
		return new PlaneMesh();
	}

	public static bool IsClockwise(Vector2 v1, Vector2 v2)
	{
		return v1.Y * v2.X < v1.X * v2.Y;
	}

	public static List<Vector3> CreateWallVertices(Vector2 start, Vector2 end, float top, float bottom)
	{
		return new List<Vector3>
		{
			new Vector3(start.X, top, start.Y),
			new Vector3(start.X, bottom, start.Y),
			new Vector3(end.X, bottom, end.Y),
			new Vector3(end.X, top, end.Y)
		};
	}

	public static Vector3 CalculateNormal(List<Vector3> wallVertices)
	{
		return (wallVertices[2] - wallVertices[1]).Cross(wallVertices[0] - wallVertices[1]).Normalized();
	}

	public static List<Vector3> CalculateVertices(List<Vector3> flatVertices, Vector3 normal, float thickness)
	{
		var vertices = flatVertices.ConvertAll(v => v + normal * thickness);
		vertices.AddRange(flatVertices.ConvertAll(v => v - normal * thickness));
		return vertices;
	}
}