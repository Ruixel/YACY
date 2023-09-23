using Godot;
using MessagePack;
using YACY.Build;
using YACY.Entities;
using YACY.Geometry;
using YACY.Legacy.Objects;

namespace YACY.UI;

public partial class BuildInterface : Control
{
	private Control _levelSelector;
	private Control _itemEditor;
	private Control _menuBar;
	private BuildManager _buildManager;
	
	private PackedScene _itemPreviewButton = ResourceLoader.Load<PackedScene>("res://Scenes/UI/Previews/PreviewItemButton.tscn");

	public override void _Ready() {
		_buildManager = Core.GetManager<BuildManager>();
		
		_levelSelector = GetNode<Control>("LevelSelector");
		_itemEditor = GetNode<Control>("ItemEditor");
		_menuBar = GetNode<Control>("MenuBar/HBoxContainer");
		_buildManager.OnLevelChange += (_, level) =>
		{
			_levelSelector.GetNode<Label>("MarginContainer/VBoxContainer/Label").Text = level.ToString();
		};

		var levelUpButton = _levelSelector.GetNode<TextureButton>("MarginContainer/VBoxContainer/Up");
		levelUpButton.Connect("pressed", new Callable(this, "GoUpLevel"));
		var levelDownButton = _levelSelector.GetNode<TextureButton>("MarginContainer/VBoxContainer/Down");
		levelDownButton.Connect("pressed", new Callable(this, "GoDownLevel"));
		
		var saveButton = _menuBar.GetNode<Button>("Save");
		saveButton.Connect("pressed", new Callable(this, nameof(SaveLevelDialog)));
		var loadButton = _menuBar.GetNode<Button>("Load");
		loadButton.Connect("pressed", new Callable(this, nameof(LoadLevelDialog)));


		CreatePreviewButton<Wall>();
		CreatePreviewButton<LegacyWall>();
		CreatePreviewButton<LegacyPlatform>();

		_buildManager.OnToolChange += (_, info) =>
		{
			var (_, type) = info;
			
			var entity = _buildManager.GetDefaultEntity(type);
			if (entity != null)
			{
				foreach (var property in _itemEditor.GetNode<Control>("MarginContainer/VBoxContainer").GetChildren())
				{
					var node = property;
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
		
		var previewButton = _itemPreviewButton.Instantiate<PreviewItemButton>();
		previewButton.GetNode<SubViewport>("SubViewportContainer/SubViewport").World3D.ResourceLocalToScene = true;
		previewButton.AddMesh(itemMetadata?.ItemPanelPreview);
		previewButton.SetName(itemMetadata?.Name);

		previewButton.onPressed += (_, _) =>
		{
			GD.Print($"Toggling {itemMetadata?.Name}");

			GetNode<Control>("ItemSelected").Call("change_item", itemMetadata?.SelectionPreview, itemMetadata?.Name );
			
			// Choose the correct tool depending on how
			_buildManager.SetTool<T>();
		};
		
		GetNode<GridContainer>("ItemPanel/GridContainer").AddChild(previewButton);
	}

	// private void GoUpLevel()
	// {
	// 	_buildManager.SetLevel(_buildManager.Level + 1);
	// }

	private void SaveLevelDialog()
	{
		var saveDialog = new FileDialog();
		saveDialog.FileMode = FileDialog.FileModeEnum.SaveFile;
		saveDialog.CurrentPath = "res://res/levels/test/Untitled.cy";
		saveDialog.MinSize = new Vector2I(700, 450);
		saveDialog.Unresizable = true;
		
		saveDialog.Connect("file_selected", new Callable(this, nameof(SaveLevel)));
		
		AddChild(saveDialog);
		saveDialog.PopupCentered();
	}

	private void SaveLevel(string path)
	{
		var levelData = Core.GetManager<LevelManager>().SerializeLevel();
		
		GD.Print(path);
		GD.Print(MessagePackSerializer.ConvertToJson(levelData));

		var file = FileAccess.Open(path, FileAccess.ModeFlags.Write);
		file.StoreBuffer(levelData);
		file.Close();
	}
	
	private void LoadLevelDialog()
	{
		var loadDialog = new FileDialog();
		loadDialog.FileMode = FileDialog.FileModeEnum.OpenFile;
		loadDialog.CurrentPath = "res://res/levels/test/";
		loadDialog.MinSize = new Vector2I(700, 450);
		loadDialog.Unresizable = true;
		
		loadDialog.Connect("file_selected", new Callable(this, nameof(LoadLevel)));
		
		AddChild(loadDialog);
		loadDialog.PopupCentered();
	}
	
	private void LoadLevel(string path)
	{
		var file = FileAccess.Open(path, FileAccess.ModeFlags.Read);
		var content = file.GetBuffer((long) file.GetLength());
		file.Close();

		Core.GetManager<LevelManager>().LoadLevel(content);
		
		GD.Print("Loaded successfully");
	}
	
	// private void GoDownLevel()
	// {
	// 	_buildManager.SetLevel(_buildManager.Level - 1);
	// }
}
