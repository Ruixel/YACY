using System;
using Godot;
using YACY.Build;

namespace YACY.UI;

public class SpinboxUI : Control, IPropertyUI
{
	private readonly Func<int, int, ICommand> _getCommand;
	private readonly PackedScene SpinBox = ResourceLoader.Load<PackedScene>("res://Scenes/UI/Properties/SpinBox.tscn");

	private Control _spinBox;

	public SpinboxUI(string name, int min, int max, Func<int, int, ICommand> getCommand)
	{
		_getCommand = getCommand;
		_spinBox = SpinBox.Instance<HBoxContainer>();
		_spinBox.GetNode<Label>("Label").Text = name;

		var spinBox = _spinBox.GetNode<SpinBox>("SpinBox");
		spinBox.MinValue = min;
		spinBox.MaxValue = max;
		spinBox.Value = 1;
		
		spinBox.Connect("value_changed", this, nameof(OnSpinBoxChange));
		AddChild(_spinBox);
	}

	private void OnSpinBoxChange(float newValue)
	{
		var entity = Core.GetManager<SelectionManager>().GetItemsSelected()[0];
		if (entity != null)
		{
			var command = _getCommand.Invoke(entity.Id, (int)newValue);
			Core.GetManager<LevelManager>().BroadcastCommandToEntity(entity.Id, command);
		}
	}

	public void Disconnect()
	{
		_spinBox.QueueFree();
	}
}