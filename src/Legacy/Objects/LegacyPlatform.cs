using System;
using Godot;
using YACY.Build;
using YACY.Entities;
using YACY.Entities.Components;
using YACY.MeshGen;
using YACY.Util;

namespace YACY.Legacy.Objects
{
	[BuildItem(
		Name = "Platform",
		Tool = ToolType.Placement,
		ItemPanelPreview = "res://Scenes/UI/Previews/ItemPanel/ThickPlatform.tscn",
		SelectionPreview = "res://Scenes/UI/Previews/Selected/Platform.tscn")]
	public class LegacyPlatform : BuildEntity
	{
		private MeshInstance _meshInstance;

		public LegacyPlatform(Vector2 position, int level)
		{
			Position = position;
			Level = level;
			
			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);

			AddComponent(new TextureComponent(this));
		}

		public LegacyPlatform()
		{
			Position = Vector2.Zero;
			Level = Core.GetManager<BuildManager>().Level;
			
			_meshInstance = new MeshInstance();
			AddChild(_meshInstance);
			
			AddComponent(new TextureComponent(this));
		}

		public override void GenerateMesh()
		{
			var textureComponent = GetComponent<TextureComponent>();
			//_meshInstance.Mesh = WallGenerator.GenerateFlatWall(new Vector2(0,0), new Vector2(2, 2), Level, textureComponent.TextureName, textureComponent.Color, 0, 1);
			Console.WriteLine($"Level: {Level}");
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