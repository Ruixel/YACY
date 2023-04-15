using System.Collections.Generic;
using Godot;

namespace YACY.MeshGen;

public static class WallHelper
{
	private static readonly int[] QuadIndices = new[] {0, 1, 3, 1, 2, 3};
	
	public static readonly Material ColorMaterial =
			ResourceLoader.Load<SpatialMaterial>("res://res/materials/test_mat.tres");

	public static void AddQuad(SurfaceTool surfaceTool, List<Vector3> vertices, int textureID, Color color,
		ref int indexOffset, bool generateBack = false)
	{
		if (generateBack)
			vertices = new List<Vector3> {vertices[3], vertices[2], vertices[1], vertices[0]};

		var normal = CalculateNormal(vertices);
		var wallLength = Mathf.Sqrt(Mathf.Pow(vertices[2].z - vertices[0].z, 2) +
		                            Mathf.Pow(vertices[2].x - vertices[0].x, 2));

		var textureFloat = textureID / 256;
		var textureScale = new Vector2(1, 1); // Get it from somewhere
		var textureSize = 1;

		for (int i = 0; i < 4; i++)
		{
			var uvX = (i == 0 || i == 3) ? 0 : wallLength;
			var uvY = (i == 0 || i == 1) ? vertices[2].y : vertices[0].y;

			surfaceTool.AddColor(color);
			surfaceTool.AddUv(new Vector2(uvX * textureScale.x * textureSize, uvY * textureScale.y * textureSize));
			surfaceTool.AddNormal(normal);
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
		return v1.y * v2.x < v1.x * v2.y;
	}

	public static List<Vector3> CreateWallVertices(Vector2 start, Vector2 end, float top, float bottom)
	{
		return new List<Vector3>
		{
			new Vector3(start.x, top, start.y),
			new Vector3(start.x, bottom, start.y),
			new Vector3(end.x, bottom, end.y),
			new Vector3(end.x, top, end.y)
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