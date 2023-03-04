using System;
using Godot;
using Godot.Collections;
using YACY.Build;
using YACY.Entities;
using YACY.Geometry;
using YACY.Legacy.Objects;

namespace YACY.UI;

public class BuildInterface : Control
{
	private Control _levelSelector;
	private Control _itemEditor;
	private BuildManager _buildManager;
	
	private PackedScene _itemPreviewButton = ResourceLoader.Load<PackedScene>("res://Scenes/UI/Previews/PreviewItemButton.tscn");

	public override void _Ready() {
		_buildManager = Core.GetManager<BuildManager>();
		
		_levelSelector = GetNode<Control>("LevelSelector");
		_itemEditor = GetNode<Control>("ItemEditor");
		_buildManager.OnLevelChange += (sender, level) =>
		{
			_levelSelector.GetNode<Label>("MarginContainer/VBoxContainer/Label").Text = level.ToString();
		};

		var levelUpButton = _levelSelector.GetNode<TextureButton>("MarginContainer/VBoxContainer/Up");
		levelUpButton.Connect("pressed", this, "GoUpLevel");
		var levelDownButton = _levelSelector.GetNode<TextureButton>("MarginContainer/VBoxContainer/Down");
		levelDownButton.Connect("pressed", this, "GoDownLevel");

		CreatePreviewButton<Wall>();
		CreatePreviewButton<LegacyWall>();

		var textureProperties = new TexturePropertyUI();
		textureProperties.Render(_itemEditor); 
	}

	private void CreatePreviewButton<T>() where T : PencilBuildEntity, IEntity, new()
	{
		BuildItemAttribute itemMetadata = null;
		var attrs = System.Attribute.GetCustomAttributes(typeof(T));
		foreach (var attribute in attrs)
		{
			if (attribute is BuildItemAttribute itemAttribute)
			{
				itemMetadata = itemAttribute;
			}
		}
		
		var previewButton = _itemPreviewButton.Instance<PreviewItemButton>();
		previewButton.GetNode<Viewport>("ViewportContainer/Viewport").World.ResourceLocalToScene = true;
		previewButton.AddMesh(itemMetadata?.ItemPanelPreview);
		previewButton.SetName(itemMetadata?.Name);

		previewButton.onPressed += (sender, args) =>
		{
			GD.Print($"Toggling {itemMetadata?.Name}");

			GetNode<Control>("ItemSelected").Call("change_item", itemMetadata?.SelectionPreview, itemMetadata?.Name );
			Core.GetManager<BuildManager>().SetTool<T>();
		};
		
		GetNode<GridContainer>("ItemPanel/GridContainer").AddChild(previewButton);
	}

	private void GoUpLevel()
	{
		_buildManager.SetLevel(_buildManager.Level + 1);
	}
	
	private void GoDownLevel()
	{
		_buildManager.SetLevel(_buildManager.Level - 1);
	}
}
