using System.Collections.Generic;
using System.Linq;
using Godot;
using Godot.Collections;
using Poly2Tri;
using Poly2Tri.Triangulation;
using Poly2Tri.Triangulation.Delaunay;
using Poly2Tri.Triangulation.Polygon;
using Poly2Tri.Utility;

namespace YACY.Legacy
{
	public class FloorGenerator : Node
	{
		private IList<DelaunayTriangle> GetTriangles(ICollection<Vector2> vertices, Array<Object> holes)
		{
			// Generate base polygon from floor vertices
			var points =
				vertices.Select(vertex => new PolygonPoint(vertex.x, vertex.y));

			var polygon = new Polygon(points);

			// Add holes
			foreach (var hole in holes)
			{
				if (hole.Call("get_vertices") is Vector2[] holeVertices)
				{
					var holePoints =
						holeVertices.Select(point => new PolygonPoint(point.x, point.y));

					var holePolygon = new Polygon(holePoints);
					polygon.AddHole(holePolygon);
				}
			}

			P2T.Triangulate(polygon);

			// Return triangles for triangulated polygon
			return polygon.Triangles;
		}

		private void AddTriangle(SurfaceTool sTool, IList<Vector3> vertices, int sIndex, int tex, Color color)
		{
			Node worldConstants = GetNode("/root/WorldConstants");
			Node worldTextures = GetNode("/root/WorldTextures");

			var normal = new Vector3(vertices[2] - vertices[0]).Cross(vertices[1] - vertices[0]);
			normal = normal.Normalized();

			var textureFloat = (float) ((tex + 1.0) / 256.0);
			var textureScale = (Vector2) worldTextures.Call("get_textureScale", tex);
			var textureSize = (float) worldConstants.Get("TEXTURE_SIZE");

			for (int i = 0; i < 3; i++)
			{
				sTool.AddColor(new Color(color.r, color.g, color.b, textureFloat));
				sTool.AddUv(new Vector2(vertices[i].x * textureScale.x * textureSize,
					vertices[i].z * textureScale.y * textureSize));

				sTool.AddNormal(normal);
				sTool.AddVertex(vertices[i]);
			}

			for (int index = 0; index < 3; index++)
			{
				sTool.AddIndex(sIndex + index);
			}
		}

		public ArrayMesh GenerateFloorMesh(Array<Vector2> vertices, int level, int floorTexture, Color floorColor,
			int ceilTexture, Color ceilColor, Array<Object> holes)
		{
			var sTool = new SurfaceTool();
			sTool.Begin(Mesh.PrimitiveType.Triangles);

			var worldConstants = GetNode("/root/WorldConstants");
			var worldTextures = GetNode("/root/WorldTextures");

			var height = (float) (level - 1.0) * (float) worldConstants.Get("LEVEL_HEIGHT");

			// Set colour to white if the color texture is selected
			var floorMeshColor = floorColor;
			if (floorTexture != (int) worldTextures.Call("getColorTextureID"))
				floorMeshColor = new Color(1, 1, 1);

			var ceilMeshColor = ceilColor;
			if (ceilTexture != (int) worldTextures.Call("getColorTextureID"))
				ceilMeshColor = new Color(1, 1, 1);

			// Not sure what the point of this is lol
			var v = new List<Vector2>
			{
				new Vector2(vertices[0].x, vertices[0].y),
				new Vector2(vertices[1].x, vertices[1].y),
				new Vector2(vertices[2].x, vertices[2].y),
				new Vector2(vertices[3].x, vertices[3].y)
			};

			var tris = GetTriangles(v, holes);

			var index = 0;
			foreach (var triangle in tris)
			{
				var triangleVertices = new List<Vector3>();
				foreach (var point in triangle.Points)
					triangleVertices.Add(new Vector3((float) point.X, height, (float) point.Y));

				AddTriangle(sTool, triangleVertices, index, floorTexture, floorMeshColor);

				var backwardsTriangleVertices = new List<Vector3>();
				for (int i = 2; i >= 0; i--)
					backwardsTriangleVertices.Add(triangleVertices[i]);

				AddTriangle(sTool, backwardsTriangleVertices, index + 3, ceilTexture, ceilMeshColor);

				index += 6;
			}

			sTool.SetMaterial((Material) worldTextures.Call("getWallMaterial", floorTexture));
			return sTool.Commit();
		}
	}
}
