using System;
using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Build.Tools;
using YACY.Entities;
using YACY.MeshGen;

namespace YACY.Geometry
{
	public class Wall : PencilBuildEntity, IStoredPosition
	{
		public Color Color { get; set; }

		public Tuple<Vector2, Vector2> FrontLine;
		public Tuple<Vector2, Vector2> BackLine;

		public float StartHeight { get; set; }
		public float EndHeight { get; set; }
		public int Level { get; }

		private MeshInstance _meshInstance;
		private MeshInstance _meshOutline;

		private static Random random = new Random();

		private static readonly List<Color> AvailableColors = new List<Color>
			//{Colors.Aqua, Colors.Bisque, Colors.Brown, Colors.Gainsboro, Colors.Ivory, Colors.Orange, Colors.MintCream};
			{
				Colors.SpringGreen, Colors.DodgerBlue, Colors.Firebrick, Colors.DarkSlateBlue, Colors.HotPink, Colors.Maroon
			};

		public Wall(Vector2 startPosition, Vector2 endPosition, int level): base(startPosition, endPosition)
		{
			Level = level;
			AddDefaultProperties();
		}

		public Wall(): base(Vector2.Zero, Vector2.Zero)
		{
			Level = Core.GetManager<BuildManager>().Level;
			AddDefaultProperties();
		}

		private void AddDefaultProperties()
		{
			StartHeight = 0;
			EndHeight = 1;

			Color = AvailableColors[random.Next(AvailableColors.Count)];

			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);

			_meshOutline = new MeshInstance();
			_meshInstance.AddChild(_meshOutline);
		}

		public override void GenerateMesh()
		{
			if (!StartPosition.IsEqualApprox(EndPosition))
			{
				var startWalls = Core.GetManager<LevelManager>().GetEntitiesAtPosition<Wall>(StartPosition, Id);
				var endWalls = Core.GetManager<LevelManager>().GetEntitiesAtPosition<Wall>(EndPosition, Id);
				GenerateMergedMesh(startWalls, endWalls, true);
			}
		}

		public void GenerateMergedMesh(List<Wall> startWalls, List<Wall> endWalls, bool propagate = false)
		{
			_meshInstance.Mesh = WallGenerator.GenerateComplexWall(this, startWalls, endWalls, Level, propagate);
			//GD.Print($"FrontLine: {FrontLine.Item1}");
		}
		
		public Mesh CreateSelectionMesh()
		{
			throw new NotImplementedException();
		}

		public IEnumerable<Vector2> GetPositions()
		{
			return new[] {StartPosition, EndPosition};
		}
	}
}