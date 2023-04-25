using System;
using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Entities;
using YACY.Entities.Components;
using YACY.MeshGen;
using YACY.Util;
using ItemList = YACY.Build.ItemList;

namespace YACY.Legacy.Objects
{
	[BuildItem(
		Name = "Wall",
        Tool = ToolType.Pencil,
		ItemPanelPreview = "res://Scenes/UI/Previews/ItemPanel/CYWall.tscn", 
		SelectionPreview = "res://Scenes/UI/Previews/Selected/CYWall.tscn")]
	public class LegacyWall : BuildEntity
	{
		private MeshInstance _meshInstance;
		
		public LegacyWall()
		{
			Level = Core.GetManager<BuildManager>().Level;
			AddDefaultProperties();
		}
		
		public LegacyWall(int id, List<Component> components) : base(id, components)
		{
			Level = Core.GetManager<BuildManager>().Level;
			AddDefaultProperties();
		}

		private void AddDefaultProperties()
		{
			Type = ItemList.BuildEntityType.LegacyWall;
			
			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);
			
			AddComponent(new TextureComponent(this));
			AddComponent(new DisplacementComponent());
		}

		public override void GenerateMesh()
		{
			var textureComponent = GetComponent<TextureComponent>();
			var displacementComponent = GetComponent<DisplacementComponent>();

			var endPosition = displacementComponent.Displacement;
			if (!Position.IsEqualApprox(endPosition))
				_meshInstance.Mesh = WallGenerator.GenerateFlatWall(Position, endPosition, Level, textureComponent.TextureName, textureComponent.Color, 0, 1);
		}
		
		public override Mesh CreateSelectionMesh()
		{
			var displacementComponent = GetComponent<DisplacementComponent>();

			var endPosition = displacementComponent.Displacement;
			return WallGenerator.GenerateSelectionFlatWall(Position, endPosition, Level, 0, 1, 0.05f);
		}
	}
}