using System;
using Godot;
using YACY.Build.Tools;
using YACY.Entities;
using YACY.MeshGen;

namespace YACY.Legacy.Objects
{
	public class LegacyWall : PencilBuildEntity, IEntity
	{
		public Color Color { get; }

		public Tuple<Vector2, Vector2> FrontLine;
		public Tuple<Vector2, Vector2> BackLine;

		private MeshInstance _meshInstance;

		public LegacyWall(Vector2 startPosition, Vector2 endPosition) : base(startPosition, endPosition)
		{
			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);
		}

		public LegacyWall() : base(Vector2.Zero, Vector2.Zero)
		{
			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);
		}

		public override void GenerateMesh()
		{
			if (!StartPosition.IsEqualApprox(EndPosition))
				_meshInstance.Mesh = WallGenerator.GenerateFlatWall(StartPosition, EndPosition, 1, 0, 1);
		}
		
		public Mesh CreateSelectionMesh()
		{
			return WallGenerator.GenerateSelectionFlatWall(StartPosition, EndPosition, 1, 0, 1, 0.05f);
		}
	}
}