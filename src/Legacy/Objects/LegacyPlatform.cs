using System;
using System.Collections.Generic;
using System.Diagnostics;
using Godot;
using MessagePack;
using YACY.Build;
using YACY.Entities;
using YACY.Entities.Components;
using YACY.MeshGen;
using YACY.Util;

namespace YACY.Legacy.Objects
{
	[MessagePackObject]
	[BuildItem(
		Name = "Platform",
		Tool = ToolType.Placement,
		ItemPanelPreview = "res://Scenes/UI/Previews/ItemPanel/ThickPlatform.tscn",
		SelectionPreview = "res://Scenes/UI/Previews/Selected/Platform.tscn")]
	public class LegacyPlatform : BuildEntity
	{
		[IgnoreMember] private MeshInstance _meshInstance;

		public LegacyPlatform()
		{
			Position = Vector2.Zero;
			Level = Core.GetManager<BuildManager>().Level;
			AddDefaultProperties();

			AddComponent(new TextureComponent(this));
			AddComponent(new HeightComponent());
			AddComponent(new SizeComponent(0,1, 4));
		}

		public LegacyPlatform(int id, List<Component> components) : base(id, components)
		{
			Position = Vector2.Zero;
			Level = 1;
			AddDefaultProperties();
		}

		private void AddDefaultProperties()
		{
			Type = BuildEntityList.Type.LegacyPlatform;

			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);
		}

		public override void GenerateMesh()
		{
			var textureComponent = GetComponent<TextureComponent>();
			var heightComponent = GetComponent<HeightComponent>();
			var sizeComponent = GetComponent<SizeComponent>();
			
			_meshInstance.Mesh = PlatformGenerator.GeneratePlatform(Position, GetSize(sizeComponent.Size), Level,
				heightComponent.BottomHeight, textureComponent.TextureName, textureComponent.Color, IsTransparent, 0,
				0);
		}

		private Vector2 GetSize(int sizeIndex)
		{
			return sizeIndex switch
			{
				2 => new Vector2(4, 4),
				3 => new Vector2(8, 8),
				4 => new Vector2(16, 16),
				_ => new Vector2(2, 2)
			};
		}

		public override Mesh CreateSelectionMesh()
		{
			//return PlatformGenerator.GenerateSelectionFlatPlatform(StartPosition, EndPosition, Level, 0, 1, 0.05f);
			//throw new NotImplementedException();
			return new CubeMesh();
		}
	}
}