using System.Diagnostics;
using Godot;
using MessagePack;
using YACY.Build;
using YACY.Build.Commands;
using YACY.UI;

namespace YACY.Entities.Components;

[MessagePackObject]
public class SizeComponent : Component
{
	public SizeComponent(int minSize, int maxSize)
	{
		Debug.Assert(maxSize > minSize);

		_minSize = minSize;
		_maxSize = maxSize;
	}

	[Key(1)] public int Size { get; set; } = 1;

	[IgnoreMember]
	private int _minSize;
	[IgnoreMember]
	private int _maxSize;

	public void ChangeSize(int newSize)
	{
		Size = Mathf.Clamp(newSize, _minSize, _maxSize);
	}

	public override void RenderUI(Control itemEditor)
	{
		var propertyList = itemEditor.GetNode<Control>("MarginContainer/VBoxContainer");

		propertyList?.AddChild(new SpinboxUI("Size", _minSize, _maxSize,
			(entityId, newValue) => new ChangeSizeCommand(entityId, newValue)));
	}
}