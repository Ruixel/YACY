using System;
using System.Collections.Generic;
using System.Runtime.Remoting.Messaging;
using Godot;
using YACY.Build;
using YACY.Geometry;
using YACY.Legacy.Objects;
using YACY.Util;

namespace YACY.MeshGen
{
	public static class WallGenerator
	{

		public static Mesh GenerateFlatWall(Vector2 start, Vector2 end, int level, float minHeight, float maxHeight)
		{
			float bottom = (level + minHeight) * Constants.LevelHeight;
			float top = (level + maxHeight) * Constants.LevelHeight;

			return GenerateWall(start, end, top, bottom, Colors.White, 0f);
		}

		public static Mesh GenerateSelectionFlatWall(Vector2 start, Vector2 end, int level, float minHeight,
			float maxHeight, float outlineWidth)
		{
			float bottom = (level + minHeight) * Constants.LevelHeight;
			float top = (level + maxHeight) * Constants.LevelHeight;

			return GenerateWall(start, end, top, bottom, Colors.Black, outlineWidth, 0.02f);
		}

		public static Mesh GenerateWall(Vector2 start, Vector2 end, float top, float bottom, Color color,
			float outlineWidth, float normalOffset = 0.0f)
		{
			var surfaceTool = new SurfaceTool();
			surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

			Vector2 wallVector = (end - start).Normalized();
			end += wallVector * outlineWidth;
			start -= wallVector * outlineWidth;
			top += outlineWidth;
			bottom -= outlineWidth;

			Vector3 normalVector = new Vector3(wallVector.x, 0, wallVector.y).Cross(new Vector3(0, 1, 0));

			List<Vector3> vertices = WallHelper.CreateWallVertices(start, end, top, bottom);
			List<Vector3> frontVertices = vertices.ConvertAll(v => v - (normalVector * normalOffset));
			List<Vector3> backVertices = vertices.ConvertAll(v => v + (normalVector * normalOffset));

			int index = 0;
			WallHelper.AddQuad(surfaceTool, frontVertices, 1, color, ref index, false);
			WallHelper.AddQuad(surfaceTool, backVertices, 1, color, ref index, true);

			surfaceTool.Index();
			return surfaceTool.Commit();
		}

		private static void GenerateWallMesh(SurfaceTool surfaceTool, List<Vector3> vertices, int level, Color color)
		{
			var index = 0;
			WallHelper.AddQuad(surfaceTool, vertices, 1, color, ref index);
			WallHelper.AddQuad(surfaceTool, vertices.GetRange(4, 4), 1, color, ref index, true);

			var frontVertices = new List<Vector3> {vertices[2], vertices[3], vertices[7], vertices[6]};
			WallHelper.AddQuad(surfaceTool, frontVertices, 1, color, ref index, true);

			var backVertices = new List<Vector3> {vertices[0], vertices[1], vertices[5], vertices[4]};
			WallHelper.AddQuad(surfaceTool, backVertices, 1, color, ref index, true);

			var topVertices = new List<Vector3> {vertices[0], vertices[3], vertices[7], vertices[4]};
			WallHelper.AddQuad(surfaceTool, topVertices, 1, color, ref index);

			var bottomVertices = new List<Vector3> {vertices[1], vertices[2], vertices[6], vertices[5]};
			WallHelper.AddQuad(surfaceTool, bottomVertices, 1, color, ref index, true);
		}


	}
}