using System;
using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Geometry;
using YACY.Util;

namespace YACY.MeshGen;

public partial class ThickWallGenerator : Node
{
	public static Mesh GenerateComplexWall(Wall wall, List<Wall> startWalls, List<Wall> endWalls, int level,
		bool propagate = false)
	{
		var surfaceTool = new SurfaceTool();
		surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

		var bottom = (level + 0) * Constants.LevelHeight;
		var top = (level + 1) * Constants.LevelHeight;

		var start = wall.StartPosition;
		var end = wall.EndPosition;

		var flatVertices = new List<Vector3>();
		flatVertices.Add(new Vector3(start.X, top, start.Y));
		flatVertices.Add(new Vector3(start.X, bottom, start.Y));
		flatVertices.Add(new Vector3(end.X, bottom, end.Y));
		flatVertices.Add(new Vector3(end.X, top, end.Y));

		var normal = (flatVertices[2] - flatVertices[1]).Cross(flatVertices[0] - flatVertices[1]).Normalized();
		var vertices = flatVertices.ConvertAll(v => v + normal * 0.1f);
		vertices.AddRange(flatVertices.ConvertAll(v => v - normal * 0.1f));

		// Calculate lines 
		var frontStart = new Vector2(vertices[0].X, vertices[0].Z);
		var frontEnd = new Vector2(vertices[3].X, vertices[3].Z);
		wall.FrontLine = new Tuple<Vector2, Vector2>(frontStart, (frontEnd - frontStart).Normalized());

		var backStart = new Vector2(vertices[4].X, vertices[4].Z);
		var backEnd = new Vector2(vertices[7].X, vertices[7].Z);
		wall.BackLine = new Tuple<Vector2, Vector2>(backStart, (backEnd - backStart).Normalized());

		// Get first wall
		if (startWalls.Count >= 1)
		{
			var closestFrontIntersect = new Vector2(vertices[0].X, vertices[0].Z);
			var closestBackIntersect = new Vector2(vertices[4].X, vertices[4].Z);

			var frontLine = new Tuple<Vector2, Vector2>(Vector2.Zero, Vector2.Zero);
			var frontLineDot = -3f;
			var backLine = new Tuple<Vector2, Vector2>(Vector2.Zero, Vector2.Zero);
			var backLineDot = -3f;

			foreach (var otherWall in startWalls)
			{
				var otherWallFrontLine = otherWall.FrontLine;
				var otherWallBackLine = otherWall.BackLine;
				if (!wall.StartPosition.IsEqualApprox(otherWall.StartPosition))
				{
					//otherWallFrontLine = otherWall.BackLine;
					//otherWallBackLine = otherWall.FrontLine;

					otherWallFrontLine =
						new Tuple<Vector2, Vector2>(otherWall.BackLine.Item1, -otherWall.BackLine.Item2);
					otherWallBackLine =
						new Tuple<Vector2, Vector2>(otherWall.FrontLine.Item1, -otherWall.FrontLine.Item2);
				}

				// Get closest front line
				var fldot = wall.BackLine.Item2.Dot(otherWallFrontLine.Item2);
				if (!WallHelper.IsClockwise(wall.BackLine.Item2, otherWallBackLine.Item2))
					fldot = -fldot - 2;

				if (fldot > frontLineDot)
				{
					frontLine = otherWallBackLine;
					frontLineDot = fldot;
				}

				// Get closest back line
				var bldot = wall.FrontLine.Item2.Dot(otherWallBackLine.Item2);
				if (WallHelper.IsClockwise(wall.FrontLine.Item2, otherWallFrontLine.Item2))
					bldot = -bldot - 2;
				if (bldot > backLineDot)
				{
					backLine = otherWallFrontLine;
					backLineDot = bldot;
				}

				// Update all adjacent walls
				if (propagate)
				{
					var otherWallsStartWalls = Core.GetManager<LevelManager>()
						.GetEntitiesAtPosition<Wall>(otherWall.StartPosition, BuildEntityList.Type.Wall, otherWall.Id);
					var otherWallsEndWalls = Core.GetManager<LevelManager>()
						.GetEntitiesAtPosition<Wall>(otherWall.EndPosition, BuildEntityList.Type.Wall, otherWall.Id);

					otherWall.GenerateMergedMesh(otherWallsStartWalls, otherWallsEndWalls, false);
				}
			}


			if (Math.Abs(frontLineDot - (-1f)) > 0.01)
			{
				var frontIntersect = (Vector2) Geometry2D.LineIntersectsLine(wall.FrontLine.Item1,
					wall.FrontLine.Item2,
					frontLine.Item1, frontLine.Item2);

				closestFrontIntersect = frontIntersect;
			}

			if (Math.Abs(backLineDot - (-1f)) > 0.01)
			{
				var backIntersect = (Vector2) Geometry2D.LineIntersectsLine(wall.BackLine.Item1,
					wall.BackLine.Item2,
					backLine.Item1, backLine.Item2);

				closestBackIntersect = backIntersect;
			}

			vertices[0] = new Vector3(closestFrontIntersect.X, top, closestFrontIntersect.Y);
			vertices[1] = new Vector3(closestFrontIntersect.X, bottom, closestFrontIntersect.Y);

			vertices[4] = new Vector3(closestBackIntersect.X, top, closestBackIntersect.Y);
			vertices[5] = new Vector3(closestBackIntersect.X, bottom, closestBackIntersect.Y);
		}


		// Wall end point
		if (endWalls.Count >= 1)
		{
			var closestFrontIntersect = new Vector2(vertices[2].X, vertices[2].Z);
			var closestBackIntersect = new Vector2(vertices[6].X, vertices[6].Z);

			var frontLine = new Tuple<Vector2, Vector2>(Vector2.Zero, Vector2.Zero);
			var frontLineDot = -3f;
			var backLine = new Tuple<Vector2, Vector2>(Vector2.Zero, Vector2.Zero);
			var backLineDot = -3f;

			foreach (var otherWall in endWalls)
			{
				var otherWallFrontLine = otherWall.FrontLine;
				var otherWallBackLine = otherWall.BackLine;
				if (!wall.EndPosition.IsEqualApprox(otherWall.EndPosition))
				{
					//otherWallFrontLine = otherWall.BackLine;
					//otherWallBackLine = otherWall.FrontLine;

					otherWallFrontLine =
						new Tuple<Vector2, Vector2>(otherWall.BackLine.Item1, -otherWall.BackLine.Item2);
					otherWallBackLine =
						new Tuple<Vector2, Vector2>(otherWall.FrontLine.Item1, -otherWall.FrontLine.Item2);
				}

				// Get closest front line
				var fldot = wall.BackLine.Item2.Dot(otherWallFrontLine.Item2);
				if (WallHelper.IsClockwise(wall.BackLine.Item2, otherWallBackLine.Item2))
					fldot = -fldot - 2;

				if (fldot > frontLineDot)
				{
					frontLine = otherWallBackLine;
					frontLineDot = fldot;
				}

				// Get closest back line
				var bldot = wall.FrontLine.Item2.Dot(otherWallBackLine.Item2);
				if (!WallHelper.IsClockwise(wall.FrontLine.Item2, otherWallFrontLine.Item2))
					bldot = -bldot - 2;

				if (bldot > backLineDot)
				{
					backLine = otherWallFrontLine;
					backLineDot = bldot;
				}

				// Update all adjacent walls
				if (propagate)
				{
					var otherWallsStartWalls = Core.GetManager<LevelManager>()
						.GetEntitiesAtPosition<Wall>(otherWall.StartPosition, BuildEntityList.Type.Wall, otherWall.Id);
					var otherWallsEndWalls = Core.GetManager<LevelManager>()
						.GetEntitiesAtPosition<Wall>(otherWall.EndPosition, BuildEntityList.Type.Wall, otherWall.Id);

					otherWall.GenerateMergedMesh(otherWallsStartWalls, otherWallsEndWalls, false);
				}
			}


			if (Math.Abs(frontLineDot - (-1f)) > 0.01)
			{
				var frontIntersect = (Vector2) Geometry2D.LineIntersectsLine(wall.FrontLine.Item1,
					wall.FrontLine.Item2,
					frontLine.Item1, frontLine.Item2);

				closestFrontIntersect = frontIntersect;
			}

			if (Math.Abs(backLineDot - (-1f)) > 0.01)
			{
				var backIntersect = (Vector2) Geometry2D.LineIntersectsLine(wall.BackLine.Item1,
					wall.BackLine.Item2,
					backLine.Item1, backLine.Item2);

				closestBackIntersect = backIntersect;
			}

			vertices[3] = new Vector3(closestFrontIntersect.X, top, closestFrontIntersect.Y);
			vertices[2] = new Vector3(closestFrontIntersect.X, bottom, closestFrontIntersect.Y);

			vertices[7] = new Vector3(closestBackIntersect.X, top, closestBackIntersect.Y);
			vertices[6] = new Vector3(closestBackIntersect.X, bottom, closestBackIntersect.Y);
		}

		// Get end first wall
		/*if (endWalls.Count >= 1)
		{
			var otherWall = endWalls[0];

			var dot = wall.FrontLine.Item2.Dot(otherWall.FrontLine.Item2);

			// Make sure they are not parallel
			if (Mathf.Abs(dot) < 0.999)
			{
				var frontLine = otherWall.FrontLine;
				var backLine = otherWall.BackLine;
				if (wall.EndPosition.IsEqualApprox(otherWall.EndPosition))
				{
					frontLine = otherWall.BackLine;
					backLine = otherWall.FrontLine;
				}

				// Start lin
				var frontIntersect = (Vector2) Godot.Geometry.LineIntersectsLine(wall.FrontLine.Item1,
					wall.FrontLine.Item2,
					frontLine.Item1, frontLine.Item2);

				vertices[2] = new Vector3(frontIntersect.x, bottom, frontIntersect.y);
				vertices[3] = new Vector3(frontIntersect.x, top, frontIntersect.y);

				var backIntersect = (Vector2) Godot.Geometry.LineIntersectsLine(wall.BackLine.Item1,
					wall.BackLine.Item2,
					backLine.Item1, backLine.Item2);

				vertices[6] = new Vector3(backIntersect.x, bottom, backIntersect.y);
				vertices[7] = new Vector3(backIntersect.x, top, backIntersect.y);

				GD.Print($"End Intersection: {frontIntersect}");

				if (propagate)
				{
					var otherWallsStartWalls =
						Core.GetManager<IWallManager>().GetWallsAtPosition(otherWall.StartPosition, otherWall.Id);
					var otherWallsEndWalls =
						Core.GetManager<IWallManager>().GetWallsAtPosition(otherWall.EndPosition, otherWall.Id);
					
					otherWall.GenerateMergedMesh(otherWallsStartWalls, otherWallsEndWalls, false);
				}
			}
		}*/

		var index = 0;
		WallHelper.AddQuad(surfaceTool, vertices, null, Colors.White, ref index, false, true);
		WallHelper.AddQuad(surfaceTool, vertices.GetRange(4, 4), null, Colors.White, ref index, true, true);

		var frontVertices = new List<Vector3> {vertices[2], vertices[3], vertices[7], vertices[6]};
		WallHelper.AddQuad(surfaceTool, frontVertices, null, Colors.White, ref index, true, true);

		var backVertices = new List<Vector3> {vertices[0], vertices[1], vertices[5], vertices[4]};
		WallHelper.AddQuad(surfaceTool, backVertices, null, Colors.White, ref index, true, true);

		var topVertices = new List<Vector3> {vertices[0], vertices[3], vertices[7], vertices[4]};
		WallHelper.AddQuad(surfaceTool, topVertices, null, Colors.White, ref index, false, true);

		var bottomVertices = new List<Vector3> {vertices[1], vertices[2], vertices[6], vertices[5]};
		WallHelper.AddQuad(surfaceTool, bottomVertices, null, Colors.White, ref index, true, true);

		if (startWalls.Count >= 2)
		{
			var gapfill = new List<Vector3> {vertices[0], vertices[4], new Vector3(start.X, top, start.Y)};
			FloorHelper.AddTri(surfaceTool, gapfill, 1, Colors.White, ref index, true);
		}

		if (endWalls.Count >= 2)
		{
			var gapfill = new List<Vector3> {vertices[3], vertices[7], new Vector3(end.X, top, end.Y)};
			FloorHelper.AddTri(surfaceTool, gapfill, 1, Colors.White, ref index, false);
		}

		surfaceTool.Index();
		surfaceTool.SetMaterial(WallHelper.ColorMaterial);
		return surfaceTool.Commit();
	}
	
		private static void MergeWithAdjacentWalls(Wall wall, List<Wall> adjacentWalls, List<Vector3> vertices,
			bool propagate)
		{
			float top;
			float bottom;
			if (adjacentWalls.Count >= 1)
			{
				var otherWall = adjacentWalls[0];

				var dot = wall.FrontLine.Item2.Dot(otherWall.FrontLine.Item2);
				GD.Print($"front dot: {dot}");

				// Make sure they are not parallel
				if (Mathf.Abs(dot) < 0.999)
				{
					var frontLine = otherWall.FrontLine;
					var backLine = otherWall.BackLine;
					if (wall.StartPosition.IsEqualApprox(otherWall.StartPosition))
					{
						frontLine = otherWall.BackLine;
						backLine = otherWall.FrontLine;
					}

					// Start line
					var frontIntersect = (Vector2) Geometry2D.LineIntersectsLine(wall.FrontLine.Item1,
						wall.FrontLine.Item2,
						frontLine.Item1, frontLine.Item2);

					vertices[0] = new Vector3(frontIntersect.X, vertices[0].Y, frontIntersect.Y);
					vertices[1] = new Vector3(frontIntersect.X, vertices[1].Y, frontIntersect.Y);

					var backIntersect = (Vector2) Geometry2D.LineIntersectsLine(wall.BackLine.Item1,
						wall.BackLine.Item2,
						backLine.Item1, backLine.Item2);

					vertices[4] = new Vector3(backIntersect.X, vertices[4].Y, backIntersect.Y);
					vertices[5] = new Vector3(backIntersect.X, vertices[5].Y, backIntersect.Y);

					if (propagate)
					{
						var otherWallsStartWalls = Core.GetManager<LevelManager>()
							.GetEntitiesAtPosition<Wall>(otherWall.StartPosition, BuildEntityList.Type.Wall, otherWall.Id);
						var otherWallsEndWalls = Core.GetManager<LevelManager>()
							.GetEntitiesAtPosition<Wall>(otherWall.EndPosition, BuildEntityList.Type.Wall, otherWall.Id);

						otherWall.GenerateMergedMesh(otherWallsStartWalls, otherWallsEndWalls, false);
					}
				}
			}
		}
}