using System;
using Godot;
using MessagePack;
using YACY.Build;
using YACY.Build.Tools;
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
	public class LegacyWall : PencilBuildEntity
	{
		public Tuple<Vector2, Vector2> FrontLine;
		public Tuple<Vector2, Vector2> BackLine;

		private MeshInstance _meshInstance;
		
		public LegacyWall(Vector2 startPosition, Vector2 endPosition, int level) : base(startPosition, endPosition)
		{
			_meshInstance = new MeshInstance();
			Level = level;	
			Type = ItemList.BuildEntityType.LegacyWall;
			
			AddChild(_meshInstance);
			
			AddComponent(new TextureComponent(this));
		}

		public LegacyWall() : base(Vector2.Zero, Vector2.Zero)
		{
			_meshInstance = new MeshInstance();
			Level = Core.GetManager<BuildManager>().Level;
			Type = ItemList.BuildEntityType.LegacyWall;
			
			AddChild(_meshInstance);
			
			AddComponent(new TextureComponent(this));
		}

		public override void GenerateMesh()
		{
			var textureComponent = GetComponent<TextureComponent>();
			if (!StartPosition.IsEqualApprox(EndPosition))
				_meshInstance.Mesh = WallGenerator.GenerateFlatWall(StartPosition, EndPosition, Level, textureComponent.TextureName, textureComponent.Color, 0, 1);
		}
		
		public override Mesh CreateSelectionMesh()
		{
			return WallGenerator.GenerateSelectionFlatWall(StartPosition, EndPosition, Level, 0, 1, 0.05f);
		}
	}
}