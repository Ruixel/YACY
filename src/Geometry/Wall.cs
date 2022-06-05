using System;
using System.Collections.Generic;
using Godot;
using YACY.Entities;
using YACY.MeshGen;

namespace YACY
{
	public class Wall : Spatial, IEntity
	{
		public int Id { get; }
		public Vector2 StartPosition { get; }
		public Vector2 EndPosition { get; }
		public Color Color { get; }

		public Tuple<Vector2, Vector2> FrontLine;
		public Tuple<Vector2, Vector2> BackLine;

		private MeshInstance _meshInstance;

		private static Random random = new Random();

		private static readonly List<Color> AvailableColors = new List<Color>
			//{Colors.Aqua, Colors.Bisque, Colors.Brown, Colors.Gainsboro, Colors.Ivory, Colors.Orange, Colors.MintCream};
			{
				Colors.SpringGreen, Colors.DodgerBlue, Colors.Firebrick, Colors.DarkSlateBlue, Colors.HotPink, Colors.Maroon
			};

		public Wall(Vector2 startPosition, Vector2 endPosition)
		{
			Id = Core.GetCore().GetNextId();
			
			StartPosition = startPosition;
			EndPosition = endPosition;

			Color = AvailableColors[random.Next(AvailableColors.Count)];

			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);
		}

		public void GenerateMesh()
		{
			_meshInstance.Mesh = WallGenerator.GenerateWall(StartPosition, EndPosition, 1, 0, 1, 0.1f);
		}

		public void GenerateMergedMesh(List<Wall> startWalls, List<Wall> endWalls, bool propagate = false)
		{
			_meshInstance.Mesh = WallGenerator.GenerateComplexWall(this, startWalls, endWalls, propagate);
			//GD.Print($"FrontLine: {FrontLine.Item1}");
		}
	}
}