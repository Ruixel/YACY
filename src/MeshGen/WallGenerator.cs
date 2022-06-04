using System;
using System.Collections.Generic;
using System.Runtime.Remoting.Messaging;
using Godot;
using YACY.Util;

namespace YACY.MeshGen
{
	public static class WallGenerator
	{
		private static int[] _quadIndices = new[] {0, 1, 3, 1, 2, 3};
		private static Material _colorMaterial = ResourceLoader.Load<ShaderMaterial>("res://res/materials/Color.tres");

		public static Mesh GenerateFlatWall(Vector2 start, Vector2 end, int level, float minHeight, float maxHeight)
		{
			var surfaceTool = new SurfaceTool();
			surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

			var bottom = (level - 1 + minHeight) * Constants.LevelHeight;
			var top = (level - 1 + maxHeight) * Constants.LevelHeight;

			var vertices = new List<Vector3>();
			vertices.Add(new Vector3(start.x, top, start.y));
			vertices.Add(new Vector3(start.x, bottom, start.y));
			vertices.Add(new Vector3(end.x, bottom, end.y));
			vertices.Add(new Vector3(end.x, top, end.y));

			AddQuad(surfaceTool, vertices, 1, Colors.White, 0);

			AddQuad(surfaceTool, vertices, 1, Colors.White, 4, true);

			surfaceTool.Index();
			return surfaceTool.Commit();
		}

		public static Mesh GenerateWall(Vector2 start, Vector2 end, int level, float minHeight, float maxHeight,
			float thickness)
		{
			var surfaceTool = new SurfaceTool();
			surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

			var bottom = (level - 1 + minHeight) * Constants.LevelHeight;
			var top = (level - 1 + maxHeight) * Constants.LevelHeight;

			var flatVertices = new List<Vector3>();
			flatVertices.Add(new Vector3(start.x, top, start.y));
			flatVertices.Add(new Vector3(start.x, bottom, start.y));
			flatVertices.Add(new Vector3(end.x, bottom, end.y));
			flatVertices.Add(new Vector3(end.x, top, end.y));

			var normal = (flatVertices[2] - flatVertices[1]).Cross(flatVertices[0] - flatVertices[1]).Normalized();
			var vertices = flatVertices.ConvertAll(v => v + normal * thickness);
			vertices.AddRange(flatVertices.ConvertAll(v => v - normal * thickness));

			AddQuad(surfaceTool, vertices, 1, Colors.White, 0);
			AddQuad(surfaceTool, vertices.GetRange(4, 4), 1, Colors.White, 4, true);

			var frontVertices = new List<Vector3> {vertices[2], vertices[3], vertices[7], vertices[6]};
			AddQuad(surfaceTool, frontVertices, 1, Colors.White, 8, true);

			var backVertices = new List<Vector3> {vertices[0], vertices[1], vertices[5], vertices[4]};
			AddQuad(surfaceTool, backVertices, 1, Colors.White, 12, true);

			var topVertices = new List<Vector3> {vertices[0], vertices[3], vertices[7], vertices[4]};
			AddQuad(surfaceTool, topVertices, 1, Colors.White, 16);

			var bottomVertices = new List<Vector3> {vertices[1], vertices[2], vertices[6], vertices[5]};
			AddQuad(surfaceTool, bottomVertices, 1, Colors.White, 20, true);

			surfaceTool.Index();
			return surfaceTool.Commit();
		}

		public static Mesh GenerateComplexWall(Wall wall, List<Wall> startWalls, List<Wall> endWalls)
		{
			var surfaceTool = new SurfaceTool();
			surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

			var bottom = (1 - 1 + 0) * Constants.LevelHeight;
			var top = (1 - 1 + 1) * Constants.LevelHeight;

			var start = wall.StartPosition;
			var end = wall.EndPosition;

			var flatVertices = new List<Vector3>();
			flatVertices.Add(new Vector3(start.x, top, start.y));
			flatVertices.Add(new Vector3(start.x, bottom, start.y));
			flatVertices.Add(new Vector3(end.x, bottom, end.y));
			flatVertices.Add(new Vector3(end.x, top, end.y));

			var normal = (flatVertices[2] - flatVertices[1]).Cross(flatVertices[0] - flatVertices[1]).Normalized();
			var vertices = flatVertices.ConvertAll(v => v + normal * 0.1f);
			vertices.AddRange(flatVertices.ConvertAll(v => v - normal * 0.1f));

			// Calculate lines 
			var frontStart = new Vector2(vertices[0].x, vertices[0].z);
			var frontEnd = new Vector2(vertices[3].x, vertices[3].z);
			wall.FrontLine = new Tuple<Vector2, Vector2>(frontStart, frontEnd - frontStart);
			
			var backStart = new Vector2(vertices[4].x, vertices[4].z);
			var backEnd = new Vector2(vertices[7].x, vertices[7].z);
			wall.BackLine = new Tuple<Vector2, Vector2>(backStart, backEnd - backStart);

			// Get first wall
			if (startWalls.Count >= 1)
			{
				var otherWall = startWalls[0];
				// Start line
				var frontIntersect = (Vector2)Godot.Geometry.LineIntersectsLine2d(wall.FrontLine.Item1, wall.FrontLine.Item2,
					otherWall.FrontLine.Item1, otherWall.FrontLine.Item2);

				vertices[0] = new Vector3(frontIntersect.x, top, frontIntersect.y);
				vertices[1] = new Vector3(frontIntersect.x, bottom, frontIntersect.y);
				
				var backIntersect = (Vector2)Godot.Geometry.LineIntersectsLine2d(wall.BackLine.Item1, wall.BackLine.Item2,
					otherWall.BackLine.Item1, otherWall.BackLine.Item2);

				vertices[4] = new Vector3(backIntersect.x, top, backIntersect.y);
				vertices[5] = new Vector3(backIntersect.x, bottom, backIntersect.y);
				
				GD.Print($"Intersection: {frontIntersect}");
			}


			AddQuad(surfaceTool, vertices, 1, wall.Color, 0);
			AddQuad(surfaceTool, vertices.GetRange(4, 4), 1, wall.Color, 4, true);

			var frontVertices = new List<Vector3> {vertices[2], vertices[3], vertices[7], vertices[6]};
			AddQuad(surfaceTool, frontVertices, 1, wall.Color, 8, true);

			var backVertices = new List<Vector3> {vertices[0], vertices[1], vertices[5], vertices[4]};
			AddQuad(surfaceTool, backVertices, 1, wall.Color, 12, true);

			var topVertices = new List<Vector3> {vertices[0], vertices[3], vertices[7], vertices[4]};
			AddQuad(surfaceTool, topVertices, 1, wall.Color, 16);

			var bottomVertices = new List<Vector3> {vertices[1], vertices[2], vertices[6], vertices[5]};
			AddQuad(surfaceTool, bottomVertices, 1, wall.Color, 20, true);

			surfaceTool.Index();
			surfaceTool.SetMaterial(_colorMaterial);
			return surfaceTool.Commit();
		}

		public static void AddQuad(SurfaceTool surfaceTool, IList<Vector3> vertices, int textureID, Color color,
			int indexOffset, bool generateBack = false)
		{
			if (generateBack)
				vertices = new List<Vector3> {vertices[3], vertices[2], vertices[1], vertices[0]};

			var normal = (vertices[2] - vertices[1]).Cross(vertices[0] - vertices[1]).Normalized();

			var wallLength = Mathf.Sqrt(Mathf.Pow(vertices[2].z - vertices[0].z, 2) +
			                            Mathf.Pow(vertices[2].x - vertices[0].x, 2));
			var textureFloat = textureID / 256;
			var textureScale = new Vector2(1, 1); // Get it from somewhere

			var textureSize = 1;

			//surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
			surfaceTool.AddColor(color);
			surfaceTool.AddUv(new Vector2(0 * textureScale.x * textureSize,
				vertices[2].y * textureScale.y * textureSize));
			surfaceTool.AddNormal(normal);
			surfaceTool.AddVertex(vertices[0]);

			//surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
			surfaceTool.AddColor(color);
			surfaceTool.AddUv(new Vector2(wallLength * textureScale.x * textureSize,
				vertices[2].y * textureScale.y * textureSize));
			surfaceTool.AddNormal(normal);
			surfaceTool.AddVertex(vertices[3]);

			//surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
			surfaceTool.AddColor(color);
			surfaceTool.AddUv(new Vector2(wallLength * textureScale.x * textureSize,
				vertices[0].y * textureScale.y * textureSize));
			surfaceTool.AddNormal(normal);
			surfaceTool.AddVertex(vertices[2]);

			//surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
			surfaceTool.AddColor(color);
			surfaceTool.AddUv(new Vector2(0 * textureScale.x * textureSize,
				vertices[0].y * textureScale.y * textureSize));
			surfaceTool.AddNormal(normal);
			surfaceTool.AddVertex(vertices[1]);


			foreach (var quadIndex in _quadIndices)
			{
				surfaceTool.AddIndex(quadIndex + indexOffset);
			}
		}

		public static Mesh AddPlane(List<Vector3> vertices)
		{
			return new PlaneMesh();
		}
	}
}