using System;
using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Entities;
using YACY.Entities.Components;
using YACY.MeshGen;
using YACY.Util;
using ItemList = YACY.Build.ItemList;

namespace YACY.Geometry
{
	[BuildItem(
		Name = "Fat Wall",
		Tool = ToolType.Pencil,
		ItemPanelPreview = "res://Scenes/UI/Previews/ItemPanel/ThickWall.tscn", 
		SelectionPreview = "res://Scenes/UI/Previews/Selected/ThickWall.tscn")]
	public class Wall : BuildEntity, IStoredPosition
	{
		private MeshInstance _meshInstance;
		
		public Tuple<Vector2, Vector2> FrontLine;
		public Tuple<Vector2, Vector2> BackLine;
		
		public Vector2 StartPosition => Position;
		public Vector2 EndPosition => GetComponent<DisplacementComponent>().Displacement;

		public Wall()
		{
			Level = Core.GetManager<BuildManager>().Level;
			AddDefaultProperties();
			
			AddComponent(new DisplacementComponent());
		}

		public Wall(int id, List<Component> components) : base(id, components)
		{
			Level = Core.GetManager<BuildManager>().Level;
			AddDefaultProperties();
		}

		private void AddDefaultProperties()
		{
			Type = ItemList.BuildEntityType.Wall;

			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);
		}

		public override void GenerateMesh()
		{
			var displacementComponent = GetComponent<DisplacementComponent>();
			var endPosition = displacementComponent.Displacement;
			
			if (Position.IsEqualApprox(endPosition)) return;
			
			var startWalls = Core.GetManager<LevelManager>().GetEntitiesAtPosition<Wall>(Position, Id);
			var endWalls = Core.GetManager<LevelManager>().GetEntitiesAtPosition<Wall>(endPosition, Id);
			GenerateMergedMesh(startWalls, endWalls, true);
		}

		public void GenerateMergedMesh(List<Wall> startWalls, List<Wall> endWalls, bool propagate = false)
		{
			_meshInstance.Mesh = ThickWallGenerator.GenerateComplexWall(this, startWalls, endWalls, Level, propagate);
		}
		
		public override Mesh CreateSelectionMesh()
		{
			return _meshInstance.Mesh.CreateOutline(0.05f);
		}

		public IEnumerable<Vector2> GetPositions()
		{
			return new[] {Position, GetComponent<DisplacementComponent>().Displacement};
		}
	}
}