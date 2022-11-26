using System;
using System.Collections.Generic;
using Godot;
using YACY.Build.Tools;
using YACY.Entities;
using YACY.MeshGen;

namespace YACY.Geometry
{
	public class Wall : BuildEntity, IEntity
	{
		public Vector2 StartPosition { get; }
		public Vector2 EndPosition { get; }
		public Color Color { get; }

		public Tuple<Vector2, Vector2> FrontLine;
		public Tuple<Vector2, Vector2> BackLine;

		public float StartHeight { get; set; }
		public float EndHeight { get; set; }

		private MeshInstance _meshInstance;
		private MeshInstance _meshOutline;

		private static Random random = new Random();

		private static readonly List<Color> AvailableColors = new List<Color>
			//{Colors.Aqua, Colors.Bisque, Colors.Brown, Colors.Gainsboro, Colors.Ivory, Colors.Orange, Colors.MintCream};
			{
				Colors.SpringGreen, Colors.DodgerBlue, Colors.Firebrick, Colors.DarkSlateBlue, Colors.HotPink, Colors.Maroon
			};

		public Wall(Vector2 startPosition, Vector2 endPosition)
		{
			StartPosition = startPosition;
			EndPosition = endPosition;

			StartHeight = 0;
			EndHeight = 1;

			Color = AvailableColors[random.Next(AvailableColors.Count)];

			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);

			_meshOutline = new MeshInstance();
			_meshInstance.AddChild(_meshOutline);
		}

		public void GenerateMesh()
		{
			_meshInstance.Mesh = WallGenerator.GenerateWall(StartPosition, EndPosition, 1, StartHeight, EndHeight, 0.1f);
			_meshOutline.Mesh = _meshInstance.Mesh.CreateOutline(0.05f);
		}

		public void GenerateMergedMesh(List<Wall> startWalls, List<Wall> endWalls, bool propagate = false)
		{
			_meshInstance.Mesh = WallGenerator.GenerateComplexWall(this, startWalls, endWalls, propagate);
			//GD.Print($"FrontLine: {FrontLine.Item1}");
		}
		
		public Mesh CreateSelectionMesh()
		{
			throw new NotImplementedException();
		}
	}
}