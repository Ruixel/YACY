using System;
using System.Collections.Generic;
using Godot;
using YACY.Build;
using YACY.Entities;
using YACY.Entities.Components;
using YACY.MeshGen;
using YACY.Util;

namespace YACY.Legacy.Objects
{
	[BuildItem(
		Name = "Wall",
		Tool = ToolType.Pencil,
		ItemPanelPreview = "res://Scenes/UI/Previews/ItemPanel/CYWall.tscn",
		SelectionPreview = "res://Scenes/UI/Previews/Selected/CYWall.tscn")]
	public partial class LegacyWall : BuildEntity
	{
		private MeshInstance3D _meshInstance;

		public LegacyWall()
		{
			Level = Core.GetManager<BuildManager>().Level;
			AddDefaultProperties();

			AddComponent(new TextureComponent(this));
			AddComponent(new DisplacementComponent());
			AddComponent(new HeightComponent());
		}

		public LegacyWall(int id, List<Component> components) : base(id, components)
		{
			Level = Core.GetManager<BuildManager>().Level;
			AddDefaultProperties();
		}

		private void AddDefaultProperties()
		{
			Type = BuildEntityList.Type.LegacyWall;

			_meshInstance = new MeshInstance3D();
			AddChild(_meshInstance);
		}

		public override void GenerateMesh()
		{
			var textureComponent = GetComponent<TextureComponent>();
			var displacementComponent = GetComponent<DisplacementComponent>();
			var heightComponent = GetComponent<HeightComponent>();

			var endPosition = displacementComponent.Displacement;
			if (!Position.IsEqualApprox(endPosition))
			{
				_meshInstance.Mesh = WallGenerator.GenerateFlatWall(Position, endPosition, Level,
					textureComponent.TextureName, textureComponent.Color, heightComponent.BottomHeight,
					heightComponent.TopHeight);
			}
		}

		public override Mesh CreateSelectionMesh()
		{
			var displacementComponent = GetComponent<DisplacementComponent>();
			var heightComponent = GetComponent<HeightComponent>();

			var endPosition = displacementComponent.Displacement;
			return WallGenerator.GenerateSelectionFlatWall(Position, endPosition, Level, heightComponent.BottomHeight, heightComponent.TopHeight, 0.05f);
		}
	}
}