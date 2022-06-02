using System;
using System.Collections.Generic;
using System.Runtime.Remoting.Messaging;
using Godot;
using YACY.Util;

namespace YACY.MeshGen
{
	public static class WallGenerator
	{
		public static int[] QuadIndices = new[] {0, 1, 3, 1, 2, 3};

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
		public static Mesh GenerateWall(Vector2 start, Vector2 end, int level, float minHeight, float maxHeight, float thickness)
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

			surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
			surfaceTool.AddUv(new Vector2(0 * textureScale.x * textureSize,
				vertices[2].y * textureScale.y * textureSize));
			surfaceTool.AddNormal(normal);
			surfaceTool.AddVertex(vertices[0]);

			surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
			surfaceTool.AddUv(new Vector2(wallLength * textureScale.x * textureSize,
				vertices[2].y * textureScale.y * textureSize));
			surfaceTool.AddNormal(normal);
			surfaceTool.AddVertex(vertices[3]);

			surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
			surfaceTool.AddUv(new Vector2(wallLength * textureScale.x * textureSize,
				vertices[0].y * textureScale.y * textureSize));
			surfaceTool.AddNormal(normal);
			surfaceTool.AddVertex(vertices[2]);
			
			surfaceTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
			surfaceTool.AddUv(new Vector2(0 * textureScale.x * textureSize,
				vertices[0].y * textureScale.y * textureSize));
			surfaceTool.AddNormal(normal);
			surfaceTool.AddVertex(vertices[1]);


			foreach (var quadIndex in QuadIndices)
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