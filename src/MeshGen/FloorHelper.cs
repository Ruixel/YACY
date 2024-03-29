using System.Collections.Generic;
using Godot;
using YACY.Legacy;
using YACY.Util;

namespace YACY.MeshGen;

public class FloorHelper
{
	private static readonly int[] TriIndices = new[] {0, 1, 2};
	private static readonly int[] QuadIndices = new[] {0, 1, 3, 1, 2, 3};

	public static void AddTri(SurfaceTool surfaceTool, IList<Vector3> vertices, int textureID, Color color,
		ref int indexOffset, bool generateBack = false)
	{
		if (generateBack)
		{
			vertices = new List<Vector3> {vertices[2], vertices[1], vertices[0]};
		}

		var normal = -(vertices[2] - vertices[1]).Cross(vertices[0] - vertices[1]).Normalized();

		var textureFloat = textureID / 256;
		var textureScale = new Vector2(1, 1); // Get it from somewhere

		var textureSize = 1;

		//surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
		surfaceTool.AddColor(color);
		surfaceTool.AddNormal(normal);
		surfaceTool.AddVertex(vertices[0]);

		//surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
		surfaceTool.AddColor(color);
		surfaceTool.AddNormal(normal);
		surfaceTool.AddVertex(vertices[1]);

		//surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
		surfaceTool.AddColor(color);
		surfaceTool.AddNormal(normal);
		surfaceTool.AddVertex(vertices[2]);


		foreach (var triIndex in TriIndices)
		{
			surfaceTool.AddIndex(triIndex + indexOffset);
		}

		indexOffset += 3;
	}
	
	public static void AddQuad(SurfaceTool surfaceTool, IList<Vector3> vertices, TextureInfo? textureInfo, Color color,
		ref int indexOffset, bool generateBack = false)
	{
		if (generateBack)
			vertices = new List<Vector3> {vertices[3], vertices[2], vertices[1], vertices[0]};

		var normal = -(vertices[2] - vertices[1]).Cross(vertices[0] - vertices[1]).Normalized();

		var textureFloat = 0.0f;
		var textureScale = new Vector2(1, 1); // Get it from somewhere
		var textureSize = Constants.TextureSize;

		if (textureInfo.HasValue)
		{
			textureFloat = (textureInfo.Value.Id+1.0f) / 256.0f;
			textureScale = textureInfo.Value.Scale;
		}
		
		color.a = textureFloat;

		for (var i = 0; i < 4; i++)
		{
			surfaceTool.AddColor(color);
			surfaceTool.AddUv(new Vector2(vertices[i].x * textureScale.x * textureSize, vertices[i].z * textureScale.y * textureSize));
			surfaceTool.AddNormal(normal);
			surfaceTool.AddVertex(vertices[i]);
		}

		foreach (var quadIndex in QuadIndices)
		{
			surfaceTool.AddIndex(quadIndex + indexOffset);
		}

		indexOffset += 4;
	}
}