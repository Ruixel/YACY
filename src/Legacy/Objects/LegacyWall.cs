using System;
using Godot;
using YACY.Entities;
using YACY.MeshGen;

namespace YACY.Legacy.Objects
{
	public class LegacyWall : Spatial, IEntity
	{
		
		public int Id { get; }
		public Vector2 StartPosition { get; }
		public Vector2 EndPosition { get; }
		public Color Color { get; }

		public Tuple<Vector2, Vector2> FrontLine;
		public Tuple<Vector2, Vector2> BackLine;

		private MeshInstance _meshInstance;

		public LegacyWall(Vector2 startPosition, Vector2 endPosition)
		{
			Id = Core.GetCore().GetNextId();
			
			StartPosition = startPosition;
			EndPosition = endPosition;

			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);
		}

		public void GenerateMesh()
		{
			_meshInstance.Mesh = WallGenerator.GenerateFlatWall(StartPosition, EndPosition, 1, 0, 1);
		}
		
		public Mesh CreateSelectionMesh()
		{
			return WallGenerator.GenerateSelectionFlatWall(StartPosition, EndPosition, 1, 0, 1, 0.05f);
		}
	}
}