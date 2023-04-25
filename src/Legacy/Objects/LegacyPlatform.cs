using System;
using System.Collections.Generic;
using Godot;
using MessagePack;
using YACY.Build;
using YACY.Entities;
using YACY.Entities.Components;
using YACY.MeshGen;
using YACY.Util;
using ItemList = YACY.Build.ItemList;

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
		[IgnoreMember]
		private MeshInstance _meshInstance;

		public LegacyPlatform(Vector2 position, int level)
		{
			Position = position;
			Level = level;
			AddDefaultProperties();
		}

		public LegacyPlatform()
		{
			Position = Vector2.Zero;
			Level = Core.GetManager<BuildManager>().Level;
			AddDefaultProperties();
		}

		public LegacyPlatform(int id, List<Component> components): base(id, components)
		{
			Position = Vector2.Zero;
			Level = 1;
			AddDefaultProperties();
		}	
		
		private void AddDefaultProperties() {
			Type = ItemList.BuildEntityType.LegacyPlatform;
			
			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);
			
			AddComponent(new TextureComponent(this));
		}

		public override void GenerateMesh()
		{
			var textureComponent = GetComponent<TextureComponent>();
			//_meshInstance.Mesh = WallGenerator.GenerateFlatWall(new Vector2(0,0), new Vector2(2, 2), Level, textureComponent.TextureName, textureComponent.Color, 0, 1);
			_meshInstance.Mesh = PlatformGenerator.GeneratePlatform(Position, new Vector2(2, 2), Level, 0, textureComponent.TextureName, textureComponent.Color, IsTransparent, 0, 0);
		}

		public override Mesh CreateSelectionMesh()
		{
			//return PlatformGenerator.GenerateSelectionFlatPlatform(StartPosition, EndPosition, Level, 0, 1, 0.05f);
			//throw new NotImplementedException();
			return new CubeMesh();
		}
	}
}