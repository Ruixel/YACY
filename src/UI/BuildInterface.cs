using System;
using System.Reflection;
using Godot;
using Godot.Collections;
using YACY.Build;
using YACY.Entities;
using YACY.Geometry;
using YACY.Legacy.Objects;
using YACY.Util;

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
		CreatePreviewButton<LegacyPlatform>();

		_buildManager.OnToolChange += (sender, info) =>
		{
			var (toolType, type) = info;
			
			var entity = _buildManager.GetDefaultEntity(type);
			if (entity != null)
			{
				foreach (var property in _itemEditor.GetNode<Control>("MarginContainer/VBoxContainer").GetChildren())
				{
					var node = (Node) property;
					if (node is IPropertyUI ui)
					{
						ui.Disconnect();
					}
				}
				
				foreach (var component in entity.GetAllComponents())
				{
					component.RenderUI(_itemEditor);
				}
			}
		};
	}

	private void CreatePreviewButton<T>() where T : BuildEntity, new()
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
			
			// Choose the correct tool depending on how
			var buildManager = Core.GetManager<BuildManager>();
			MethodInfo setToolMethod = typeof(BuildManager).GetMethod("SetTool");
			if (typeof(T).IsSubclassOf(typeof(PencilBuildEntity)))
			{
				//Core.GetManager<BuildManager>().SetTool<T>();
				MethodInfo genericSetToolMethod = setToolMethod?.MakeGenericMethod(typeof(T));
				genericSetToolMethod?.Invoke(buildManager, null);
			}
			else
			{
				buildManager.TempSetPlacementTool<T>();
			}
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
