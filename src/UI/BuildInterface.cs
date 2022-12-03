using Godot;
using YACY.Build;

namespace YACY.UI;

public class BuildInterface : Control
{
	private Control _levelSelector;
	private BuildManager _buildManager;

	public override void _Ready() {
		_buildManager = Core.GetManager<BuildManager>();
		
		_levelSelector = GetNode<Control>("LevelSelector");
		_buildManager.onLevelChange += (sender, level) =>
		{
			_levelSelector.GetNode<Label>("MarginContainer/VBoxContainer/Label").Text = level.ToString();
		};

		var levelUpButton = _levelSelector.GetNode<TextureButton>("MarginContainer/VBoxContainer/Up");
		levelUpButton.Connect("pressed", this, "GoUpLevel");
		var levelDownButton = _levelSelector.GetNode<TextureButton>("MarginContainer/VBoxContainer/Down");
		levelDownButton.Connect("pressed", this, "GoDownLevel");
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
