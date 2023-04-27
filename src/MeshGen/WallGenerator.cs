using System;
using System.Collections.Generic;
using System.Runtime.Remoting.Messaging;
using Godot;
using YACY.Build;
using YACY.Geometry;
using YACY.Legacy;
using YACY.Legacy.Objects;
using YACY.Util;

namespace YACY.MeshGen
{
	public static class WallGenerator
	{
		public static Mesh GenerateFlatWall(Vector2 start, Vector2 end, int level, string textureName, Color color,
			float minHeight, float maxHeight)
		{
			var bottom = (level + minHeight) * Constants.LevelHeight;
			var top = (level + maxHeight) * Constants.LevelHeight;

			return GenerateWall(start, end, top, bottom, textureName, color, 0f);
		}

		public static Mesh GenerateSelectionFlatWall(Vector2 start, Vector2 end, int level, float minHeight,
			float maxHeight, float outlineWidth)
		{
			var bottom = (level + minHeight) * Constants.LevelHeight;
			var top = (level + maxHeight) * Constants.LevelHeight;

			return GenerateWall(start, end, top, bottom, "Color", Colors.White, outlineWidth, 0.02f);
		}

		private static Mesh GenerateWall(Vector2 start, Vector2 end, float top, float bottom, string textureName,
			Color color, float outlineWidth, float normalOffset = 0.0f)
		{
			var surfaceTool = new SurfaceTool();
			surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

			var wallVector = (end - start).Normalized();
			end += wallVector * outlineWidth;
			start -= wallVector * outlineWidth;
			top += outlineWidth;
			bottom -= outlineWidth;

			var texture = Core.GetManager<TextureManager>().Textures[textureName]?.TextureInfo;

			var normalVector = new Vector3(wallVector.x, 0, wallVector.y).Cross(new Vector3(0, 1, 0));

			var vertices = WallHelper.CreateWallVertices(start, end, top, bottom);
			var frontVertices = vertices.ConvertAll(v => v - (normalVector * normalOffset));
			var backVertices = vertices.ConvertAll(v => v + (normalVector * normalOffset));

			var index = 0;
			WallHelper.AddQuad(surfaceTool, frontVertices, texture, color, ref index, false);
			WallHelper.AddQuad(surfaceTool, backVertices, texture, color, ref index, true);

			surfaceTool.Index();
			surfaceTool.SetMaterial(WallHelper.ArrayTextureMaterial);

			return surfaceTool.Commit();
		}

		private static void GenerateWallMesh(SurfaceTool surfaceTool, List<Vector3> vertices, int level, TextureInfo? textureInfo, Color color)
		{
			var index = 0;
			WallHelper.AddQuad(surfaceTool, vertices, textureInfo, color, ref index);
			WallHelper.AddQuad(surfaceTool, vertices.GetRange(4, 4), textureInfo, color, ref index, true);

			var frontVertices = new List<Vector3> {vertices[2], vertices[3], vertices[7], vertices[6]};
			WallHelper.AddQuad(surfaceTool, frontVertices, textureInfo, color, ref index, true);

			var backVertices = new List<Vector3> {vertices[0], vertices[1], vertices[5], vertices[4]};
			WallHelper.AddQuad(surfaceTool, backVertices, textureInfo, color, ref index, true);

			var topVertices = new List<Vector3> {vertices[0], vertices[3], vertices[7], vertices[4]};
			WallHelper.AddQuad(surfaceTool, topVertices, textureInfo, color, ref index);

			var bottomVertices = new List<Vector3> {vertices[1], vertices[2], vertices[6], vertices[5]};
			WallHelper.AddQuad(surfaceTool, bottomVertices, textureInfo, color, ref index, true);
		}
	}
}